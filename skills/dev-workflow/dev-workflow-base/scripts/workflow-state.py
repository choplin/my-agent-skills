#!/usr/bin/env python3
"""dev-workflow state evaluator.

Scans .claude/dev-workflow/ and prints a single JSON object describing every
work unit's derived state. This is the single deterministic implementation of
the state contract defined in dev-workflow/references/state-schema.md.

Consumers (resume-work, handoff, workflow-status, self-review) run this script
and use its output instead of parsing Markdown or restating the priority table.

Usage:
    python3 dev-workflow/scripts/workflow-state.py [--root .claude/dev-workflow]

No third-party dependencies (stdlib only).
"""

import argparse
import json
import os
import re
import subprocess
import sys
import time

# --- State contract (see references/state-schema.md) -------------------------

# review.md (owned by the review-tools family) uses phase open/done and item
# statuses open/resolved/skipped/postponed. Map any legacy value onto those.
LEGACY_PHASE = {
    "REVIEWING": "open",
    "COLLECTING FEEDBACK": "open",
    "READY FOR IMPLEMENTATION": "open",
    "IMPLEMENTING": "open",
    "LGTM": "done",
}
LEGACY_ITEM_STATUS = {
    "OPEN": "open",
    "APPROACH PROPOSED": "open",
    "APPROACH RECORDED": "open",
    "APPROACH AGREED": "open",
    "IMPLEMENTING": "open",
    "RESOLVED": "resolved",
    "SKIPPED": "skipped",
}

# state -> (label, skill or None) for next-action dispatch
DISPATCH = {
    "spec_only": ("Create implementation plan", "dev-workflow-create-plan"),
    "planned": ("Begin implementation from step 1", None),
    "in_progress": ("Continue from first unchecked step", None),
    "potentially_complete": ("Run self-review", "dev-workflow-self-review"),
    "in_review": ("Resume user review", "dev-workflow-user-review"),
    "review_complete": ("Run post-task", "dev-workflow-post-task"),
    "epic_next_story": ("Start next Story", "dev-workflow-create-spec"),
    "blocked": ("Report blockers", None),
}


def normalize_phase(phase):
    if phase is None:
        return None
    phase = phase.strip()
    return LEGACY_PHASE.get(phase, phase)


def normalize_item_status(status):
    status = status.strip()
    return LEGACY_ITEM_STATUS.get(status, status)


# --- Git ---------------------------------------------------------------------


def current_branch():
    try:
        out = subprocess.run(
            ["git", "branch", "--show-current"],
            capture_output=True, text=True, check=False,
        )
        return out.stdout.strip() or None
    except Exception:
        return None


# --- Active-session pointers -------------------------------------------------
#
# The active work unit is bound per session, not guessed. Each dev-workflow
# skill records "this session is working on <unit>" the moment it knows its
# target unit, by writing root/active/<session_id>.json. Hooks pass their
# session id and act only on that session's unit; an unbound session is a
# no-op. See references/state-schema.md (Active-unit resolution).

POINTER_MAX_AGE_S = 7 * 24 * 3600  # stale-pointer cutoff for --prune


def active_dir(root):
    return os.path.join(root, "active")


def pointer_path(root, session_id):
    return os.path.join(active_dir(root), session_id + ".json")


def set_active(root, session_id, unit_path):
    d = active_dir(root)
    os.makedirs(d, exist_ok=True)
    with open(pointer_path(root, session_id), "w", encoding="utf-8") as f:
        json.dump({"unit": os.path.abspath(unit_path)}, f)


def clear_active(root, session_id):
    try:
        os.remove(pointer_path(root, session_id))
    except OSError:
        pass


def read_active_path(root, session_id):
    """Return the abspath of the unit bound to this session, or None.

    None when there is no session id, no pointer, an unreadable pointer, or
    the pointer targets a directory that no longer exists.
    """
    if not session_id:
        return None
    try:
        with open(pointer_path(root, session_id), encoding="utf-8") as f:
            target = json.load(f).get("unit")
    except Exception:
        return None
    if target and os.path.isdir(target):
        return os.path.abspath(target)
    return None


def prune_pointers(root):
    """Drop pointers whose unit is gone or whose file has aged out.

    Live sessions refresh their pointer's mtime on every skill use, so only
    orphans (ended sessions, deleted units) are removed. Best-effort.
    """
    d = active_dir(root)
    if not os.path.isdir(d):
        return
    now = time.time()
    for name in os.listdir(d):
        if not name.endswith(".json"):
            continue
        fp = os.path.join(d, name)
        try:
            with open(fp, encoding="utf-8") as f:
                target = json.load(f).get("unit")
            missing = not (target and os.path.isdir(target))
            aged = (now - os.path.getmtime(fp)) > POINTER_MAX_AGE_S
            stale = missing or aged
        except Exception:
            stale = True  # unreadable -> remove
        if stale:
            try:
                os.remove(fp)
            except OSError:
                pass


