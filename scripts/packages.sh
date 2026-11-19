#!/usr/bin/env bash
# Install the packages the configs in this repo depend on.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BASE_PKGS=(
    git stow curl wget zip unzip gcc cmake make npm
    zsh vim neovim kitty bat eza ripgrep fd-find
    firefox btop fastfetch flatpak
)
# gnome-tweaks requires gnome-shell (and so GDM + most of GNOME): only add it
# when GNOME is already installed, e.g. on Fedora Workstation.
rpm -q gnome-shell &>/dev/null && BASE_PKGS+=(gnome-tweaks)
# Hyprland and the desktop tools are installed by scripts/hyprland.sh.

info "Installing base packages..."
sudo dnf install -y "${BASE_PKGS[@]}"

info "Installing and enabling preload..."
sudo dnf install -y preload
sudo systemctl enable --now preload
