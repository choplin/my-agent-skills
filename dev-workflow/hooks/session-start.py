#!/usr/bin/env python3
"""SessionStart hook: inject the active dev-workflow work unit's state.

Best-effort: if there is no active work, or anything fails, emit nothing and
exit 0 so session start is never disrupted.
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _common import active_unit, read_stdin, session_id  # noqa: E402


def main():
    sid = session_id(read_stdin())
    # A fresh session has no binding yet, so this usually injects nothing; the
    # prune sweep is the real work here, clearing pointers from ended sessions.
    try:
        unit = active_unit(sid, prune=True)
    except Exception:
        return
    if not unit:
        return

    next_action = unit.get("next_action") or {}
    label = next_action.get("label")
    if not label:
        # No pending action -> nothing useful to inject.
        return
    skill = next_action.get("skill")

    name = os.path.basename(unit.get("path", ""))
    progress = unit.get("progress") or {}
    review = unit.get("review") or {}

    bits = ["state {}".format(unit.get("state"))]
    if progress.get("total"):
        bits.append("{}/{} steps".format(progress.get("done"), progress.get("total")))
    if review.get("phase"):
        bits.append("review {}".format(review.get("phase")))

    nxt = label + (" → run /dev-workflow:{}".format(skill) if skill else "")
    context = (
        "dev-workflow: there is active work in progress.\n"
        "- Unit: {} ({})\n"
        "- {}\n"
        "- Next: {}\n"
        "Use /dev-workflow:resume-work to continue, or proceed if you are "
        "starting unrelated work.".format(
            name, unit.get("level"), ", ".join(bits), nxt
        )
    )

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": context,
        }
    }))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Never disrupt session start.
        pass
