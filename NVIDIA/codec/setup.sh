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

# Requirement
$SDUO $APT update && $SUDO $APT install -y --no-install-recommends zip unzip

# Download
wget -P . https://raw.githubusercontent.com/taehun-kmu/auto/main/codec/SDK_12.2.zip && unzip SDK_12.2.zip

# Setup
$SUDO cp Video_Codec_SDK_*/Interface/*.h /usr/local/cuda/targets/$(uname -m)-linux/include/
$SUDO cp Video_Codec_SDK_*/Lib/linux/stubs/$(uname -m)/*.so /usr/local/cuda/lib64/

# Remove
rm -rf Video_Codec_SDK_12.2.72

