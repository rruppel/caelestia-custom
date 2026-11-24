#!/usr/bin/env python3
"""Place the currently focused Hyprland window in one of six 3x2 zones."""
import json
import subprocess
import sys


def hypr(*args):
    return subprocess.check_output(["hyprctl", *args], text=True).strip()


def details(*args):
    return json.loads(hypr("-j", *args))


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in "123456":
        raise SystemExit("usage: snap6.py {1..6}")
    zone = int(sys.argv[1]) - 1
    window = details("activewindow")
    if not window or not window.get("address") or window.get("fullscreen"):
        raise SystemExit("No suitable active window (or window is fullscreen)")

    monitors = details("monitors")
    monitor = next((m for m in monitors if m["id"] == window.get("monitor")), None)
    if monitor is None:
        monitor = next((m for m in monitors if m.get("focused")), None)
    if monitor is None:
        raise SystemExit("Could not identify active monitor")

    scale = float(monitor.get("scale") or 1)
    mx, my = monitor["x"], monitor["y"]
    mw = round(monitor["width"] / scale)
    mh = round(monitor["height"] / scale)
    # Hyprland's reserved: top, bottom, left, right.
    top, bottom, left, right = monitor.get("reserved", [0, 0, 0, 0])
    # Hyprbars adds an external title decoration above floating windows.
    # Leave a generous buffer below the floating TopBar (ends at y=46).
    # hyprctl's reported window y can exclude decoration extents, so y=78
    # may render a title bar visually adjacent to/overlapping the TopBar.
    # Keep the snapped *client* top >= 120px, plus the grid's 12px margin.
    # Honour larger compositor reservations when present.
    topbar_clearance = 120
    effective_top = max(top, topbar_clearance)
    x0, y0 = mx + left, my + effective_top
    usable_w, usable_h = mw - left - right, mh - effective_top - bottom
    col, row = zone % 3, zone // 3
    margin, spacing = 12, 12
    usable_w -= 2 * margin
    usable_h -= 2 * margin
    cell_w = (usable_w - 2 * spacing) // 3
    cell_h = (usable_h - spacing) // 2
    x = x0 + margin + col * (cell_w + spacing)
    y = y0 + margin + row * (cell_h + spacing)
    w = cell_w if col != 2 else (x0 + margin + usable_w - x)
    h = cell_h if row != 1 else (y0 + margin + usable_h - y)
    addr = window["address"]
    if not window.get("floating", False):
        hypr("dispatch", "togglefloating", f"address:{addr}")
    hypr("dispatch", "resizewindowpixel", f"exact {w} {h},address:{addr}")
    hypr("dispatch", "movewindowpixel", f"exact {x} {y},address:{addr}")
    print(f"Snapped {addr} to zone {zone + 1}: {x},{y} {w}x{h}")


if __name__ == "__main__":
    main()
