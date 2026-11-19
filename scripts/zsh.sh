#!/usr/bin/env bash
# Install oh-my-zsh, powerlevel10k and plugins, and make zsh the login shell.
# The .zshrc / .p10k.zsh themselves are symlinked by stow (zsh package).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    info "oh-my-zsh already installed."
else
    info "Installing oh-my-zsh (unattended, keeping .zshrc)..."
    # RUNZSH=no + --unattended stops the installer from launching a new shell,
    # which used to stop the old install_all.sh halfway through.
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_once https://github.com/romkatv/powerlevel10k.git          "$ZSH_CUSTOM/themes/powerlevel10k"
clone_once https://github.com/zsh-users/zsh-autosuggestions        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_once https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_once https://github.com/chrissicool/zsh-256color             "$ZSH_CUSTOM/plugins/zsh-256color"

# oh-my-zsh may have written a default .zshrc; stow needs that path free.
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]] && grep -q 'oh-my-zsh.sh' "$HOME/.zshrc" \
   && ! grep -q 'powerlevel10k/powerlevel10k' "$HOME/.zshrc"; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.omz-default"
fi

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
    info "Setting zsh as default shell..."
    # usermod (shadow-utils) is always installed; chsh needs util-linux-user.
    sudo usermod --shell "$(command -v zsh)" "$USER"
fi
