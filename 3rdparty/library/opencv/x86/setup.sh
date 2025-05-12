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


# System
$SUDO $APT purge -y "*libopencv*" opencv-data
$SUDO $APT autoremove -y --purge


# Requirement
$SUDO $APT update
$SUDO $APT install -y --no-install-recommends zsh curl wget
$SUDO $APT install -y --no-install-recommends git ccache gcc-12 g++-12
$SUDO $APT install -y --no-install-recommends cmake cmake-curses-gui ninja-build
$SUDO $APT install -y --no-install-recommends libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev
$SUDO $APT install -y --no-install-recommends libpng-dev libtiff-dev libglew-dev
$SUDO $APT install -y --no-install-recommends libavif-dev libva-dev libopenjp2-7
$SUDO $APT install -y --no-install-recommends libopenjp2-7-dev libopenjpip-dec-server libopenjpip-server
$SUDO $APT install -y --no-install-recommends libopenjpip-viewer libopenjpip7 libopenjp2-tools
$SUDO $APT install -y --no-install-recommends libopenjp3d-tools libavcodec-dev libavformat-dev
$SUDO $APT install -y --no-install-recommends libswscale-dev libgtk2.0-dev libgtk-3-dev
$SUDO $APT install -y --no-install-recommends "libcanberra-gtk*"
$SUDO $APT install -y --no-install-recommends python3 python3-dev python3-pip
$SUDO $APT install -y --no-install-recommends python3-venv python3-venv python3-numpy
$SUDO $APT install -y --no-install-recommends libxvidcore-dev libx264-dev libtbb-dev
$SUDO $APT install -y --no-install-recommends libdc1394-dev libxine2-dev libv4l-dev
$SUDO $APT install -y --no-install-recommends v4l-utils qv4l2
$SUDO $APT install -y --no-install-recommends libtesseract-dev libpostproc-dev libswresample-dev
$SUDO $APT install -y --no-install-recommends libvorbis-dev libfaac-dev libmp3lame-dev
$SUDO $APT install -y --no-install-recommends libtheora-dev libopencore-amrnb-dev libopencore-amrwb-dev
$SUDO $APT install -y --no-install-recommends libopenblas-base libopenblas-dev libatlas-base-dev
$SUDO $APT install -y --no-install-recommends libblas-dev liblapack-dev liblapacke-dev
$SUDO $APT install -y --no-install-recommends libeigen3-dev gfortran libhdf5-dev
$SUDO $APT install -y --no-install-recommends libprotobuf-dev protobuf-compiler libgoogle-glog-dev
$SUDO $APT install -y --no-install-recommends libgflags-dev openjdk-8-jdk libvtk9-dev
$SUDO $APT install -y --no-install-recommends libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev
$SUDO $APT install -y --no-install-recommends libogre-1.12-dev libceres-dev nasm

# FFmpeg
sh -c "$(curl -fsSL https://raw.githubusercontent.com/taehun-kmu/auto/main/script/ffmpeg.sh)"

# Symbolic Link 
$SUDO ln -s /usr/include/lapacke.h /usr/include/$(uname -m)-linux-gnu


# Installation
library_dir="$HOME/Workspace/thirdparty/library"
mkdir -p "$library_dir" && cd "$library_dir"

git clone -b 4.11.0 --depth=1 https://github.com/opencv/opencv.git
git clone -b 4.11.0 --depth=1 https://github.com/opencv/opencv_contrib.git

echo ""
echo "Edit to opencv/cmake/OpenCVFindOpenBLAS.cmake"
echo ""
echo "Add to Open_BLAS_INCLUDE_SEARCH_PATHS path: /usr/include/$(uname -m)-linux-gnu"
echo "Add to Open_BLAS_LIB_SEARCH_PATHS path: /usr/lib/$(uname -m)-linux-gnu"
echo ""
