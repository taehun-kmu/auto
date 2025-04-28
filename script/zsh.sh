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

$SUDO $APT update && $SUDO $APT install -y --no-install-recommends curl wget ca-certificates zsh git

# Installation
if command -v zsh &> /dev/null
then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions
  git clone https://github.com/hlissner/zsh-autopair ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autopair
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

  wget -O $HOME/.zshrc https://raw.githubusercontent.com/taehun-kmu/auto/main/script/zsh/.zshrc
  wget -O $HOME/.p10k.zsh https://raw.githubusercontent.com/taehun-kmu/auto/main/script/zsh/.p10k.zsh

  wget -O $HOME/.oh-my-zsh/custom/broot.zsh https://raw.githubusercontent.com/taehun-kmu/auto/main/script/zsh/broot.zsh
  wget -O $HOME/.oh-my-zsh/custom/eza.zsh https://raw.githubusercontent.com/taehun-kmu/auto/main/script/zsh/eza.zsh
  wget -O $HOME/.oh-my-zsh/custom/fzf.zsh https://raw.githubusercontent.com/taehun-kmu/auto/main/script/zsh/fzf.zsh 
  wget -O $HOME/.oh-my-zsh/custom/zoxide.zsh https://raw.githubusercontent.com/taehun-kmu/auto/main/script/zsh/zoxide.zsh

else
  exit 1

fi