# --- Markdown fallback parsers ----------------------------------------------


def read(path):
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except OSError:
        return None


def parse_phase_from_review_md(text):
    m = re.search(r"^- \*\*Phase\*\*:\s*(.+?)\s*$", text, re.MULTILINE)
    return normalize_phase(m.group(1)) if m else None


def parse_mode_from_review_md(text):
    m = re.search(r"^- \*\*Mode\*\*:\s*(.+?)\s*$", text, re.MULTILINE)
    return m.group(1).strip() if m else None


def parse_progress_from_plan_md(text):
    """Return (done, total) from the ## Progress section checkboxes."""
    section = re.split(r"^##\s+Progress\s*$", text, flags=re.MULTILINE)
    if len(section) < 2:
        return (0, 0)
    body = section[1]
    # Stop at next H2 if present
    body = re.split(r"^##\s+", body, flags=re.MULTILINE)[0]
    done = len(re.findall(r"^- \[x\]", body, re.MULTILINE | re.IGNORECASE))
    pending = len(re.findall(r"^- \[ \]", body, re.MULTILINE))
    return (done, pending + done)


def parse_review_items_from_md(text):
    """Return list of {status} dicts from review.md Item blocks."""
    items = []
    for m in re.finditer(r"^- \*\*Status\*\*:\s*(.+?)\s*$", text, re.MULTILINE):
        raw = m.group(1).strip()
        # A template line may list options with '|'; skip those.
        if "|" in raw:
            continue
        items.append({"status": normalize_item_status(raw)})
    return items


def parse_epic_stories(text):
    """Return list of story status strings from the ## Stories table.

    The Status column is located by header name, so differing table layouts
    are tolerated (e.g. `| # | Story | Status | Dependencies |` vs
    `| Story | Status | Spec | Plan |`). The first table row is the header.
    """
    statuses = []
    section = re.split(r"^##\s+Stories\s*$", text, flags=re.MULTILINE)
    if len(section) < 2:
        return statuses
    body = re.split(r"^##\s+", section[1], flags=re.MULTILINE)[0]
    status_idx = None
    for line in body.splitlines():
        s = line.strip()
        if not s.startswith("|"):
            continue
        cols = [c.strip() for c in s.strip("|").split("|")]
        # Separator row, e.g. |---|---|
        if cols and all(c and set(c) <= set("-: ") for c in cols):
            continue
        # First non-separator row is the header: locate the Status column.
        if status_idx is None:
            lowered = [c.lower() for c in cols]
            if "status" in lowered:
                status_idx = lowered.index("status")
            continue
        if status_idx < len(cols):
            statuses.append(cols[status_idx])
    return statuses


# --- Title helper ------------------------------------------------------------


def parse_title(text, prefix):
    m = re.search(rf"^#\s+{re.escape(prefix)}:\s*(.+?)\s*$", text, re.MULTILINE)
    return m.group(1).strip() if m else None


# --- Work unit loading -------------------------------------------------------


def load_state_json(unit_dir):
    raw = read(os.path.join(unit_dir, "state.json"))
    if raw is None:
        return None
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return None


def review_summary(items):
    """Aggregate item statuses into counts + resolved string."""
    counts = {}
    for it in items:
        st = it.get("status")
        counts[st] = counts.get(st, 0) + 1
    total = len(items)
    resolved = sum(counts.get(k, 0) for k in ("resolved", "skipped", "postponed"))
    return counts, f"{resolved}/{total}"


def derive_state(level, has_spec, steps_done, steps_total,
                 review_phase, epic_statuses):
    if level == "epic":
        if not epic_statuses:
            return "blocked"
        if any(s.lower().startswith("not started") for s in epic_statuses):
            return "epic_next_story"
        if all(s.lower() == "done" for s in epic_statuses):
            return "review_complete"
        # Some stories past "Not Started" but not all "Done".
        return "in_progress"
    if review_phase is not None:
        return "review_complete" if review_phase == "done" else "in_review"
    if steps_total > 0 and steps_done == steps_total:
        return "potentially_complete"
    if steps_done > 0:
        return "in_progress"
    if steps_total > 0:
        return "planned"
    if has_spec:
        return "spec_only"
    return "blocked"


