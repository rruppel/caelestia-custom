#!/usr/bin/env python3
"""Toggle wf-recorder for the focused Hyprland monitor.

Usage: python3 screen-record-toggle.py [toggle|status|start|stop]
Recording survives restarting the Caelestia/Quickshell UI.
"""
import fcntl
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import time

HOME = Path.home()
STATE = Path(os.environ.get("XDG_RUNTIME_DIR", str(HOME / ".cache"))) / "caelestia-recorder"
PIDFILE = STATE / "wf-recorder.pid"
LOCKFILE = STATE / "recorder.lock"
VIDEO_DIR = HOME / "Videos" / "Caelestia"


def valid_pid():
    try:
        pid = int(PIDFILE.read_text().strip())
        stat = Path(f"/proc/{pid}/stat").read_text()
        if stat.split(") ", 1)[1][0] == "Z":
            return None
        args = Path(f"/proc/{pid}/cmdline").read_bytes().split(b"\0")
        if args and Path(os.fsdecode(args[0])).name == "wf-recorder":
            return pid
    except (FileNotFoundError, ValueError, ProcessLookupError, PermissionError, IndexError):
        pass
    return None


def focused_output():
    monitors = json.loads(subprocess.check_output(["hyprctl", "-j", "monitors"], text=True))
    selected = next((m for m in monitors if m.get("focused")), None)
    if selected is None and len(monitors) == 1:
        selected = monitors[0]
    if not selected:
        raise RuntimeError("No focused Hyprland monitor found")
    return selected["name"]


def start():
    if valid_pid():
        print("recording")
        return
    if shutil.which("wf-recorder") is None:
        raise RuntimeError("wf-recorder is missing. Install: sudo apt install wf-recorder")
    monitor = focused_output()
    VIDEO_DIR.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("%Y-%m-%d_%H-%M-%S")
    outfile = VIDEO_DIR / f"record-{stamp}.mp4"
    logfile = STATE / "wf-recorder.log"
    with logfile.open("ab") as log:
        proc = subprocess.Popen(
            ["wf-recorder", "-o", monitor, "-r", "30", "-f", str(outfile)],
            stdin=subprocess.DEVNULL, stdout=log, stderr=subprocess.STDOUT,
            start_new_session=True, close_fds=True,
        )
    time.sleep(0.3)
    if proc.poll() is not None:
        raise RuntimeError(f"wf-recorder exited early; inspect {logfile}")
    PIDFILE.write_text(str(proc.pid))
    print("recording")


def stop():
    pid = valid_pid()
    if pid is None:
        PIDFILE.unlink(missing_ok=True)
        print("idle")
        return
    os.kill(pid, signal.SIGINT)
    # Give ffmpeg/wf-recorder time to flush and finalize MP4 metadata.
    for _ in range(100):
        if not valid_pid():
            break
        time.sleep(0.1)
    if not valid_pid():
        PIDFILE.unlink(missing_ok=True)
        print("idle")
    else:
        print("stopping")


def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "toggle"
    if action not in {"toggle", "status", "start", "stop"}:
        raise SystemExit("usage: screen-record-toggle.py [toggle|status|start|stop]")
    STATE.mkdir(parents=True, exist_ok=True)
    if action == "status":
        print("recording" if valid_pid() else "idle")
        return
    with LOCKFILE.open("a+") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if action == "stop" or (action == "toggle" and valid_pid()):
            stop()
        else:
            start()


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.SubprocessError, RuntimeError, json.JSONDecodeError) as exc:
        print(f"Caelestia recorder: {exc}", file=sys.stderr)
        sys.exit(1)
