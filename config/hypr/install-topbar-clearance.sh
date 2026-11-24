#!/usr/bin/env bash
set -euo pipefail

repo="${HOME}/.config/quickshell/caelestia"
src="${repo}/config/hypr/topbar-clearance.conf"
target_dir="${HOME}/.config/hypr"
target="${target_dir}/topbar-clearance.conf"
main="${target_dir}/hyprland.conf"
source_line="source = ~/.config/hypr/topbar-clearance.conf"

[[ -f "$src" ]] || { echo "Missing source file: $src" >&2; exit 1; }
[[ -f "$main" ]] || { echo "Missing Hyprland config: $main" >&2; exit 1; }

if [[ -e "$target" && ! -L "$target" ]]; then
  echo "Refusing to overwrite an existing file: $target" >&2
  exit 1
fi
if [[ -L "$target" && "$(readlink -f "$target")" != "$(readlink -f "$src")" ]]; then
  echo "Refusing to replace a symlink pointing elsewhere: $target" >&2
  exit 1
fi

# An existing reservation could stack with this one; do not install blindly.
if ! grep -Fqx "$source_line" "$main"; then
  if grep -REq '^[[:space:]]*monitor[[:space:]]*=[^#]*,[[:space:]]*addreserved[[:space:]]*,' "$target_dir" \
    --include='*.conf' --exclude='topbar-clearance.conf' 2>/dev/null; then
    echo "Existing monitor addreserved rule found under $target_dir." >&2
    echo "Review it before enabling a second reservation." >&2
    exit 1
  fi
fi

mkdir -p "$target_dir"
ln -sfn "$src" "$target"
if ! grep -Fqx "$source_line" "$main"; then
  backup="$main.backup-before-topbar-clearance.$(date +%Y%m%d-%H%M%S)"
  cp -p "$main" "$backup"
  printf '\n# Leave space above tiled windows for the floating Caelestia bar\n%s\n' "$source_line" >> "$main"
  echo "Backup saved: $backup"
else
  echo "TopBar clearance source is already installed."
fi

hyprctl reload
echo "Loaded TopBar clearance: 60px at top. Hyprbars and SnapZones unchanged."
