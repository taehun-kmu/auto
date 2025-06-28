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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends git wget zip unzip

# Installation
cd && cd Downloads
wget -O eigen-3.3.9.zip https://gitlab.com/libeigen/eigen/-/archive/3.3.9/eigen-3.3.9.zip
unzip eigen-3.3.9.zip

# Build
cd && cd Downloads/eigen-3.3.9 
cmake -S . -B build 
cd build && $SUDO make install -j$(nproc)

$SUDO ldconfig
