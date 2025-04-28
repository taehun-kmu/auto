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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends curl build-essential cmake

# Installation
curl https://sh.rustup.rs -sSf | sh -s -- -y && . $HOME/.cargo/env
rustup update stable

# Completions
bashc_dir="$HOME/.local/share/bash-completion/completions" && mkdir -p "$bashc_dir"
rustup completions bash >> "$bashc_dir/rustup" && rustup completions bash cargo >> "$bashc_dir/cargo"

zfunc_dir="$HOME/.zfunc" && mkdir -p "$zfunc_dir"
rustup completions zsh > "$zfunc_dir/_rustup" && rustup completions zsh cargo > "$zfunc_dir/_cargo"

# Package
cargo install cargo-quickinstall cargo-binstall cargo-cache
cargo-cache -e
