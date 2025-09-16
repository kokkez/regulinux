# ~/.bashrc

case $- in
    *i*) ;;
      *) return;;
esac

## history
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend
shopt -s cmdhist
PROMPT_COMMAND='history -a'

## terminal
shopt -s checkwinsize
shopt -s extglob
shopt -s globstar

## prompt
if [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
    PS1='\[\e[1;32m\]\u@\h \[\e[1;34m\]\w\[\e[0m\] \$ '
else
    PS1='\u@\h \w \$ '
fi
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        ;;
esac
export TERM=xterm-256color

## colors
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
    alias ls='ls --color=auto'
fi

## safer coreutils
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

## regulinux shortcut
os() { bash "$(find ~/r* -name os.* -print -quit)" "$@"; }

## readline
bind 'set enable-bracketed-paste off'

