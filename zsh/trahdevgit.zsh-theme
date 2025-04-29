#PROMPT="%B%F{47}[ %m ]%b%f %(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%}"
#PROMPT+=' $(git_prompt_info)'
#autoload -Uz vcs_info
setopt prompt_subst
#zstyle ':vcs_info:git*' formats " %F{10}%b%f %m%u%c %a"
zstyle ':vcs_info:git*' formats "  %F{10}%b%f %c %a"
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{green}✚%f'
zstyle ':vcs_info:*' unstagedstr '%F{red}●%f'


PRE="%B%F{47}[ %m ]%b%f %(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%2~%{$reset_color%}"
PRE+='${vcs_info_msg_0_} '
precmd() { 
  vcs_info 
  print -P $PRE
}
PROMPT='$ '

