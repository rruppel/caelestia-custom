# macOS-inspired Hyprbars (Hyprland 0.53.x)

This is a separate, versioned Hyprland configuration. It changes ONLY Hyprbars
appearance/button behavior, not TopBar, SnapZones or the free dragging mechanism.

## Preview

- 30px deep navy bar, centered Rubik title, and red/yellow/green buttons on the left.
- Red closes the current window.
- Yellow moves it to the existing `special:magic` scratchpad. Press `Super+S`
  to open that scratchpad; this is *not* a conventional minimize.
- Green toggles Hyprland's fullscreen mode 1 (maximized).
- Double-clicking empty titlebar area toggles mode 1.
- Dragging by the titlebar stays free, independent of SnapZones.

## Apply (safe and reversible)

After `git pull --ff-only origin feature/top-bar`, run:

```bash
bash ~/.config/quickshell/caelestia/config/hypr/install-hyprbars-macos.sh
```

The script creates a timestamped backup of `~/.config/hypr/hyprland.conf`,
links the new style file under `~/.config/hypr/`, adds ONE `source =` line,
and runs `hyprctl reload`. It refuses to overwrite an existing hyprbars
configuration in `hyprland.conf`. Existing Hyprbars plugin must remain loaded.

To revert: delete the line `source = ~/.config/hypr/hyprbars-macos.conf`
from `hyprland.conf`, then `hyprctl reload`. The original config remains
in the backup and the external file can be removed.

Some applications (notably browsers with their own client-side titlebars) may
need per-window no-bar rules. Test before adding exclusions.

## Space for Caelestia floating TopBar (Hyprland 0.53.x)

The TopBar overlays the upper 12–46 px of the desktop. Without reserved space,
normal tiled windows may begin immediately below the monitor edge and overlap
the bar. The file `topbar-clearance.conf` adds 60 px of compositor reserved
space at the top of each monitor; this yields a comfortable buffer under the
TopBar while leaving Hyprbars styling and normal dragging intact.

Apply after updating the repo:

```bash
bash ~/.config/quickshell/caelestia/config/hypr/install-topbar-clearance.sh
```

The installer symlinks the versioned file, adds one `source` line to
`~/.config/hypr/hyprland.conf`, saves a timestamped backup before writing,
and reloads Hyprland. It refuses to add a second reservation if it detects an
existing `monitor = ..., addreserved, ...` rule in other local config files.

Revert: remove `source = ~/.config/hypr/topbar-clearance.conf` from
`~/.config/hypr/hyprland.conf` and run `hyprctl reload`.

**Note:** Explicitly floating windows can still be positioned by the user
wherever desired. The custom SnapZones script already respects compositor
reservations, so it should not double-apply the 60 px.
