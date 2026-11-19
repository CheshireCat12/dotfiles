#!/usr/bin/env bash
# Install the Flat-Remix-Blue-Dark icon theme (used by waybar/wofi).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if [[ -d "$HOME/.icons/Flat-Remix-Blue-Dark" ]]; then
    info "Flat-Remix-Blue-Dark icons already installed."
else
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    info "Downloading icon theme..."
    git clone --depth=1 https://github.com/JaKooLit/GTK-themes-icons.git "$tmp/GTK-themes-icons"
    mkdir -p "$HOME/.icons"
    unzip -o -q "$tmp/GTK-themes-icons/icon/Flat-Remix-Blue-Dark.zip" -d "$HOME/.icons"
fi

if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface icon-theme Flat-Remix-Blue-Dark || true
fi
