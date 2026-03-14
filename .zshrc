# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("$HOME/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit
compinit -u
# OPENSPEC:END

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

alias zel="zellij"
alias gemi="gemini"
alias pu="pulumi"

eval "$(starship init zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# NVM: Node Version Manager
export NVM_DIR="$HOME/.nvm"
NVM_BREW="/opt/homebrew/opt/nvm"
[ -s "$NVM_BREW/nvm.sh" ] && \. "$NVM_BREW/nvm.sh"
[ -s "$NVM_BREW/etc/bash_completion.d/nvm" ] && \. "$NVM_BREW/etc/bash_completion.d/nvm"
