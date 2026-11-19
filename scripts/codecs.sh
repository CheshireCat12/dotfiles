#!/usr/bin/env bash
# Multimedia codecs and hardware video decoding.
# Usage: codecs.sh [intel|amd|none] [--nvidia]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

GPU="${1:-intel}"
NVIDIA="${2:-}"

info "Installing multimedia codecs..."
sudo dnf group install -y multimedia
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf upgrade -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf group install -y sound-and-video

info "Installing VA-API..."
sudo dnf install -y ffmpeg-libs libva libva-utils

case "$GPU" in
    intel)
        info "Intel (5th gen+) VA-API drivers..."
        sudo dnf swap -y libva-intel-media-driver intel-media-driver --allowerasing
        sudo dnf install -y libva-intel-driver
        ;;
    amd)
        # Fedora 43+ ships VA-API inside mesa-dri-drivers and dropped VDPAU, so the
        # freeworld driver (H.264/H.265 enabled) is installed alongside, not swapped.
        info "AMD freeworld Mesa VA-API driver..."
        sudo dnf install -y mesa-va-drivers-freeworld
        sudo dnf install -y mesa-va-drivers-freeworld.i686 || warn "No 32-bit freeworld driver, skipping."
        ;;
    none) info "Skipping GPU-specific drivers." ;;
    *) error "Unknown GPU '$GPU' (expected intel|amd|none)"; exit 1 ;;
esac

if [[ "$NVIDIA" == "--nvidia" ]]; then
    info "Installing Nvidia driver..."
    sudo dnf install -y akmod-nvidia
fi

info "Enabling OpenH264 for Firefox..."
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
