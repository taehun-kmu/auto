#!/bin/bash
set -e

zfunc_dir="$HOME/.zfunc" && mkdir -p "$zfunc_dir"
rustup completions zsh > "$zfunc_dir/_rustup" && rustup completions zsh cargo > "$zfunc_dir/_cargo"

rg --generate complete-zsh > $HOME/.zfunc/_rg

zellij setup --generate-completion zsh > $HOME/.zfunc/_zellij

curl -L -o $HOME/.zfunc/_tealdeer https://github.com/tealdeer-rs/tealdeer/raw/refs/heads/main/completion/zsh_tealdeer
curl -L -o $HOME/.zfunc/_dust https://github.com/bootandy/dust/raw/refs/heads/master/completions/_dust
curl -L -o $HOME/.zfunc/_eza https://github.com/eza-community/eza/raw/refs/heads/main/completions/zsh/_eza
curl -L -o $HOME/.zfunc/_fd https://github.com/sharkdp/fd/raw/refs/heads/master/contrib/completion/_fd
curl -L -o $HOME/.zfunc/_sd https://github.com/chmln/sd/raw/refs/heads/master/gen/completions/_sd
curl -L -o $HOME/.zfunc/_cheat https://github.com/cheat/cheat/raw/refs/heads/master/scripts/cheat.zsh

git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf

yes | $HOME/.fzf/install --all

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

bat --config-file
bat --generate-config-file
sed -i 's|#--theme="TwoDark"|--theme="ansi"|g' $HOME/.config/bat/config

yes | broot > /dev/null 2>&1

