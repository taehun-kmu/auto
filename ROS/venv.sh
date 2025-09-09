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
$SUDO $APT update && $SUDO $APT install -y --no-install-recommends jq

# Python Virtual Envrironment Setup
uv venv --system-site-packages

# COLCON_IGNORE
touch .venv/COLCON_IGNORE

# Installation colcon & setuptoools
uv pip install --force-reinstall colcon-core setuptools==$(pip list --no-index --format=json |  jq -r '.[] | select(.name=="setuptools").version') --no-cache
uv pip install colcon-common-extensions --no-cache

# Check the colcon path
source .venv/bin/activate

echo ""
which colcon
python -c "import colcon; print(colcon.__file__)"
echo ""

deactivate

# Installation empy & lark & catkin_pkg
uv pip install empy==3.3.4 lark catkin_pkg

# Build
echo ""
echo "source .venv/bin/activate"
echo "python -m colcon build --cmake-args -D CMAKE_BUILD_TYPE=Release --event-handlers console_direct+"
