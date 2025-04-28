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

# Requirement 
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends curl wget zip unzip build-essential ccache pkg-config software-properties-common gpg-agent python3 python3-dev python3-pip python3-venv
$SUDO add-apt-repository universe -y


# Set locale
locale  # check for UTF-8

$SUDO $APT update && $SUDO $APT install locales
$SUDO locale-gen en_US en_US.UTF-8
$SUDO update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

locale  # verify settings


# Setup Sources 
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" # If using Ubuntu derivates use $UBUNTU_CODENAME
$SUDO dpkg -i /tmp/ros2-apt-source.deb


# Installation
$SUDO $APT update && $SUDO $APT upgrade -y 

$SUDO $APT install -y --no-install-recommends ros-humble-desktop 

$SUDO $APT install -y --no-install-recommends ros-dev-tools python3-colcon-clean 


# Envrironment setup 
echo -e "\nsource /opt/ros/humble/setup.bash" >> $HOME/.bashrc
echo -e "\nexport _colcon_cd_root=$HOME/Workspace/ros2_ws"
echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> $HOME/.bashrc
echo "source /usr/share/colcon_cd/function/colcon_cd-argcomplete.bash" >> $HOME/.bashrc
echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> $HOME/.bashrc


# ROS2 rqt TF tree 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/taehun-kmu/auto/main/ROS/rqt_tf.sh)"
