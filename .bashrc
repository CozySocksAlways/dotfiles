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

## SSH STUFF ##

# Which GUI to use, and force it's use
export SSH_ASKPASS=/usr/lib/ssh/x11-ssh-askpass
export SSH_ASKPASS_REQUIRE=force

# Export the ssh agent vars
eval "$(ssh-agent -s)" &> /dev/null
