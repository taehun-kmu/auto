
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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends git ninja-build gettext cmake curl build-essential

# Build
tool_dir="$HOME/Workspace/thirdparty/tool"
mkdir -p "$tool_dir"
cd "$tool_dir" && git clone -b v0.11.4 --depth=1 https://github.com/neovim/neovim.git && cd neovim
make CMAKE_BUILD_TYPE=Release && $SUDO make install

# Backup
mv $HOME/.local/state/nvim $HOME/.local/state/nvim.bak

# Installation
git clone --depth 1 https://github.com/AstroNvim/template $HOME/.config/nvim
rm -rf $HOME/.config/nvim/.git

mkdir -p $HOME/.local/share/nvim/dirsession/

ls -la $HOME/.local/share/nvim/
$SUDO chmod 755 /home/orin/.local/share/nvim/dirsession/
$SUDO chown -R orin:orin /home/orin/.local/share/nvim/
