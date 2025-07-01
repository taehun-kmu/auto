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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends git build-essential cmake \
                                                                   libgl1-mesa-dev libglew-dev libepoxy-dev libglfw3-dev \
                                                                   libegl1-mesa-dev libwayland-dev libxkbcommon-dev wayland-protocols \
                                                                   libpython3-dev \
                                                                   libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev


# Clone & Build
git clone -b v0.8 https://github.com/stevenlovegrove/Pangolin.git && cd Pangolin
cmake -S . -B build -D CMAKE_CXX_FLAGS="-Wno-missing-braces"
cmake --build build -j$(( $(nproc) - 2))
$SUDO cmake --install build


# Add to Library Path
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
