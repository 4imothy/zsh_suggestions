#!/usr/bin/zsh

local executables=$(go run main.go)
# local chip=$(echo $system_hardware | grep "Chip:" | awk '{print($2$3$4)}')
 
__update_command() {
  zle .$WIDGET
  local key="${BUFFER: -1}"
  __CURRENT_INPUT="${__CURRENT_INPUT}${key}"
}

__erase_save(){
  echo "${__CURRENT_INPUT}"
  __CURRENT_INPUT=""
}

local __CURRENT_INPUT=""

zle -N self-insert __update_command  

if [[ ! "$precmd_functions" == *__erase_save* ]]; then
    precmd_functions+=(__erase_save)
fi 
