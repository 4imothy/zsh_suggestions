#!/usr/bin/zsh
 
__update_command() {
  tput sc
  zle .$WIDGET
  local key="${BUFFER: -1}"
  __CURRENT_INPUT="${__CURRENT_INPUT}${key}"
  echo "\n$__CURRENT_INPUT"
  tput rc
}

function __remove_char() {
  tput sc
  zle backward-delete-char
  __CURRENT_INPUT="${__CURRENT_INPUT%?}"
  echo "\n$__CURRENT_INPUT\033[K"
  tput rc
}
zle -N __remove_in_copy __remove_char
bindkey "^?" __remove_in_copy

__prepare_for_next(){
  __CURRENT_INPUT=""
}

# Only do these things the first time this file is sourced

local __CURRENT_INPUT=""

zle -N self-insert __update_command  

if [[ ! "$precmd_functions" == *__prepare_for_next* ]]; then
    precmd_functions+=(__prepare_for_next)
fi 

# get all the executable commands
 
# path=(${(s/:/)${PATH}})
# local executables=()

# # Loop through each directory in the path
# for directory in "${path[@]}"; do

local executables=()

# Loop through each directory in the path
for directory in ${(s/:/)${PATH}}; do

  # Loop through each file in the directory
  for file in "${directory}"/*(N); do

    # Check if the file is executable
    if [[ -x "${file}" ]]; then

      # Print the full path to the executable
      executables+=("${file:t}")
    fi 
  done 
done  
