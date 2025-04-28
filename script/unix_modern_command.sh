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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends ripgrep

# zellij setup --generate-completion zsh > $HOME/.zfunc/_zellij

curl -L -o $HOME/.zfunc/_tealdeer https://github.com/tealdeer-rs/tealdeer/raw/refs/heads/main/completion/zsh_tealdeer
curl -L -o $HOME/.zfunc/_dust https://github.com/bootandy/dust/raw/refs/heads/master/completions/_dust
curl -L -o $HOME/.zfunc/_sd https://github.com/chmln/sd/raw/refs/heads/master/gen/completions/_sd
curl -L -o $HOME/.zfunc/_cheat https://github.com/cheat/cheat/raw/refs/heads/master/scripts/cheat.zsh

git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
yes | $HOME/.fzf/install --all

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

bat --config-file
bat --generate-config-file
sed -i 's|#--theme="TwoDark"|--theme="ansi"|g' $HOME/.config/bat/config

yes | broot > /dev/null 2>&1
