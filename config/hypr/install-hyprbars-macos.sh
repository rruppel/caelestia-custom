#!/usr/bin/env bash
set -euo pipefail

repo="${HOME}/.config/quickshell/caelestia"
src="${repo}/config/hypr/hyprbars-macos.conf"
target_dir="${HOME}/.config/hypr"
target="${target_dir}/hyprbars-macos.conf"
main="${target_dir}/hyprland.conf"
source_line="source = ~/.config/hypr/hyprbars-macos.conf"

[[ -f "$src" ]] || { echo "Missing repo config: $src" >&2; exit 1; }
[[ -f "$main" ]] || { echo "Missing Hyprland config: $main" >&2; exit 1; }

if grep -Eq '^[[:space:]]*(bar_height|hyprbars-button|bar_buttons_alignment)[[:space:]]*=' "$main"; then
  echo "Existing Hyprbars settings found in $main; review before installing." >&2
  exit 1
fi

if [[ -e "$target" && ! -L "$target" ]]; then
  echo "Refusing to replace existing $target" >&2
  exit 1
fi

if [[ -L "$target" && "$(readlink -f "$target")" != "$(readlink -f "$src")" ]]; then
  echo "Refusing to replace symlink with different target: $target" >&2
  exit 1
fi

mkdir -p "$target_dir"
ln -sfn "$src" "$target"

if ! grep -Fqx "$source_line" "$main"; then
  backup="$main.backup-before-macos-hyprbars.$(date +%Y%m%d-%H%M%S)"
  cp -p "$main" "$backup"
  printf '\n# Custom versioned Mac-style titlebar\n%s\n' "$source_line" >> "$main"
  echo "Backup saved: $backup"
else
  echo "Source already present; not adding twice."
fi

hyprctl reload
echo "Hyprbars macOS style loaded. Dragging and SnapZones bindings unchanged."
