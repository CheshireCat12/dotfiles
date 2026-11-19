# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME='powerlevel10k/powerlevel10k'

# List of plugins used
plugins=( git sudo zsh-256color zsh-autosuggestions zsh-syntax-highlighting )
source $ZSH/oh-my-zsh.sh

# Helpful aliases
alias cat='bat'
alias  c='clear' # clear terminal
alias ld='eza -lhD --icons=auto' # long list dirs
alias  l='eza -lh  --icons=auto' # long list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ls='eza -1   --icons=auto' # short list
alias lt='eza --icons=auto --tree' # list folder as tree
alias vim='nvim'

export MANPAGER='nvim +Man!'

# Handy change dir shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

# change the xterm when using ssh
alias ssh='TERM=xterm-256color ssh'

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion stylinJ
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# Just remind me to update when it's time
zstyle ':omz:update' mode reminder

# Keybindings
# All Keybindings after this line
bindkey -v
# export KEYTIMEOUT=1
bindkey '^k' history-search-backward
bindkey '^j' history-search-forward
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

# Config zsh-autosuggestions
bindkey '\t\t' autosuggest-accept

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# append
path+=('/snap/bin')
# and don't forget to export to make it inherited by child processes
export PATH
export PATH="$HOME/.local/bin:$PATH"
