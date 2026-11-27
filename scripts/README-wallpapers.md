# Sequential wallpaper switching with pause/resume

The TopBar wallpaper icon switches images alphabetically (A–Z) from
`~/Pictures/Wallpapers`. The original shuffle icon is intentionally retained.

- **Left click:** select next wallpaper and resume automatic cycling.
- **Right click:** show menu with **Pausar transições** or **Retomar transições**.
- **Pause:** retain the current wallpaper and skip scheduled changes.
- **Resume:** allow the next scheduled change (doesn't change wallpaper immediately).

The state is stored at `~/.local/state/caelestia-custom/`, outside Git:
`last-wallpaper` remembers the most recently applied filename and
`wallpaper-paused` holds the paused flag. Restarts do not clear the pause.

## Automatic changes (every 30 minutes)

The repository includes a systemd user timer that invokes the same alphabetical
wallpaper helper and obeys the pause state. To install or migrate the former
`caelestia-wallpaper.timer` rotation:

```bash
cd ~/.config/quickshell/caelestia
git pull --ff-only origin feature/top-bar
bash config/systemd/install-wallpaper-timer.sh
systemctl --user status caelestia-wallpaper.timer
```

The installer backs up existing timer/service definitions if they differ,
then symlinks the repository versions and activates the new schedule.

To stop automatic wallpaper rotation entirely:

```bash
systemctl --user disable --now caelestia-wallpaper.timer
```

**Important:** If you also have an *independent* wallpaper script in
Hyprland `exec-once`, a cron job or another service, disable that separately:
the pause flag controls this repository's automatic timer, not arbitrary
third-party wallpaper commands.

## Manual commands

```bash
python3 scripts/next-wallpaper.py status   # paused / running
python3 scripts/next-wallpaper.py pause    # pause scheduled rotation
python3 scripts/next-wallpaper.py resume   # resume without changing
python3 scripts/next-wallpaper.py next     # next image and resume
python3 scripts/next-wallpaper.py auto     # next image only if not paused
```

The helper locks concurrent requests to prevent conflicting state updates.
