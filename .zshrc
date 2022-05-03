
export VISUAL=vim
export EDITOR="$VISUAL"
export PATH=$PATH:/usr/lib64/openmpi/bin
#stty -ixon

# Use neovim for vim if present.
[ -x "$(command -v nvim)" ] && alias vim="nvim" vimdiff="nvim -d"

# Set case-Insensitive completion
#bind 'set completion-ignore-case on'
#bind "set show-all-if-ambiguous on"

# PIP suggestion
PATH=$PATH:$HOME/.local/bin

# Peano/Exahype Python path
export PYTHONPATH=$HOME/Codes/Peano/python/
export PYTHONPATH=/usr/lib64/paraview/python3.10/site-packages:$PYTHONPATH  # paraview libs location
export PYTHONPATH=/usr/lib64/python3.10/site-packages:$PYTHONPATH           # Jinja2 location
export JUPYTER_PATH=$HOME/Codes/Peano/python

# Define Aliases
# Verbosity and settings that you pretty much just always are going to want.
alias \
	cp="cp -iv" \
	mv="mv -iv" \
	rm="rm -vI" \
	bc="bc -ql" \
	mkd="mkdir -pv" \
	yt="youtube-dl --add-metadata -i" \
	yta="yt -x -f bestaudio/best" \
	ffmpeg="ffmpeg -hide_banner"

# Colorize commands when possible.
alias \
	ls="ls -hN --color=auto --group-directories-first" \
	ltr="ls -ltr -hN --color=auto --group-directories-first" \
    sl="ls" \
	grep="grep --color=auto" \
	diff="diff --color=auto" \
	ccat="highlight --out-format=ansi"
    
# Weather in terminal
alias weather='curl wttr.in'
alias dush='du -shc --apparent-size'

# Visualise peano grid
alias renderpeanogrid='pvpython ~/Codes/Peano/python/peano4/visualisation/render.py grid.peano-patch-file'

# dotfiles git repo
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME"

# jupyter notebooks
alias jn='jupyter-notebook'
# Remote connection to jupyter
alias jtunnel='ssh -N -L localhost:8444:localhost:8444 dc-barr3@cosma7c'
alias jnham8='ssh -N -L localhost:8555:localhost:8555 hgcq36@ham8'

###############################################

# Luke's config for the Zoomer Shell

# Enable colors and change prompt:
autoload -U colors && colors
#PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
PS1="%B%{$fg[red]%}[%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history   # Note: this file has to be manually created

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

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
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

# dwm status bar config files
export PATH=$HOME/.config/statusbar/:$PATH

# Auto accept key
bindkey '^ ' autosuggest-accept

# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Fix history
setopt nosharehistory

# Prompt Git integration
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git

