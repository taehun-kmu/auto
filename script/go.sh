#!/bin/bash
set -e

command_exists() {
  command -v "$@" > /dev/null 2>&1
}

user_can_sudo() {
  command_exists sudo || return 1
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

if user_can_sudo; then
  SUDO="sudo"
else
  SUDO="" # To support docker environment
fi

user_can_apt() {
  command_exists apt-fast || return 1
  ! LANG= apt-fast -n -v 2>&1 | grep -q "may not run apt-fast"
}

if user_can_apt; then
  APT="apt-fast"
else
  APT="apt-get" # Basic command
fi

# Installation
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends software-properties-common gpg-agent
$SUDO add-apt-repository -y ppa:longsleep/golang-backports
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends golang-go

# ENV
go env -w GOPATH="$HOME/.go"
go env -w CGO_CFLAGS='-O3 -g'
go env -w CGO_CXXFLAGS='-O3 -g'
go env -w CGO_FFLAGS='-O3 -g'
go env -w CGO_LDFLAGS='-O3 -g'

# Package
go install github.com/cheat/cheat/cmd/cheat@latest
go install github.com/rs/curlie@latest
go install github.com/jesseduffield/lazygit@latest

# PATH
echo 'PATH="$PATH:$HOME/.go/bin"' | $SUDO tee -a /etc/profile.d/go.sh
