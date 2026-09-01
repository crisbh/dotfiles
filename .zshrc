# ==============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# OS detection + Homebrew integration (portable across Apple Silicon macOS,
# Intel macOS, and Linux). BREW_PREFIX is empty when brew is absent (e.g. Fedora
# with native dnf); dependent paths below are guarded on it.
case "$OSTYPE" in
  darwin*) export DOTFILES_OS=macos ;;
  *)       export DOTFILES_OS=linux ;;
esac
export DOTFILES="$HOME/.dotfiles"
for _brew in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if [[ -x "$_brew/bin/brew" ]]; then
    export BREW_PREFIX="$_brew"
    eval "$("$_brew/bin/brew" shellenv)"
    break
  fi
done
unset _brew

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if not present
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
#zinit snippet OMZP::archlinux
#zinit snippet OMZP::aws
#zinit snippet OMZP::kubectl
#zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Completion
#bind 'set completion-ignore-case on'
#bind "set show-all-if-ambiguous on"
autoload -Uz compinit && compinit
#autoload -U compinit
#zstyle ':completion:*' menu select
#zmodload zsh/complist
#compinit
#_comp_options+=(globdots)		# Include hidden files.

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

zinit cdreplay -q

# ==============================================================================
# ======================   User zsh config   ===================================
# ==============================================================================
export VISUAL=vim
export EDITOR="$VISUAL"

# Set location of Vault with notes
if [[ $OSTYPE == *"darwin"* ]]; then
    export VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/kosmos"
else
    VAULT="$HOME/notes"
    [[ ! -d $VAULT ]] && mkdir "$VAULT"
    export VAULT
fi

# Use neovim for vim and vi if present.
if [[ -x "$(command -v nvim)" ]]; then
  alias "vi=nvim" vim="nvim" vimdiff="nvim -d"
  export EDITOR="nvim"
fi

# History in cache directory:
HISTSIZE=10000
SAVEHIST=$HISTSIZE
[ ! -f "$HOME/.cache/zsh/history" ] && touch "$HOME/.cache/zsh/history" \
    && echo "History file not found. Creating one..."
HISTFILE=~/.cache/zsh/history
HISTDUP=erase
export HISTCONTROL=ignoredups
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Keybindings
#bindkey -e  # emacs keybiding, if desired
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region


# Remember ssh login passwords for current session
# --apple-use-keychain is macOS-only; Linux ssh-add rejects it.
if [[ $DOTFILES_OS == macos ]]; then
  eval $(ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519 2> /dev/null)
else
  eval $(ssh-add $HOME/.ssh/id_ed25519 2> /dev/null)
fi

# Set various PATHs (brew's bin is already on PATH via `brew shellenv` above)
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.dotfiles/scripts

# Hide the default go folder in home
export GOPATH=$HOME/.go

# libomp flags for OpenMP builds (Homebrew keg — macOS only)
if [[ -n $BREW_PREFIX && -d "$BREW_PREFIX/opt/libomp" ]]; then
  export LDFLAGS="-L$BREW_PREFIX/opt/libomp/lib"
  export CPPFLAGS="-I$BREW_PREFIX/opt/libomp/include"
fi

# Path to cd quicker between frequent directories
export CDPATH=$HOME
export CDPATH=$CDPATH:$HOME/.config/
export CDPATH=$CDPATH:$HOME/Dropbox
export CDPATH=$CDPATH:$HOME/Projects

# Colouring man
export MANPAGER="less -R --use-color -Dd+g -Du+b"

# --------------------------------------------
# Aliases
# --------------------------------------------

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/.shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/.aliasrc" ] && source "$HOME/.config/.aliasrc"

# --------------------------------------------
# Load custom functions
# --------------------------------------------
[ -f "$HOME/.bash_functions" ] && source "$HOME/.bash_functions"

# --------------------------------------------
# Key bindings
# --------------------------------------------

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
#bindkey -M menuselect 'h' vi-backward-char
#bindkey -M menuselect 'k' vi-up-line-or-history
#bindkey -M menuselect 'l' vi-forward-char
#bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Auto accept key
bindkey '^ ' autosuggest-accept

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
zle-line-init() {
    zle -K viins                 # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q'                # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# ==============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# ==============================================================================

# ==============================================================================
## Shell integrations
# ==============================================================================

alias python=python3
alias pip=pip3

# Pin node@22 from Homebrew when present (macOS); on Linux node comes from dnf.
if [[ -n $BREW_PREFIX && -d "$BREW_PREFIX/opt/node@22/bin" ]]; then
  export PATH="$BREW_PREFIX/opt/node@22/bin:$PATH"
fi

# fzf shell integration (completion + key bindings, portable)
eval "$(fzf --zsh)"
# Trigger sequence for fuzzy completion (instead of the default **)
export FZF_COMPLETION_TRIGGER='ff'
# Open fzf selections directly in neovim
alias ffvim="fzf --multi --bind 'enter:become(nvim {})'"
# Use fd instead of find for path/dir completion candidates
_fzf_compgen_path() { fd --hidden --follow --exclude ".git" . "$1"; }
_fzf_compgen_dir()  { fd --type d --hidden --follow --exclude ".git" . "$1"; }

# Enable zoxide for zshell and alias to cd
eval "$(zoxide init --cmd cd zsh)"
# ==============================================================================

