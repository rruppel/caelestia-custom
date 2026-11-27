#!/usr/bin/env bash
set -euo pipefail
src="$HOME/.config/quickshell/caelestia/config/systemd"
dest="$HOME/.config/systemd/user"
mkdir -p "$dest"
for name in caelestia-wallpaper.service caelestia-wallpaper.timer; do
  target="$dest/$name"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$(readlink -f "$target")" != "$(readlink -f "$src/$name")" ]]; then
      backup="$target.backup.$(date +%Y%m%d-%H%M%S)"
      cp -L "$target" "$backup"
      echo "Preserved previous $name at $backup"
    fi
  fi
  ln -sfn "$src/$name" "$target"
done
systemctl --user daemon-reload
systemctl --user enable --now caelestia-wallpaper.timer
echo "Alphabetical wallpaper rotation installed (every 30 minutes)."
echo "TopBar right-click controls pause/resume. Left-click advances and resumes."