def build_unit(unit_dir, level, branch_now):
    state_obj = load_state_json(unit_dir)
    source = "state_json" if state_obj else "markdown_fallback"

    spec_txt = read(os.path.join(unit_dir, "spec.md"))
    plan_txt = read(os.path.join(unit_dir, "plan.md"))
    review_txt = read(os.path.join(unit_dir, "review.md"))
    epic_txt = read(os.path.join(unit_dir, "epic.md"))

    title = None
    branch = None
    steps_done = steps_total = 0
    review_phase = None
    items = []
    epic_statuses = []
    has_spec = spec_txt is not None

    if state_obj:
        title = state_obj.get("title")
        branch = state_obj.get("branch")
        steps = state_obj.get("steps") or []
        steps_total = len(steps)
        steps_done = sum(1 for s in steps if s.get("done"))
        has_spec = has_spec or bool(state_obj.get("criteria"))

    # Review state is read from review.md — the single source of truth owned by
    # the review-tools skills. state.json carries no `review` block; parse
    # review.md whenever it exists, regardless of state.json.
    if review_txt:
        review_phase = parse_phase_from_review_md(review_txt)
        items = parse_review_items_from_md(review_txt)

    if level == "epic":
        if epic_txt:
            title = title or parse_title(epic_txt, "Epic")
            epic_statuses = parse_epic_stories(epic_txt)
    else:
        # Markdown fallback fills whatever state.json did not provide
        if title is None:
            if plan_txt:
                title = parse_title(plan_txt, "Plan")
            elif spec_txt:
                title = parse_title(spec_txt, "Spec")
        if not state_obj:
            if plan_txt:
                steps_done, steps_total = parse_progress_from_plan_md(plan_txt)
        if branch is None and spec_txt:
            m = re.search(r"^- \*\*Name\*\*:\s*`?([^`\n]+?)`?\s*$",
                          spec_txt, re.MULTILINE)
            if m:
                branch = m.group(1).strip()

    state = derive_state(level, has_spec, steps_done, steps_total,
                         review_phase, epic_statuses)
    counts, resolved = review_summary(items)
    label, skill = DISPATCH.get(state, ("Unknown", None))

    return {
        "path": unit_dir,
        "level": level,
        "title": title,
        "branch": branch,
        "matches_current_branch": branch is not None and branch == branch_now,
        "state": state,
        "progress": {"done": steps_done, "total": steps_total},
        "review": {
            "phase": review_phase,
            "items": counts,
            "resolved": resolved,
        },
        "next_action": {"label": label, "skill": skill},
        "source": source,
    }


def discover(root, branch_now):
    units = []
    layout = [("epic", "epic.md"), ("story", "spec.md")]
    for level, marker in layout:
        level_dir = os.path.join(root, level)
        if not os.path.isdir(level_dir):
            continue
        for name in sorted(os.listdir(level_dir)):
            unit_dir = os.path.join(level_dir, name)
            if not os.path.isdir(unit_dir):
                continue
            has_state = os.path.exists(os.path.join(unit_dir, "state.json"))
            if not has_state and \
                    not os.path.exists(os.path.join(unit_dir, marker)):
                # story/epic require their marker unless a state.json is present.
                continue
            units.append(build_unit(unit_dir, level, branch_now))
    return units


def resolve_active(units, active_path):
    """Return the work unit this session is bound to, or None.

    Identification is explicit, not guessed: `active_path` is the unit recorded
    for the current session (see read_active_path). An unbound session resolves
    to None so passive hooks stay quiet. `matches_current_branch` is reported
    on each unit as a hint for interactive skills, but never selects here.
    """
    if not active_path:
        return None
    for u in units:
        if os.path.abspath(u["path"]) == active_path:
            return u["path"]
    return None


def main():
    ap = argparse.ArgumentParser(description="dev-workflow state evaluator")
    ap.add_argument("--root", default=".claude/dev-workflow",
                    help="root of dev-workflow documents (default: .claude/dev-workflow)")
    ap.add_argument("--session",
                    help="session id; binds active resolution to this session")
    ap.add_argument("--set", dest="set_unit", metavar="UNIT_PATH",
                    help="bind --session to this unit, then exit (no output)")
    ap.add_argument("--clear", action="store_true",
                    help="clear --session's binding, then exit (no output)")
    ap.add_argument("--prune", action="store_true",
                    help="drop stale session pointers before evaluating")
    args = ap.parse_args()

    # Mutating actions are terminal: bind/clear then exit without evaluating.
    if args.set_unit or args.clear:
        if not args.session:
            sys.stderr.write("--set/--clear require --session\n")
            sys.exit(2)
        if args.set_unit:
            set_active(args.root, args.session, args.set_unit)
        else:
            clear_active(args.root, args.session)
        return

    if args.prune:
        prune_pointers(args.root)

    branch_now = current_branch()
    units = discover(args.root, branch_now) if os.path.isdir(args.root) else []
    active_path = read_active_path(args.root, args.session)
    active_resolved = resolve_active(units, active_path)
    for u in units:
        u["active"] = (u["path"] == active_resolved)
    out = {
        "current_branch": branch_now,
        "active_path": active_resolved,
        "work_units": units,
    }
    json.dump(out, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
