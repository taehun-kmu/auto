
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


build_dir="$HOME/Workspace/3rdparty/SDK/librealsense"
cd "$build_dir"


# Installation
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
                    -DBUILD_EXAMPLES=ON \
                    -DFORCE_RSUSB_BACKEND=ON \
                    -DBUILD_WITH_CPU_EXTENSIONS=ON \
                    -DBUILD_WITH_OPENMP=ON \
                    -DBUILD_WITH_CUDA=ON \
                    -DCMAKE_CUDA_ARCHITECTURES="87" \
                    -DBUILD_PYTHON_BINDINGS=ON
