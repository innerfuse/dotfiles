# always source zprofile regardless of whether this is/isn't a login shell
source ~/.zprofile

# load shared shell configuration
source ~/.shrc

# History file
export HISTFILE=~/.zsh_history

# Don't show duplicate history entires
setopt hist_find_no_dups

# Remove unnecessary blanks from history
setopt hist_reduce_blanks

# Share history between instances
setopt share_history

# Don't hang up background jobs
setopt no_hup

# autocorrect command and parameter spelling
setopt correct
setopt correctall

# use emacs bindings even with vim as EDITOR
bindkey -e

# fix backspace on Debian
[ -n "$LINUX" ] && bindkey "^?" backward-delete-char

# fix delete key on macOS
[ -n "$MACOS" ] && bindkey '\e[3~' delete-char

# alternate mappings for Ctrl-U/V to search the history
bindkey "^u" history-beginning-search-backward
bindkey "^v" history-beginning-search-forward

# enable autosuggestions
ZSH_AUTOSUGGESTIONS="$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$ZSH_AUTOSUGGESTIONS" ] && source "$ZSH_AUTOSUGGESTIONS"

# enable starship integration for zsh
which starship &>/dev/null && eval "$(starship init zsh)"

# enable direnv (if installed)
which direnv &>/dev/null && eval "$(direnv hook zsh)"

# enable mcfly (if installed)
which mcfly &>/dev/null && eval "$(mcfly init zsh)"

# to avoid non-zero exit code
export VOLTA_HOME=""
export PATH="$VOLTA_HOME/bin:$PATH"

# enable asdf (if installed)
which asdf &>/dev/null && . /opt/homebrew/opt/asdf/libexec/asdf.sh
which asdf &>/dev/null && echo "asdf installed"

# More colours with grc
# shellcheck disable=SC1090
GRC_ZSH="$HOMEBREW_PREFIX/etc/grc.zsh"
[ -f "$GRC_ZSH" ] && source "$GRC_ZSH"

# Disable autocorrection for some commonly used binaries
alias npm='nocorrect npm'
alias yarn='nocorrect yarn'
alias pnpm='nocorrect pnpm'

true
