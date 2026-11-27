#!/usr/bin/env python3
"""Cycle Caelestia wallpapers by filename (A-Z), remembering the last choice.

The command intentionally uses the regular Caelestia CLI so color transitions
and wallpaper state are handled by Caelestia itself.
"""
import fcntl
import os
from pathlib import Path
import subprocess
import sys

HOME = Path.home()
WALLPAPERS = HOME / "Pictures" / "Wallpapers"
STATE_DIR = Path(os.environ.get("XDG_STATE_HOME", str(HOME / ".local" / "state"))) / "caelestia-custom"
STATE_FILE = STATE_DIR / "last-wallpaper"
PAUSED_FILE = STATE_DIR / "wallpaper-paused"
LOCK_FILE = STATE_DIR / "wallpaper.lock"
CLI = HOME / ".local" / "bin" / "caelestia"
EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".gif", ".avif"}


def next_wallpaper():
    if not WALLPAPERS.is_dir():
        raise RuntimeError(f"Wallpaper folder not found: {WALLPAPERS}")

    candidates = sorted(
        (p for p in WALLPAPERS.iterdir()
         if p.is_file() and p.suffix.lower() in EXTENSIONS),
        key=lambda p: (p.name.casefold(), p.name),
    )
    if not candidates:
        raise RuntimeError(f"No supported images found in: {WALLPAPERS}")

    last_name = STATE_FILE.read_text(encoding="utf-8").strip() if STATE_FILE.exists() else ""
    names = [p.name for p in candidates]

    if last_name in names:
        chosen = candidates[(names.index(last_name) + 1) % len(candidates)]
    elif last_name:
        # If the previous file was deleted, continue from its former place.
        chosen = next((p for p in candidates if p.name.casefold() > last_name.casefold()), candidates[0])
    else:
        chosen = candidates[0]

    subprocess.run([str(CLI), "wallpaper", "-f", str(chosen)], check=True)
    STATE_FILE.write_text(chosen.name + "\n", encoding="utf-8")
    print(f"Wallpaper {names.index(chosen.name) + 1}/{len(candidates)}: {chosen.name}")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "next"
    if mode not in {"next", "auto", "status", "pause", "resume"}:
        raise SystemExit("usage: next-wallpaper.py [next|auto|status|pause|resume]")

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    with LOCK_FILE.open("a+") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if mode == "status":
            print("paused" if PAUSED_FILE.exists() else "running")
        elif mode == "pause":
            PAUSED_FILE.touch()
            print("paused")
        elif mode == "resume":
            PAUSED_FILE.unlink(missing_ok=True)
            print("running")
        elif mode == "auto":
            if PAUSED_FILE.exists():
                print("paused: skipping automatic wallpaper change")
            else:
                next_wallpaper()
        else:
            # Manual advancement always resumes automatic changes.
            next_wallpaper()
            PAUSED_FILE.unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"Caelestia wallpaper cycle: {exc}", file=sys.stderr)
        sys.exit(1)
