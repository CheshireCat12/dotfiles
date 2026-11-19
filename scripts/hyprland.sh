#!/usr/bin/env bash
# Install Hyprland + the Wayland desktop pieces from the lionheartp/Hyprland COPR
# (the repo the official Hyprland wiki recommends for Fedora).
#
# The configs in this repo need Hyprland >= 0.55 (Lua config) and hyprpaper >= 0.8,
# which this COPR provides for Fedora 44 and newer.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

COPR=lionheartp/Hyprland
OLD_COPRS=(solopasha/hyprland sdegler/hyprland)
MIN_FEDORA=44

FEDORA_VER="$(rpm -E %fedora)"
if (( FEDORA_VER < MIN_FEDORA )); then
    error "Fedora $FEDORA_VER is not supported by the $COPR COPR (needs Fedora $MIN_FEDORA+)."
    error "Upgrade Fedora first, for example:"
    error "  sudo dnf upgrade --refresh && sudo dnf system-upgrade download --releasever=$MIN_FEDORA && sudo dnf offline reboot"
    exit 1
fi

# Several Hyprland COPRs ship the same package names; keep only one enabled
# so packages don't get mixed between repos.
for old in "${OLD_COPRS[@]}"; do
    if dnf copr list 2>/dev/null | grep -v -i disabled | grep -qiF "$old"; then
        info "Disabling old COPR $old..."
        sudo dnf copr disable -y "$old"
    fi
done

info "Enabling COPR $COPR..."
sudo dnf copr enable -y "$COPR"

# Compositor + portals + Hypr ecosystem (from the COPR)
HYPR_PKGS=(
    hyprland
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    hyprpolkitagent hyprland-guiutils hyprland-qt-support
    hyprpaper hypridle hyprlock hyprshot hyprpicker hyprshutdown
)

# Desktop tools used by the configs (Fedora repos)
DESKTOP_PKGS=(
    waybar wofi SwayNotificationCenter
    blueman network-manager-applet
    pipewire wireplumber helvum brightnessctl playerctl
    grim slurp wl-clipboard jq libnotify
    qt5-qtwayland qt6-qtwayland
    nautilus
)

info "Installing Hyprland and the Wayland desktop..."
sudo dnf install -y "${HYPR_PKGS[@]}" "${DESKTOP_PKGS[@]}"

# Pull already-installed packages (e.g. from an older COPR) up to the new COPR's versions.
sudo dnf upgrade -y --refresh "${HYPR_PKGS[@]}"

# A login screen that lists the Hyprland session. Fedora Workstation already has GDM;
# minimal/Everything installs get SDDM.
if systemctl is-enabled -q display-manager.service 2>/dev/null; then
    info "Display manager already enabled: $(basename "$(readlink -f /etc/systemd/system/display-manager.service)")"
else
    info "No display manager found, installing SDDM..."
    sudo dnf install -y sddm
    sudo systemctl enable sddm.service
    sudo systemctl set-default graphical.target
fi

info "Hyprland $(rpm -q --qf '%{VERSION}' hyprland) installed. Choose 'Hyprland' on the login screen."
