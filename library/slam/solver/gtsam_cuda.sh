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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends git libomp-dev libboost-all-dev libmetis-dev libfmt-dev libspdlog-dev libglm-dev libglfw3-dev libpng-dev libjpeg-dev

# Installation
cd && mkdir .solver && cd .solver
git clone https://github.com/borglab/gtsam && cd gtsam && git checkout 4.3a0
cmake -S . -B build -D GTSAM_BULID_EXAMPLES_ALWAYS=OFF \
                    -D GTSAM_BUILD_TESTS=OFF \
                    -D GTSAM_WITH_TBB=OFF \
                    -D GTSAM_USE_SYSTEM_EIGEN=ON \
                    -D GTSAM_BUILD_WITH_MARCH_NATIVE=OFF 
cmake --build bulid -j$(nproc)
$SUDO cmake --install build

# Install Iridescence for visualization
# This is optional but highly recommended
cd && cd .solver 
git clone https://github.com/koide3/iridescence --recursive cd iridescence && cd iridescence
cmake -S . -B build -D CMAKE_BUILD_TYPE=Release 
cmake --build build -j$(nproc)
$SUDO cmake --install build

# Install gtsam_points
cd && cd .solver
git clone https://github.com/koide3/gtsam_points && cd gtsam_points
cmake -S . -B build -D BUILD_WITH_CUDA=ON 
cmake --build build -j$(nproc)
$SUDO cmake --install build

$SUDO ldconfig
