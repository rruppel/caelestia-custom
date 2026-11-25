# Sequential wallpaper switching

The TopBar wallpaper capsule uses `scripts/next-wallpaper.py` to rotate through
regular image files in `~/Pictures/Wallpapers` alphabetically (case-insensitive).
It wraps around after the last file and remembers the last successfully applied
filename at `~/.local/state/caelestia-custom/last-wallpaper` (or
`$XDG_STATE_HOME/caelestia-custom/last-wallpaper`).

The state is stored outside the Git working tree. Missing/deleted previous
images are handled by selecting the next filename. Newly added wallpapers
join the sorted list on the next click.

To test manually:

```bash
python3 ~/.config/quickshell/caelestia/scripts/next-wallpaper.py
```

**Scope:** The TopBar button is sequential. Existing standalone
`caelestia wallpaper -r` commands and any separately installed auto-rotation
timers still use their own configuration, and are not modified by this feature.
