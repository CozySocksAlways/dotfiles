#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Load custom aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Load personal aliases
if [ -f ~/.personal_alias ]; then
    . ~/.personal_alias
fi

# Update promt
PS1='\[\e[32m\]\W>\[\e[0m\] '

# Add local binaries to path
export PATH="$HOME/.local/bin:$PATH"

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
