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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends curl wget openssh-server net-tools \
                                                                   make gcc g++ gcc-12 g++-12 \
                                                                   libncurses-dev libssl-dev \
                                                                   flex libelf-dev bison build-essential \
                                                                   libtool git autoconf automake pkg-config \
                                                                   doxygen acpid dkms libglvnd-core-dev \
                                                                   libglvnd0 libglvnd-dev libc6-dev
