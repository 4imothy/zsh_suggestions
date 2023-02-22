#!/usr/bin/zsh
 
__update_command() {
  zle .$WIDGET
  local key="${KEYS[-1]}"
  __CURRENT_INPUT="${BUFFER}"
  # echo "\n$__CURRENT_INPUT\033[K" # ascii to erase to end of line
  # printf "\n%s$__CURRENT_INPUT\033[K"  # print contents on next line and erase to end of line
  tput sc
  __find_matches
  tput rc
}

__remove_char() {
  zle backward-delete-char
  __CURRENT_INPUT="${BUFFER}" # remove the last character
  tput sc
  __find_matches
  tput rc
}

__find_matches(){
  # if there are no typed words, then clear the output and return
  if [[ ${#__CURRENT_INPUT} -eq 0 ]]; then
    echo "\n\033[K"
    return
  fi 
  matches=()
  for ex in "${executables[@]}"; do
    if [[ "$ex" == "$__CURRENT_INPUT"* ]]; then
      # If the current input partially matches an item in the vector, print a message
      if [[ "${#matches}" -lt 5 ]]; then # if the length of matches is less than 5 add
        matches+=$ex
      else
        # Find the longest string in the array
        longest_string=""
        index=0
        for string in "${matches[@]}"; do
          if [[ "$longest_string" == "" || "${#string}" -gt "${#longest_string}" ]]; then
            longest_string="$string"
            index=$index+1
          fi
        done
        if [[ "${#ex}" -lt "${#longest_string}" ]]; then
              matches[$index]=$ex # replace the longest string 
        fi
      fi
    fi
  done 
  echo "\n$matches\033[K" # print out at most the shortest 5 matches, clearing the rest of spaces
}


__CURRENT_INPUT=""

zle -N self-insert __update_command  
zle -N __remove_in_copy __remove_char # create a new zle widget to change default function of the delete
bindkey "^?" __remove_in_copy

__prepare_for_next(){
  __CURRENT_INPUT=""
}

# Only do these things the first time this file is sourced

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
      # add only the executable name
      executables+=("${file:t}") 
    fi
  done 
done  
