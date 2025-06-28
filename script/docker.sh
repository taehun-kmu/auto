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

# Uninstall Old Versions
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do $SUDO $APT remove $pkg; done

# Add Docker's official GPG key:
$SUDO $APT update && $SUDO $APT install ca-certificates curl
$SUDO install -m 0755 -d /etc/apt/keyrings
$SUDO curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
$SUDO chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$SUDO $APT update

# Installation
$SUDO $APT install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Gruop
$SUDO groupadd docker

# Adding Users to Groups
$SUDO usermod -aG docker ${USER}
$SUDO gpasswd -a $USER docker

# Restart
$SUDO systemctl restart docker

# Signing out add signing back in the current user
$SUDO su -

# Login User
su - $(ls /home)
