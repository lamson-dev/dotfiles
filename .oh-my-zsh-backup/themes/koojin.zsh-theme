PROMPT='
$fg[yellow]%m: $fg[magenta]$(get_pwd)
 %{$fg_bold[blue]%}☿ %{$fg_bold[green]%}%p % %{$reset_color%}'

#RPROMPT='$(battery_charge)'
RPROMPT='$(git_prompt_info) $(battery_charge)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}git:[%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}] %{$fg[red]%}✗%{$reset_color%}"
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