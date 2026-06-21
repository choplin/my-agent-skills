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

# --- State contract (see references/state-schema.md) -------------------------

LEGACY_PHASE = {
    "COLLECTING FEEDBACK": "REVIEWING",
    "READY FOR IMPLEMENTATION": "REVIEWING",
    "IMPLEMENTING": "REVIEWING",
}
LEGACY_ITEM_STATUS = {
    "APPROACH RECORDED": "APPROACH PROPOSED",
}

# state -> (label, skill or None) for next-action dispatch
DISPATCH = {
    "spec_only": ("Create implementation plan", "create-plan"),
    "planned": ("Begin implementation from step 1", None),
    "in_progress": ("Continue from first unchecked step", None),
    "potentially_complete": ("Run self-review", "self-review"),
    "in_review": ("Resume user review", "user-review"),
    "review_complete": ("Run post-task", "post-task"),
    "epic_next_story": ("Start next Story", "create-spec"),
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
    resolved = counts.get("RESOLVED", 0) + counts.get("SKIPPED", 0)
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
        return "review_complete" if review_phase == "LGTM" else "in_review"
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
        review = state_obj.get("review")
        if review:
            review_phase = normalize_phase(review.get("phase"))
            items = [
                {"status": normalize_item_status(i.get("status", ""))}
                for i in (review.get("items") or [])
            ]
        has_spec = has_spec or bool(state_obj.get("criteria"))

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
            if review_txt:
                review_phase = parse_phase_from_review_md(review_txt)
                items = parse_review_items_from_md(review_txt)
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
    layout = [("epic", "epic.md"), ("story", "spec.md"), ("task", None)]
    for level, marker in layout:
        level_dir = os.path.join(root, level)
        if not os.path.isdir(level_dir):
            continue
        for name in sorted(os.listdir(level_dir)):
            unit_dir = os.path.join(level_dir, name)
            if not os.path.isdir(unit_dir):
                continue
            has_state = os.path.exists(os.path.join(unit_dir, "state.json"))
            if marker and not has_state and \
                    not os.path.exists(os.path.join(unit_dir, marker)):
                # story/epic require their marker unless a state.json is present;
                # task has no fixed marker and is always included.
                continue
            units.append(build_unit(unit_dir, level, branch_now))
    return units


def unit_mtime(unit_dir):
    """Most recent mtime among a unit's known documents (0.0 if none)."""
    latest = 0.0
    for fname in ("state.json", "review.md", "plan.md", "spec.md", "epic.md"):
        try:
            latest = max(latest, os.path.getmtime(os.path.join(unit_dir, fname)))
        except OSError:
            pass
    return latest


def resolve_active(units):
    """Pick the single work unit currently being worked on.

    Identification does not depend on one-branch-per-unit: a unique
    current-branch match wins; otherwise fall back to the most recently
    modified unit, preferring story/task over epic. Returns a path or None.
    """
    if not units:
        return None
    matches = [u for u in units if u["matches_current_branch"]]
    if len(matches) == 1:
        return matches[0]["path"]
    pool = matches if matches else units
    non_epic = [u for u in pool if u["level"] != "epic"]
    candidates = non_epic if non_epic else pool
    return max(candidates, key=lambda u: unit_mtime(u["path"]))["path"]


def main():
    ap = argparse.ArgumentParser(description="dev-workflow state evaluator")
    ap.add_argument("--root", default=".claude/dev-workflow",
                    help="root of dev-workflow documents (default: .claude/dev-workflow)")
    args = ap.parse_args()

    branch_now = current_branch()
    units = discover(args.root, branch_now) if os.path.isdir(args.root) else []
    active_path = resolve_active(units)
    for u in units:
        u["active"] = (u["path"] == active_path)
    out = {
        "current_branch": branch_now,
        "active_path": active_path,
        "work_units": units,
    }
    json.dump(out, sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
