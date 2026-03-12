# ============================================================================
# ZSH CONFIGURATION
# ============================================================================
# 
# KEYBIND CHEATSHEET:
# -------------------
# Ctrl+F          - Accept autosuggestion
# Ctrl+U          - Delete from cursor to beginning of line
# Ctrl+Delete     - Delete word forward
# Ctrl+→          - Move forward one word
# Ctrl+←          - Move backward one word
# Home            - Move to beginning of line
# End             - Move to end of line
# Page Up         - Jump to beginning of history
# Page Down       - Jump to end of history
# Shift+Tab       - Undo last action
# Space           - History expansion
#
# ALIASES:
# --------
# Navigation:     .., ..., ...., ..... (go up 1-4 directories)
# Shortcuts:      dl (Downloads), doc (Documents), dt (Desktop)
# ls variants:    ll, la, lah, l
# git:            g (git shorthand)
# System:         reload (source ~/.zshrc), backup (system backup script)
# Tools:          installer (package script), icat (kitty image cat), snvim (sudo nvim)
# ============================================================================

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
export LC_ALL="en_US.UTF-8"
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:/opt/nvim/"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export NVM_DIR="$HOME/.config/nvm"

# ============================================================================
# OH MY ZSH CONFIGURATION
# ============================================================================
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ============================================================================
# CUSTOM PROMPT
# ============================================================================
# Disable conda/virtualenv prompt modification since we handle it ourselves
VIRTUAL_ENV_DISABLE_PROMPT=1

# Execution time tracking
preexec() {
    timer=$(($(date +%s%N)/1000000))
}

precmd() {
    local return_code=$?
    
    if [ -n "$timer" ]; then
        local now=$(($(date +%s%N)/1000000))
        local elapsed=$(($now-$timer))
        
        # Convert milliseconds to minutes and seconds
        local minutes=$((elapsed / 60000))
        local seconds=$(((elapsed % 60000) / 1000))
        local ms=$((elapsed % 1000))
        
        # Color code return code (green for 0, red for non-zero)
        if [ $return_code -eq 0 ]; then
            local code_color="\033[32m"
        else
            local code_color="\033[31m"
        fi
        
        # Only show if command took more than 1 second
        if [ $elapsed -gt 1000 ]; then
            if [ $minutes -gt 0 ]; then
                print -P "\033[34m󰁔\033[0m ${code_color}${return_code}\033[0m took ${minutes}m ${seconds}s"
            else
                print -P "\033[34m󰁔\033[0m ${code_color}${return_code}\033[0m took ${seconds}.$(printf "%03d" $ms)s"
            fi
        fi
        
        unset timer
    fi
    
    # Add newline before next prompt
    print ""
}

# Two-line prompt with time on first line
PROMPT=$'%F{cyan}╭──${VIRTUAL_ENV:+[$(basename $VIRTUAL_ENV)]─}[%B%F{red}%n%b%F{yellow}@%B%F{green}%m%b%F{cyan}][%B%F{blue}%25<…<%~%<<%b%F{cyan}]──[%B%F{magenta}%D{%Y/%m/%d}%b%F{cyan}][%B%F{yellow}%D{%H:%M:%S}%b%F{cyan}]\n%F{cyan}╰─%B%(#.%F{red}#.%F{green}▶)%b%F{reset} '
RPROMPT=''

# ============================================================================
# ZSH OPTIONS
# ============================================================================
zstyle ':omz:update' mode auto      # update automatically without asking
setopt autocd                       # change directory just by typing its name
setopt interactivecomments          # allow comments in interactive mode
setopt magicequalsubst              # enable filename expansion for arguments of the form 'anything=expression'
setopt nonomatch                    # hide error message if there is no match for the pattern
setopt notify                       # report the status of background jobs immediately
setopt numericglobsort              # sort filenames numerically when it makes sense
setopt promptsubst                  # enable command substitution in prompt

CASE_SENSITIVE="true"
WORDCHARS=${WORDCHARS//\/}          # Don't consider certain characters part of the word
PROMPT_EOL_MARK=""                  # hide EOL sign ('%')
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P' # configure `time` format

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================
HIST_STAMPS="yyyy-mm-dd"
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000

setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
alias history="history 0"     # force zsh to show the complete history

# ============================================================================
# KEY BINDINGS
# ============================================================================
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + →
bindkey '^[[1;5D' backward-word                   # ctrl + ←
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action
bindkey '^F' autosuggest-accept                   # ctrl + F (accept autosuggestion)

# ============================================================================
# COMPLETION SYSTEM
# ============================================================================
autoload -Uz compinit
compinit -d ~/.cache/zcompdump

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ============================================================================
# COLOR SUPPORT
# ============================================================================
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='lsd --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

    # More ls aliases
    alias ll='lsd -l'
    alias la='lsd -A'
    alias lah='lsd -lah'
    alias l='lsd -CF'
fi

# ============================================================================
# ALIASES
# ============================================================================

# Navigation shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Directory shortcuts
alias dl="cd ~/Downloads"
alias doc="cd ~/Documents"
alias dt="cd ~/Desktop"

# Tools and utilities
alias g="git"
alias reload="source ~/.zshrc"
alias backup="sudo /usr/local/bin/system-backup.sh"
alias installer="~/Scripts/packages.sh"
alias icat="kitty +kitten icat"
alias snvim="sudo nvim"

# ============================================================================
# PLUGINS & EXTENSIONS
# ============================================================================

# Download Znap, if it's not there yet.
[[ -r ~/zshRepos/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/zshRepos/znap
source ~/zshRepos/znap/znap.zsh  # Start Znap
znap source marlonrichert/zsh-autocomplete    # Autocomplete
znap source zsh-users/zsh-autosuggestions     # Autosuggestions
znap source zsh-users/zsh-syntax-highlighting # Highlighting

# Autosuggestion color (blue)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=blue'

# ============================================================================
# EXTERNAL TOOLS
# ============================================================================

# Python environment tools
if [[ -f ~/Scripts/py_env_tools.sh ]]; then
    source ~/Scripts/py_env_tools.sh
fi

# NVM (Node Version Manager)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# Dart CLI completion
[[ -f /home/kuroma/.config/.dart-cli-completion/zsh-config.zsh ]] && \
    . /home/kuroma/.config/.dart-cli-completion/zsh-config.zsh || true

# TheFuck (command correction)
if command -v thefuck &> /dev/null; then
    eval $(thefuck --alias)
fi

# ============================================================================
# WELCOME MESSAGE
# ============================================================================
if [[ "$TERM" == "xterm-kitty" ]]; then
    echo -e "\e[34m$(figlet -f ansi-shadow "Hi! $USER")\e[0m"  # Blue
    fastfetch
fi

# ============================================================================
# END OF CONFIGURATION
# ============================================================================
