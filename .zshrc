# ==============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# ==============================================================================


# ==============================================================================
# ======================   General zsh config   ================================
# ==============================================================================

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="powerlevel10k/powerlevel10k"

# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh


# ==============================================================================
# ======================   User zsh config   ===================================
# ==============================================================================

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
[ ! -f "$HOME/.cache/zsh/history" ] && touch "$HOME/.cache/zsh/history" \
    && echo "History file not found. Creating one..."
HISTFILE=~/.cache/zsh/history
export HISTCONTROL=ignoredups
setopt nosharehistory

export VISUAL=vim
export EDITOR="$VISUAL"
export VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/kosmos"

# Use neovim for vim and vi if present.
[ -x "$(command -v nvim)" ] && alias "vi=nvim" vim="nvim" vimdiff="nvim -d"

# Completion
#bind 'set completion-ignore-case on'
#bind "set show-all-if-ambiguous on"
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'


# Remember ssh login passwords for current session
#eval $(keychain --eval /home/$USER/.ssh/id_rsa 2> /dev/null)
eval $(ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519 2> /dev/null)

# Paths
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/Library/Python/3.9/bin
export PATH=$PATH:$HOME/.dotfiles/scripts
export PYTHONPATH=$HOME/Projects/Peano/code/python
export PYTHONPATH=/usr/lib64/paraview/python3.10/site-packages:$PYTHONPATH  # paraview libs location
export PYTHONPATH=/usr/lib64/python3.10/site-packages:$PYTHONPATH           # Jinja2 location
export PYTHONPATH=/usr/lib/python3.10/site-packages:$PYTHONPATH             # Jinja2 location
export PYTHONPATH=$HOME/Projects/GR-effects-clusters:$PYTHONPATH            # Custom project folder
export JUPYTER_PATH=$HOME/Codes/Peano/python

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
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/.aliasrc"

#
# --------------------------------------------
# Load functions
# --------------------------------------------

[ -f "$HOME/.bash_functions" ] && source "$HOME/.bash_functions"

# --------------------------------------------
# Key bindings
# --------------------------------------------

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

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


# --------------------------------------------
# >>> conda initialize >>>
# --------------------------------------------
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/etc/profile.d/conda.sh" ]; then
        . "/usr/etc/profile.d/conda.sh"
    else
        export PATH="/usr/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

#source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme
source /opt/homebrew/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme
# ==============================================================================
# Load zsh-syntax-highlighting; should be last.
# Linux
#source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
#source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# macos brew installations
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# ==============================================================================
# Auto accept key
bindkey '^ ' autosuggest-accept

# ==============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# ==============================================================================

# ==============================================================================
# Enable zoxide for zshell and alias to cd
eval "$(zoxide init --cmd cd zsh)"
# ==============================================================================
