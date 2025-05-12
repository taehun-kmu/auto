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
$SUDO $APT update && $SUDO $APT install -y git autoconf patch build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libtiff-dev libgdbm-dev libdb-dev uuid-dev

# ruby-build
git clone --recursive --depth=1 https://github.com/rbenv/ruby-build.git $HOME/.ruby-build
cd $HOME/.ruby-build

$SUDO PREFIX=/usr/local $HOME/.ruby-build/install.sh
echo "Installation Complete"

# ruby
ruby-build --list
ruby-build 3.3.7 $HOME/.ruby

export PATH=$HOME/.ruby/bin:$PATH

gem update --system
gem install neovim

# PATH
echo 'PATH="$PATH:$HOME/.ruby/bin"' | $SUDO tee -a /etc/profile.d/ruby.sh
