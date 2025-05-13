#!/bin/sh
set -e

# @file      extensions.sh
# @author    Taehun Jung     [taehun@kookmin.ac.kr]
#
# Copyright (c) 2025 Taehun Jung, all rights reserved
#
echo "Installing Visual Studio Code Extension Pack for Modern C++"
code --install-extension ms-vscode.cpptools
code --install-extension llvm-vs-code-extensions.vscode-clangd
code --install-extension twxs.cmake
code --install-extension ms-vscode.cmake-tools
code --install-extension cheshirekow.cmake-format
code --install-extension yzhang.markdown-all-in-one
code --install-extension DavidAnson.vscode-markdownlint
