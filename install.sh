#!/usr/bin/env bash
# Fedora + Hyprland setup: repos, packages, codecs, zsh, icons, and dotfiles (via GNU stow).
#
# Usage: ./install.sh [options] [steps...]
#
# Steps (run in this order; default = all):
#   repos     RPM Fusion, Terra, Flathub, COPRs, dnf tuning
#   packages  base CLI tools, kitty, neovim, firefox
#   hyprland  Hyprland + Wayland desktop from the lionheartp/Hyprland COPR (Fedora 44+)
#   codecs    multimedia codecs + hardware video decoding
#   zsh       oh-my-zsh, powerlevel10k, plugins, default shell
#   icons     Flat-Remix-Blue-Dark icon theme
#   stow      symlink every config package into $HOME
#
# Options:
#   --gpu intel|amd|none   GPU video drivers to install (default: intel)
#   --nvidia               also install the Nvidia driver
#   -h, --help             show this help
#
# Examples:
#   ./install.sh                      # everything, Intel GPU
#   ./install.sh --gpu amd            # everything, AMD GPU
#   ./install.sh stow                 # only (re)link the dotfiles
#   ./scripts/stow.sh nvim kitty      # link only some packages
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR
source "$DOTFILES_DIR/scripts/lib.sh"

ALL_STEPS=(repos packages hyprland codecs zsh icons stow)
GPU=intel
NVIDIA=""
STEPS=()

usage() { sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        --gpu) GPU="${2:?--gpu needs a value}"; shift 2 ;;
        --nvidia) NVIDIA=--nvidia; shift ;;
        -h|--help) usage; exit 0 ;;
        -*) error "Unknown option: $1"; usage; exit 1 ;;
        *) STEPS+=("$1"); shift ;;
    esac
done
[[ ${#STEPS[@]} -eq 0 ]] && STEPS=("${ALL_STEPS[@]}")

for step in "${STEPS[@]}"; do
    if [[ " ${ALL_STEPS[*]} " != *" $step "* ]]; then
        error "Unknown step: $step"; usage; exit 1
    fi
done

if [[ $EUID -eq 0 ]]; then
    error "Run as your normal user, not root (sudo is used where needed)."
    exit 1
fi

if [[ "$DOTFILES_DIR" == /tmp/* ]]; then
    warn "This repo is in /tmp: the stow symlinks will break when /tmp is cleared."
    warn "Clone it somewhere permanent, e.g. ~/.dotfiles."
fi

if [[ " ${STEPS[*]} " == *" hyprland "* ]] && (( $(rpm -E %fedora) < 44 )); then
    error "The hyprland step needs Fedora 44+ (you have Fedora $(rpm -E %fedora))."
    error "Upgrade Fedora first, or skip it: ./install.sh repos packages codecs zsh icons stow"
    exit 1
fi

# Ask for the sudo password once up front.
sudo -v

for step in "${STEPS[@]}"; do
    info "===== $step ====="
    case "$step" in
        repos)    bash "$DOTFILES_DIR/scripts/repos.sh" ;;
        packages) bash "$DOTFILES_DIR/scripts/packages.sh" ;;
        hyprland) bash "$DOTFILES_DIR/scripts/hyprland.sh" ;;
        codecs)   bash "$DOTFILES_DIR/scripts/codecs.sh" "$GPU" "$NVIDIA" ;;
        zsh)      bash "$DOTFILES_DIR/scripts/zsh.sh" ;;
        icons)    bash "$DOTFILES_DIR/scripts/icons.sh" ;;
        stow)     bash "$DOTFILES_DIR/scripts/stow.sh" ;;
        *) error "Unknown step: $step"; usage; exit 1 ;;
    esac
done

info "Done. Log out and back in (or reboot) to start using zsh and Hyprland."
info "Remember to enable the OpenH264 plugin in Firefox's settings."
