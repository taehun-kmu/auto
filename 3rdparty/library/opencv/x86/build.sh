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

# Source Build
build_dir="$HOME/Workspace/thirdparty/library/opencv"

cd "$build_dir" && ninja --C build -j$(nproc)

# Path
# echo "export PKG_CONFIG_PATH=/usr/local/opencv/lib/pkgconfig:$PKG_CONFIG_PATH"
# echo "export LD_LIBRARY_PATH=/usr/local/opencv/lib:$LD_LIBRARY_PATH"


# Reset the shared library cache
# $SUDO ldconfig

# APT Update
# $SUDO $APT update
