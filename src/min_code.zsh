#! /bin/zsh

function __keypress() {
  zle .$WIDGET
  __get_cur_pos
  tput cuf1
  RBUFFER=""
  RBUFFER="work"
  tput cup $__fut_row $__fut_col
}

function __delete() {
  # remove the last character from buffer
  # echo -n "fail\033[K"
  __get_cur_pos
  RBUFFER=""
  BUFFER=${BUFFER%?}
  RBUFFER="fuck"
  tput cup $__fut_row $__fut_col
}

function __clear_rbuffer(){
  RBUFFER=""
}

function __get_cur_pos(){
  echo -ne "\033[6n"
  read -t 1 -s -d 'R' line < /dev/tty
  line="${line##*\[}"
  __fut_row=$((${line%%;*}-1)) # extract the row number
  __fut_col=$((${line##*;}-1)) # extract the column number 
  unset line
}

function clear-rbuffer-and-execute {
  RBUFFER=""
  zle accept-line
}

zle -N clear-rbuffer-and-execute
bindkey '^M' clear-rbuffer-and-execute 
zle -N self-insert __keypress 
zle -N __del __delete # change the action of delete key to deleting most recent and updating __current_input
bindkey "^?" __del
