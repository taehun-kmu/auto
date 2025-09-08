[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)

export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"
