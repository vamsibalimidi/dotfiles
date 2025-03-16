. "$HOME/.cargo/env"
. ~/.alias.bash

eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/jandedobbeleer.omp.json)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/vamsibalimidi/.lmstudio/bin"
