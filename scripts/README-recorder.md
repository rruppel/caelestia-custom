# Caelestia TopBar screen recorder

The **Record** capsule appears to the left of the Shuffle wallpaper button.
Click once to record the **currently focused Hyprland monitor**, and again to
stop. The icon changes to red while recording.

- Dependency: `sudo apt install wf-recorder`
- Saved MP4 videos: `~/Videos/Caelestia/record-YYYY-MM-DD_HH-MM-SS.mp4`
- No audio is recorded in this first version.
- The recording is **detached** from Quickshell and survives a Caelestia reload.
- Avoid restarting the entire Wayland/Hyprland session while recording.

The helper is versioned at `scripts/screen-record-toggle.py` and invoked
directly by the TopBar; no files must be copied to `~/.local/bin`.

Manual troubleshooting:

```bash
python3 ~/.config/quickshell/caelestia/scripts/screen-record-toggle.py status
python3 ~/.config/quickshell/caelestia/scripts/screen-record-toggle.py toggle
tail -60 "${XDG_RUNTIME_DIR:-$HOME/.cache}/caelestia-recorder/wf-recorder.log"
```

The first click may take a moment to start recording. The second click waits
for `wf-recorder` to finalize MP4 metadata before confirming that recording has
stopped. A user-owned state file in `$XDG_RUNTIME_DIR/caelestia-recorder` holds
the recorder PID; the helper validates its process command before signaling it.

**Important:** this action records whatever is displayed on the chosen monitor,
including notifications and sensitive information. Review clips before posting.
