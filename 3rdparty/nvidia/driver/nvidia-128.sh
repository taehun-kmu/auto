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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends curl wget wget2 openssh-server \
                                                                   net-tools make \
                                                                   gcc g++ gcc-12 g++-12 \
                                                                   libncurses-dev libssl-dev flex \
                                                                   libelf-dev bison build-essential \
                                                                   libtool git autoconf automake \
                                                                   pkg-config rt-tests doxygen \
                                                                   acpid dkms libglvnd-core-dev \
                                                                   libglvnd0 libglvnd-dev libc6-dev

# Setup to gcc-12 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/taehun-kmu/auto/main/script/gcc.sh)"

# Download
run_dir="$HOME/Downloads/driver"
mkdir -p "$run_dir" && cd "$run_dir"
wget https://us.download.nvidia.com/XFree86/Linux-x86_64/570.172.08/NVIDIA-Linux-x86_64-570.172.08.run
chmod +x *.run
