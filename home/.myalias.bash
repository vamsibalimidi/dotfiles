# ------------------------------------
# Color variables
# ------------------------------------
# Regular Colors
Black='\[\033[0;30m\]'
Red='\[\033[0;31m\]'
Greenlias='\[\033[0;32m\]'
Yellow='\[\033[0;33m\]'
Blue='\[\033[0;34m\]'
Purple='\[\033[0;35m\]'
Cyan='\[\033[0;36m\]'
White='\[\033[0;37m\]'
Light_Gray='\[\033[0;37m\]'

# Reset colors
NONE='\[\033[0;0m\]'

alias a='alias | f'
alias blu='xterm -sb -sl 5000 -fg white -bg midnightblue -cr red -title "Switch Console" -n "Switch Console" -fn 9x15 &'
alias green='xterm -sb -sl 5000 -fg black -bg lightgreen -cr red -title "Switch Console" -n "Switch Console" -fn 9x15 &'
alias cdc='cd ~/.config/'
alias cls='tput clear'
alias createtar='tar -cvzf '
alias cya=' xterm -sb -sl 5000 -fg white -bg darkcyan -cr red -title "Switch" -n "Switch" -fn "-bitstream-courier 10 pitch-medium-r-normal--0-0-0-0-m-0-iso10646-1"  -fn 9x15&'
alias dev='konsole --profile dev&'
alias diff='gvimdiff'


alias e='exit'
alias findc='find . -depth \( -name \*.c -o -name \*.h \) -exec grep -l \!* {} \; | tee /dev/stderr | xargs grep -n \!* '
alias f='fzf --height=90% --layout=reverse --info=inline --border --margin=1 --padding=1 --cycle'
alias gt='git tag --contains '
alias gc='git_diff_with_prev_commit '
alias gf='git diff '
alias gitdir='git rev-parse --show-toplevel'
alias gp='git pull'
alias gsg='git status'
alias gs='git status .'
alias h='history'
alias ll='ls -alFG --color=auto'
alias lld='ls -alFGd */ --color=auto'
alias l.='ls -d .* --color=always'
alias ls='ls --color=always'
alias m='cat \!* | tbl | col | nroff -man | more'
alias nv='nvim'
alias nvk='NVIM_APPNAME="nvim-kickstart" nvim'
alias nvn='NVIM_APPNAME="nvim-chad" nvim'
alias s='grep -rn'
alias st='stow'
alias sti='stow -t ~/'
alias stx='stow -t ~/ -D'
alias vi='vim'
echo "------------------------------------------------------------------------------"
