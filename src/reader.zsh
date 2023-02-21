#!/usr/bin/zsh
 
__update_command() {
  zle .$WIDGET
  local key="${BUFFER: -1}"
  __CURRENT_INPUT="${__CURRENT_INPUT}${key}"
  echo $__CURRENT_INPUT
}

__prepare_for_next(){
  echo "${__CURRENT_INPUT}"
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
