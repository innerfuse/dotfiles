
SH=1

# run bash_profile if this is not a login shell
[ -z "$LOGIN_BASH" ] && source ~/.bash_profile

# load shared shell configuration
source ~/.shrc

# History
export HISTFILE="$HOME/.bash_history"
export HISTCONTROL="ignoredups"
export PROMPT_COMMAND="history -a"
export HISTIGNORE="&:ls:[bf]g:exit"

# enable direnv (if installed)
which direnv &>/dev/null && eval "$(direnv hook bash)"

# enable mcfly (if installed)
which mcfly &>/dev/null && eval "$(mcfly init bash)"

export VOLTA_HOME=""
export PATH="$VOLTA_HOME/bin:$PATH"

# enable asdf (if installed)
which asdf &>/dev/null && . /opt/homebrew/opt/asdf/libexec/asdf.sh
which asdf &>/dev/null && echo "asdf installed"

# More colours with grc
# shellcheck disable=SC1090
GRC_SH="$HOMEBREW_PREFIX/etc/grc.sh"
[ -f "$GRC_SH" ] && source "$GRC_SH"

# to avoid non-zero exit code
true
