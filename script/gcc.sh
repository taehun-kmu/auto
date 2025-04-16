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
  command_exists apt-fast
}

if user_can_apt; then
  APT="apt-fast"
else
  APT="apt-get" # Basic command
fi

# Requirement
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends gcc gcc-12 g++ g++-12

# gcc
$SUDO update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100
$SUDO update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 200

# g++
$SUDO update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 200
$SUDO update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100
