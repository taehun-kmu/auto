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

# Update
wget -P /usr/local/share/ca-certificates/ https://raw.githubusercontent.com/taehun-kmu/shellscript/main/ssl/KMU.crt
$SUDO update-ca-certificates
