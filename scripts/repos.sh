#!/usr/bin/env bash
# Enable extra repositories: RPM Fusion, Terra, Flathub and the preload COPR.
# (The Hyprland COPR is enabled by scripts/hyprland.sh.)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

info "Tuning dnf..."
append_once 'fastestmirror=True' /etc/dnf/dnf.conf
append_once 'max_parallel_downloads=10' /etc/dnf/dnf.conf

info "Adding RPM Fusion (free + nonfree)..."
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

info "Adding Terra..."
if ! rpm -q terra-release &>/dev/null; then
    sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
fi

info "Adding Flathub..."
command -v flatpak >/dev/null || sudo dnf install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

info "Enabling the preload COPR..."
sudo dnf copr enable -y kylegospo/preload
