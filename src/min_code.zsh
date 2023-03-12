#! /bin/zsh

function __keypress() {
  zle .$WIDGET
  POSTDISPLAY="add"
  __apply_highlighting
}

function __delete() {
  # remove the last character from buffer
  # echo -n "fail\033[K"
  BUFFER=${BUFFER%?}
  POSTDISPLAY="del" 
  __apply_highlighting
}

zle -N self-insert __keypress 
zle -N backward-delete-char __delete

function __apply_highlighting() {
	if [ $#POSTDISPLAY -gt 0 ]; then
    region_highlight=("$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) fg=4")
  fi
}