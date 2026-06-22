"""Shared helpers for dev-workflow hooks.

Both hooks are best-effort: any failure must end with the session/turn
proceeding normally. They delegate all state logic to scripts/workflow-state.py
and only format/act on its output.
"""

import json
import os
import subprocess
import sys


def evaluator_paths():
    """Return (script_path, root_dir) or (None, None) if unavailable."""
    plugin_root = os.environ.get("CLAUDE_PLUGIN_ROOT", "")
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    script = os.path.join(plugin_root, "scripts", "workflow-state.py")
    root = os.path.join(project_dir, ".claude", "dev-workflow")
    if not plugin_root or not os.path.exists(script) or not os.path.isdir(root):
        return None, None
    return script, root


def active_unit():
    """Run the evaluator and return the active work unit dict, or None.

    Self-contained best-effort: any failure (subprocess error, timeout,
    non-zero exit, empty/partial output, bad JSON) returns None rather than
    raising, so callers never have to guard against exceptions here. The
    subprocess timeout (8s) is kept below the hook timeout (10s in hooks.json)
    so TimeoutExpired is caught here before the harness kills the hook.
    """
    script, root = evaluator_paths()
    if not script:
        return None
    try:
        out = subprocess.run(
            [sys.executable, script, "--root", root],
            capture_output=True, text=True, timeout=8,
        )
    except Exception:
        return None
    if out.returncode != 0 or not out.stdout.strip():
        return None
    try:
        data = json.loads(out.stdout)
    except Exception:
        return None
    for unit in data.get("work_units", []):
        if unit.get("active"):
            return unit
    return None


def drain_stdin():
    try:
        return sys.stdin.read()
    except Exception:
        return ""
