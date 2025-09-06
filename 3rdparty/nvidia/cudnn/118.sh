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
sh -c "$(curl -fsSL https://raw.githubusercontent.com/taehun-kmu/auto/main/script/gcc.sh)"

# Download
cudnn_dir="$HOME/Downloads/CUDNN"
mkdir -p "$cudnn_dir" && cd "$cudnn_dir"
wget https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-x86_64/cudnn-linux-x86_64-8.9.6.50_cuda11-archive.tar.xz

tar -xvf cudnn-linux-x86_64-8.9.6.50_cuda11-archive.tar.xz

echo ""
echo "sudo cp cudnn/include/cudnn*h /usr/local/cuda/include/"
echo "sudo cp cudnn/lib/libcudnn* /usr/local/cuda/lib64/"
echo ""
