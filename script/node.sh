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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends git

# node-build
git clone -b v5.3.22 --recursive --depth=1 https://github.com/nodenv/node-build.git $HOME/.node-build

if [ -n "$SUDO" ]; then
  $SUDO env PREFIX=/usr/local "$HOME/.node-build/install.sh"
  echo "Installation Complete"
else
  $SUDO env PREFIX=/usr/local "$HOME/.node-build/install.sh"
fi

# node
node-build 22.12.0 $HOME/.node

export PATH=$HOME/.node/bin:$PATH

npm install -g npm@latest
npm install -g neovim

# PATH
echo 'PATH="$PATH:$HOME/.node/bin"' | $SUDO tee -a /etc/profile.d/node.sh
