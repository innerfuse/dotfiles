#!/bin/sh
# shellcheck disable=SC2155

# Colourful manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Set to avoid `env` output from changing console colour
export LESS_TERMEND=$'\E[0m'

# Print field by number
field() {
  ruby -ane "puts \$F[$1]"
}

# Setup PATH

# Remove from anywhere in PATH
remove_from_path() {
  [[ -d "$1" ]] || return
  PATHSUB=":${PATH}:"
  PATHSUB=${PATHSUB//:$1:/:}
  PATHSUB=${PATHSUB#:}
  PATHSUB=${PATHSUB%:}
  export PATH="${PATHSUB}"
}

# Add to the start of PATH if it exists
add_to_path_start() {
  [[ -d "$1" ]] || return
  remove_from_path "$1"
  export PATH="$1:${PATH}"
}

# Add to the end of PATH if it exists
add_to_path_end() {
  [[ -d "$1" ]] || return
  remove_from_path "$1"
  export PATH="${PATH}:$1"
}

# Add to PATH even if it doesn't exist
force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="$1:${PATH}"
}

quiet_which() {
  command -v "$1" >/dev/null
}

add_to_path_start "/home/linuxbrew/.linuxbrew/bin"
add_to_path_start "/opt/homebrew/bin"
add_to_path_start "/usr/local/bin"

add_to_path_end "${HOME}/.dotfiles/bin"
add_to_path_end "${HOME}/.gem/ruby/2.6.0/bin"

# Setup Go development
export GOPATH="${HOME}/.gopath"
add_to_path_end "${GOPATH}/bin"

# Run rbenv/nodenv if they exist
quiet_which rbenv && add_to_path_start "$(rbenv root)/shims"
quiet_which nodenv && add_to_path_start "$(nodenv root)/shims"

# Aliases
alias mkdir="mkdir -vp"
alias df="df -H"
alias rm="rm -iv"
alias mv="mv -iv"
alias zmv="noglob zmv -vW"
alias cp="cp -irv"
alias du="du -sh"
alias make="nice make"
alias less="less --ignore-case --raw-control-chars"
alias rsync="rsync --partial --progress --human-readable --compress"
alias rake="noglob rake"
alias rg="rg --colors 'match:style:nobold' --colors 'path:style:nobold'"
alias be="nocorrect noglob bundle exec"
alias sha256="shasum -a 256"
alias perlsed="perl -p -e"

# Command-specific stuff
if quiet_which brew; then
  eval $(brew shellenv)

  export HOMEBREW_DEVELOPER=1
  export HOMEBREW_BOOTSNAP=1
  export HOMEBREW_NO_ENV_HINTS=1
  export HOMEBREW_AUTOREMOVE=1

  add_to_path_end "${HOMEBREW_PREFIX}/Library/Homebrew/shims/gems"

  alias hbc='cd $HOMEBREW_REPOSITORY/Library/Taps/homebrew/homebrew-core'
fi

if quiet_which git-delta; then
  export GIT_PAGER='delta'
else
  # shellcheck disable=SC2016
  export GIT_PAGER='less -+$LESS -RX'
fi

if quiet_which exa; then
  alias ls="exa --classify --group --git"
elif [[ -n "${MACOS}" ]]; then
  alias ls="ls -F"
else
  alias ls="ls -F --color=auto"
fi

if quiet_which bat; then
  export BAT_THEME="ansi"
  alias cat="bat"
fi

if quiet_which prettyping; then
  alias ping="prettyping --nolegend"
fi

if quiet_which htop; then
  alias top="sudo htop"
fi

if quiet_which dust; then
  alias du="dust"
fi

if quiet_which duf; then
  alias df="duf"
fi

if quiet_which mcfly; then
  export MCFLY_LIGHT=TRUE
  export MCFLY_FUZZY=true
  export MCFLY_RESULTS=64
fi

# Configure environment
export CLICOLOR=1
export GITHUB_PROFILE_BOOTSTRAP=1
export GITHUB_PACKAGES_SUBPROJECT_CACHE_READ=1
export GITHUB_NO_AUTO_BOOTSTRAP=1

# OS-specific configuration
if [[ -n "${MACOS}" ]]; then
  export GREP_OPTIONS="--color=auto"
  export VAGRANT_DEFAULT_PROVIDER="vmware_fusion"

  add_to_path_end "${HOMEBREW_PREFIX}/opt/git/share/git-core/contrib/diff-highlight"
  add_to_path_end "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

  alias fork="/Applications/Fork.app/Contents/Resources/fork_cli"

  alias locate="mdfind -name"
  alias finder-hide="setfile -a V"

  # Load GITHUB_TOKEN from macOS keychain
  # export GITHUB_TOKEN=$(
  #   printf "protocol=https\\nhost=github.com\\n" |
  #     git credential fill |
  #     perl -lne '/password=(gho_.+)/ && print "$1"'
  # )
  export HOMEBREW_GITHUB_API_TOKEN="${GITHUB_TOKEN}"
  export JEKYLL_GITHUB_TOKEN="${GITHUB_TOKEN}"
  export BUNDLE_RUBYGEMS__PKG__GITHUB__COM="${GITHUB_TOKEN}"

  # output what's listening on the supplied port
  on-port() {
    sudo lsof -nP -i4TCP:"$1"
  }

  # make no-argument find Just Work.
  find() {
    local arg
    local path_arg
    local dot_arg

    for arg; do
      [[ ${arg} =~ "^-" ]] && break
      path_arg="${arg}"
    done

    [[ -z "${path_arg}" ]] && dot_arg="."

    command find "${dot_arg}" "$@"
  }

  # Only run these if they're not already running
  pgrep -fq rbenv-nodenv-homebrew-sync || rbenv-nodenv-homebrew-sync
  pgrep -fq touchid-enable-pam-sudo || touchid-enable-pam-sudo --quiet
elif [[ -n "${LINUX}" ]]; then
  quiet_which keychain && eval "$(keychain -q --eval --agents ssh id_rsa)"

  add_to_path_end "/data/github/shell/bin"
  add_to_path_start "/workspaces/github/bin"

  alias su="/bin/su -"
  alias open="xdg-open"
elif [[ -n "${WINDOWS}" ]]; then
  open() {
    # shellcheck disable=SC2145
    cmd /C"$@"
  }
fi

# Set up editor
if quiet_which code; then
  export EDITOR="code"
  export GIT_EDITOR="${EDITOR} -w"
  export SVN_EDITOR="${GIT_EDITOR}"
elif quiet_which vim; then
  export EDITOR="vim"
elif quiet_which vi; then
  export EDITOR="vi"
fi

# Run dircolors if it exists
quiet_which dircolors && eval "$(dircolors -b)"

# Run volta setup, if it exists
if quiet_which volta; then;
  eval "$(volta setup)"
  add_to_path_start "$VOLTA_HOME/bin"
fi

# Load the global secrets
source $HOME/.secrets

# Save directory changes
cd() {
  builtin cd "$@" || return
  [[ -n "${TERMINALAPP}" ]] && command -v set_terminal_app_pwd >/dev/null &&
    set_terminal_app_pwd
  pwd >"${HOME}/.lastpwd"
  ls
}

# Use ruby-prof to generate a call stack
ruby-call-stack() {
  ruby-prof --printer=call_stack --file=call_stack.html -- "$@"
}

# Pretty-print JSON files
json() {
  [[ -n "$1" ]] || return
  cat "$1" | jq .
}

# Pretty-print Homebrew install receipts
receipt() {
  [[ -n "$1" ]] || return
  json "${HOMEBREW_PREFIX}/opt/$1/INSTALL_RECEIPT.json"
}

# Move files to the Trash folder
trash() {
  mv "$@" "${HOME}/.Trash/"
}

# GitHub API shortcut
github-api-curl() {
  noglob curl -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/$1"
}
