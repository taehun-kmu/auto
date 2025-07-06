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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends git cmake libspdlog-dev libsuitesparse-dev qtdeclarative5-dev qt5-qmake libqglviewer-dev-qt5

# Installation
cd && mkdir -p .solver && cd .solver
git clone -b 20241228_git https://github.com/RainerKuemmerle/g2o.git && cd g2o
cmake -S . -B build 
cmake --build build -j$(( $(nproc) - 2 ))
$SUDO cmake --install build

$SUDO ldconfig
