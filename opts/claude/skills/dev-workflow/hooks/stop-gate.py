#!/usr/bin/env python3
"""Stop hook: remind to run self-review when implementation is complete.

Blocks the stop when the active work unit is `potentially_complete` (all plan
steps done, no review started) — at most twice in a row for the same unit,
then yields. This is a reminder, not a loop engine. Any failure allows the
stop (best-effort).
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _common import (  # noqa: E402
    active_unit,
    evaluator_paths,
    read_stdin,
    session_id,
)

MAX_BLOCKS = 2


def allow():
    # Exit 0 with no decision -> the stop proceeds.
    sys.exit(0)


def counter_path():
    _, root = evaluator_paths()
    if not root:
        return None
    return os.path.join(root, ".stop-gate")


def read_count(path, unit):
    try:
        with open(path) as f:
            data = json.load(f)
        return data.get("count", 0) if data.get("unit") == unit else 0
    except Exception:
        return 0


def write_count(path, unit, count):
    try:
        with open(path, "w") as f:
            json.dump({"unit": unit, "count": count}, f)
    except Exception:
        pass


def reset(path):
    try:
        if path and os.path.exists(path):
            os.remove(path)
    except Exception:
        pass


def main():
    sid = session_id(read_stdin())
    path = counter_path()
    try:
        unit = active_unit(sid)
    except Exception:
        return allow()

    gate = bool(unit) and unit.get("state") == "potentially_complete"
    if not gate:
        reset(path)
        return allow()

    unit_path = unit.get("path", "")
    count = read_count(path, unit_path) if path else MAX_BLOCKS
    if count >= MAX_BLOCKS:
        # Already reminded twice; yield so the user is never trapped.
        reset(path)
        return allow()

    if path:
        write_count(path, unit_path, count + 1)

    name = os.path.basename(unit_path)
    reason = (
        "Implementation looks complete for '{}' (all plan steps done) but "
        "self-review has not run yet. Run /dev-workflow:self-review before "
        "finishing. Stop again to override.".format(name)
    )
    print(json.dumps({"decision": "block", "reason": reason}))
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Never trap the user on error.
        allow()
