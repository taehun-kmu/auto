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
$SUDO $APT update && $SUDO $APT upgrade && $SUDO $APT dist-upgrade
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends libssl-dev libusb-1.0-0-dev libudev-dev \
                                                                   pkg-config libgtk-3-dev \
                                                                   git wget cmake build-essential \
                                                                   libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev \
                                                                   freeglut3-dev at v4l-utils


# Repository
realsense_dir="$HOME/Workspace/3rdparty/SDK"
mkdir -p "$realsense_dir" && cd "$realsense_dir"
git clone -b v2.56.4 https://github.com/IntelRealSense/librealsense.git && cd librealsense

# udev
./scripts/setup_udev_rules.sh
