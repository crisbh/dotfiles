# ==============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Integrate brew and shell in macOS
if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

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
eval $(ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519 2> /dev/null)

# Set various PATHs
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:/opt/anaconda3/bin
#export PATH=$PATH:$HOME/Library/Python/3.9/bin
export PATH=$PATH:$HOME/.dotfiles/scripts
export PYTHONPATH=$HOME/Projects/Peano/code/python
export PYTHONPATH=/usr/lib64/paraview/python3.10/site-packages:$PYTHONPATH  # paraview libs location
export PYTHONPATH=/usr/lib64/python3.10/site-packages:$PYTHONPATH           # Jinja2 location
export PYTHONPATH=/usr/lib/python3.10/site-packages:$PYTHONPATH             # Jinja2 location
export PYTHONPATH=$HOME/Projects/GR-effects-clusters:$PYTHONPATH            # Custom project folder
export JUPYTER_PATH=$HOME/Codes/Peano/python

# Hide the default go folder in home
export GOPATH=$HOME/.go

export LDFLAGS="-L/opt/homebrew/opt/libomp/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libomp/include"

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
eval "$(fzf --zsh)"
# Enable zoxide for zshell and alias to cd
eval "$(zoxide init --cmd cd zsh)"
# ==============================================================================

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

