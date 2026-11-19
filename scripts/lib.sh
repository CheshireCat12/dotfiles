#!/usr/bin/env bash
# Shared helpers sourced by install.sh and the scripts in scripts/.

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

# Append a line to a root-owned file only if it is not already there.
append_once() {
    local line="$1" file="$2"
    sudo grep -qxF "$line" "$file" 2>/dev/null || echo "$line" | sudo tee -a "$file" >/dev/null
}

# Clone a git repo only if the destination does not exist yet.
clone_once() {
    local url="$1" dest="$2"
    if [[ -d "$dest" ]]; then
        info "Already present: $dest"
    else
        git clone --depth=1 "$url" "$dest"
    fi
}
