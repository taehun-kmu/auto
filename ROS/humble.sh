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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends software-properties-common gpg-agent
$SUDO add-apt-repository universe -y

# Add a repository and enroll a key
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends curl
$SUDO curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | $SUDO tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install development tools
$SUDO $APT update && $SUDO $APT install -y ros-dev-tools

# Installing ROS2
$SUDO $APT install -y ros-humble-desktop-full

# Install development tools (colcon)
$SUDO $APT install -y python3-colcon-common-extensions

# Install DDS (fastRTPS -> CycloneDDS)
$SUDO $APT install -y ros-humble-rmw-cyclonedds-cpp

# Installing rosdep and vcstool
$SUDO $APT  install -y python3-rosdep python3-vcstool
$SUDO rosdep init && rosdep update

