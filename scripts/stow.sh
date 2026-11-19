#!/usr/bin/env bash
# Symlink the stow packages into $HOME.
# Usage: stow.sh [package...]   (default: every package directory)
# Existing real files that would conflict are moved to ~/.dotfiles_backup/<date>/.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

command -v stow >/dev/null || { error "GNU stow is not installed (sudo dnf install stow)"; exit 1; }

NON_PACKAGES=(scripts docs)

if [[ $# -gt 0 ]]; then
    PACKAGES=("$@")
else
    PACKAGES=()
    for dir in "$DOTFILES_DIR"/*/; do
        name="$(basename "$dir")"
        [[ " ${NON_PACKAGES[*]} " == *" $name "* ]] && continue
        PACKAGES+=("$name")
    done
fi

BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

# The hypr* packages use Lua-era syntax (Hyprland >= 0.55, hyprpaper >= 0.8).
# Don't link them over an older install that can't read them.
NEW_HYPR_PKGS=(hyprland hypridle hyprpaper)
version_ge() { [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" == "$2" ]]; }
hypr_too_old() {
    local v
    v="$(rpm -q --qf '%{VERSION}' hyprland 2>/dev/null)" || return 1  # not installed: link anyway
    ! version_ge "$v" 0.55
}
if hypr_too_old && [[ "${FORCE_HYPR:-0}" != 1 ]]; then
    kept=()
    for pkg in "${PACKAGES[@]}"; do
        if [[ " ${NEW_HYPR_PKGS[*]} " == *" $pkg "* ]]; then
            warn "Skipping $pkg: installed Hyprland $(rpm -q --qf '%{VERSION}' hyprland) is older than 0.55."
            warn "  Run ./install.sh hyprland first (or FORCE_HYPR=1 to link anyway)."
        else
            kept+=("$pkg")
        fi
    done
    PACKAGES=("${kept[@]}")
fi

# Remove symlinks left behind by files that were deleted or renamed in this repo
# (e.g. the old ~/.config/hypr/hyprland.conf).
while IFS= read -r -d '' link; do
    if [[ "$(readlink -m "$link")" == "$DOTFILES_DIR"/* ]]; then
        warn "Removing stale link $link"
        rm "$link"
    fi
done < <(find "$HOME" -maxdepth 1 -xtype l -print0; find "$HOME/.config" "$HOME/.local/share" -maxdepth 3 -xtype l -print0 2>/dev/null)

backup_conflicts() {
    local pkg="$1" rel target
    while IFS= read -r -d '' file; do
        rel="${file#"$DOTFILES_DIR/$pkg/"}"
        target="$HOME/$rel"
        if [[ -e "$target" && ! -L "$target" ]]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
            mv "$target" "$BACKUP_DIR/$rel"
            warn "Backed up $target -> $BACKUP_DIR/$rel"
        fi
    done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)
}

for pkg in "${PACKAGES[@]}"; do
    [[ -d "$DOTFILES_DIR/$pkg" ]] || { warn "No package named '$pkg', skipping."; continue; }
    info "Stowing $pkg"
    backup_conflicts "$pkg"
    # --no-folding: link files, not whole dirs, so ~/.config/hypr can hold
    # files from several packages (hyprland, hyprlock, hypridle, hyprpaper).
    stow --no-folding --restow -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
done

if [[ " ${PACKAGES[*]} " == *" fonts "* ]] && command -v fc-cache >/dev/null; then
    info "Refreshing font cache..."
    fc-cache -f >/dev/null
fi
