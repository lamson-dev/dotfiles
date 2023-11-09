PROMPT='
$fg[cyan]%m: $fg[yellow]$(get_pwd)
%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} %{$fg_bold[red]%}☿ %{$fg_bold[green]%}%p % %{$reset_color%}'

RPROMPT='$(battery_charge)'

ZSH_THEME_GIT_PROMPT_PREFIX="git:[%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}] %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}]"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"

function get_pwd() {
   echo "${PWD/$HOME/~}"
}

function battery_charge() {
    if [ -e ~/.oh-my-zsh/batcharge.py ]
    then
        echo `python ~/.oh-my-zsh/batcharge.py`
    else
        echo '';
    fi
}