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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends curl build-essential cmake file ffmpeg 7zip jq poppler-utils imagemagick

# Installation
curl https://sh.rustup.rs -sSf | sh -s -- -y && . $HOME/.cargo/env
rustup update stable

# Package
cargo install cargo-quickinstall cargo-binstall cargo-cache
cargo-cache -e
cargo install tealdeer choose du-dust eza resvg fd-find procs ripgrep sd bottom bat broot hyperfine tree-sitter-cli zellij yazi-fm yazi-cli
