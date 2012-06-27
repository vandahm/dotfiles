# OH-MY-ZSH

ZSH=${HOME}/.dotfiles/oh-my-zsh
ZSH_THEME="gentoo"
DISABLE_AUTO_UPDATE="true"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Don't write my history to disk
SAVEHIST=0
unset HISTFILE

# Also, don't share history between processes
unset SHARE_HISTORY


# CONVENIENT SHELL FUNCTIONS
source_if_exists()
{
    if [ -r $1 ]; then
        . $1 # IIRC, 'source' is weird under ksh
    fi
}

# I got the following three functions from Unix wizard Jeffery
# Neitzel (@v6shell) in 2003 and have used them ever since.

# Return 'true' if $1 is missing from $2 (or PATH)
_nopath()
{
    # Based on jneitzel's function
    eval _v="\$${2:-PATH}"
    case :$_v: in
        *:$1:*) return 1 ;; # no we have it
    esac
    return 0
}

prepend_to_path()
{
    # Based on jneitzel's function
    [ -d ${1:-.} ] && _nopath $* && eval ${2:-PATH}="$1:\$${2:-PATH}"
    export PATH
}

remove_from_path()
{
    # Based on jneitzel's function
    _nopath $* || eval ${2:-PATH}=`eval echo :'$'${2:-PATH}: |
        sed -e "s,:$1:,:,g" -e "s,^:,," -e "s,:\$,,"`
    export PATH
}

# This is a blank function that eliminates the need to have case
# statements everywhere.

restore_default_xterm_title()
{
    return
}

# Vim isn't always installed, but vi should exist everywhere.
if which vim 2>&1 1>/dev/null; then
    export EDITOR=`which vim`
else
    export EDITOR=`which vi`
fi
export VISUAL=$EDITOR

if [ "$COLORTERM" = 'gnome-terminal' ]; then
    TERM=xterm-color
    export TERM
fi

case "$TERM" in
    *xterm*)
        source_if_exists ${HOME}/.dotfiles/xterm-functions
        ;;
esac

# Source my aliases from another file.
source_if_exists ${HOME}/.dotfiles/shell-aliases

if [ `uname` = Darwin ] && [ -d /usr/local/php5/bin ]; then
    prepend_to_path /usr/local/php5/bin
fi

# Homebrew on Macs
if [ `uname` = Darwin ] && [ -x /usr/local/bin/brew ]; then
    remove_from_path /usr/local/bin
    remove_from_path /usr/local/sbin
    prepend_to_path /usr/local/sbin
    prepend_to_path /usr/local/bin
    prepend_to_path /usr/local/share/python
    export NODE_PATH=/usr/local/lib/node_modules
fi

# TeX on Macs
prepend_to_path /usr/local/texlive/2011/bin/x86_64-darwin

# Custom scripts
prepend_to_path ${HOME}/Library/UnixUtils # OS X
prepend_to_path ${HOME}/bin               # Regular Unix

# Ruby Stuff
if [ -d ${HOME}/.rbenv ]; then
    prepend_to_path ${HOME}/.rbenv/bin
    eval "$(rbenv init -)"
fi

# Prevent jackasses on multiuser systems from catting /dev/urandom to my TTY
mesg n

# Perform any machine-specific config tasks
source_if_exists ${HOME}/.zshrc-local

# Set xterm window title, if appropriate.
restore_default_xterm_title
