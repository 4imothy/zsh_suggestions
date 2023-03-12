#! /bin/zsh

function __keypress() {
  zle .$WIDGET
  __get_cur_pos
  POSTDISPLAY="work"
  tput cup $__fut_row $__fut_col
}

function __delete() {
  # remove the last character from buffer
  # echo -n "fail\033[K"
  __get_cur_pos
  BUFFER=${BUFFER%?}
  region_highlight=("0 10 fg=8")
  region_highlight=("P0 20 bold memo=foobar")
  POSTDISPLAY="hello" 
  tput cup $__fut_row $__fut_col
} 

function __get_cur_pos(){
  echo -ne "\033[6n"
  read -t 1 -s -d 'R' line < /dev/tty
  line="${line##*\[}"
  __fut_row=$((${line%%;*}-1)) # extract the row number
  __fut_col=$((${line##*;}-1)) # extract the column number 
  unset line
} 

zle -N self-insert __keypress 
zle -N __del __delete # change the action of delete key to deleting most recent and updating __current_input
bindkey "^?" __del
region_highlight=("P0 20 bold memo=foobar")
zle_highlight=(bold)
region_highlight=(background:red)
