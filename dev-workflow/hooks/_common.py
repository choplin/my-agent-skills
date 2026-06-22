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


def active_unit(session_id, prune=False):
    """Run the evaluator and return the session's active work unit, or None.

    The active unit is bound per session (root/active/<session_id>.json); with
    no session id, or no binding, this returns None and the hook stays quiet.
    Pass prune=True to drop stale pointers first (session-start only).

    Self-contained best-effort: any failure (subprocess error, timeout,
    non-zero exit, empty/partial output, bad JSON) returns None rather than
    raising, so callers never have to guard against exceptions here. The
    subprocess timeout (8s) is kept below the hook timeout (10s in hooks.json)
    so TimeoutExpired is caught here before the harness kills the hook.
    """
    script, root = evaluator_paths()
    if not script:
        return None
    cmd = [sys.executable, script, "--root", root]
    if session_id:
        cmd += ["--session", session_id]
    if prune:
        cmd.append("--prune")
    try:
        out = subprocess.run(
            cmd, capture_output=True, text=True, timeout=8,
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


def read_stdin():
    try:
        return sys.stdin.read()
    except Exception:
        return ""


def session_id(stdin_raw):
    """Resolve the current session id from hook stdin, then the environment."""
    try:
        sid = json.loads(stdin_raw).get("session_id")
        if sid:
            return sid
    except Exception:
        pass
    return os.environ.get("CLAUDE_CODE_SESSION_ID") or None
