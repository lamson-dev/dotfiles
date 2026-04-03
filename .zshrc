# Ensure Homebrew zsh functions are in fpath (Apple Silicon)
if [ -d /opt/homebrew/share/zsh/functions ]; then
  fpath=(/opt/homebrew/share/zsh/functions /opt/homebrew/share/zsh/site-functions $fpath)
fi

fpath=("$HOME/.oh-my-zsh/custom/completions" $fpath)

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Skip compinit security check — Homebrew dirs are owned by admin user,
# not the current user, which compinit -i silently skips.
ZSH_DISABLE_COMPFIX=true

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Re-add Homebrew zsh functions after Oh My Zsh (it resets fpath)
if [ -d /opt/homebrew/share/zsh/functions ]; then
  fpath=(/opt/homebrew/share/zsh/functions /opt/homebrew/share/zsh/site-functions $fpath)
  autoload -Uz add-zsh-hook bashcompinit
fi

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
