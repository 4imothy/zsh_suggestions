#!/usr/bin/zsh
 
__update_command() {
  zle .$WIDGET
  local key="${KEYS[-1]}"
  __CURRENT_INPUT="${BUFFER}"
  tput sc
  __find_matches
  tput rc
}

__remove_char() {
  zle backward-delete-char # remove the last character
  __CURRENT_INPUT="${BUFFER}"
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
      # echo $ex
      # if [[ $ex == "source" ]]; then
      #   echo "found $ex"
      # fi
      if [[ "${#matches}" -lt 5 ]]; then # if the length of matches is less than 5 add
        matches+=$ex
      else
        # Find the longest string in the array
        longest_string=""
        index=0
        long_ind=0
        for string in "${matches[@]}"; do
          index=$((index+1))
          if [[ "${#string}" -gt "${#longest_string}" ]]; then
            longest_string="$string"
            long_ind=($index)
          fi
        done
        if [[ "${#ex}" -lt "${#longest_string}" ]]; then
              matches[$long_ind]=$ex # replace the longest string 
        fi
      fi
    fi
  done 
  echo "\n$matches\033[K" # print out at most the shortest 5 matches, clearing the rest of spaces 
} 

__CURRENT_INPUT=""

zle -N self-insert __update_command  
zle -N __remove_in_copy __remove_char # change the action of delete key to deleting most recent and updating __CURRENT_INPUT
bindkey "^?" __remove_in_copy
 
# below only happen when file is sourced

local executables=()

# loop through $commands instead of path
for com in $commands; do
  executables+=("${com:t}")
done
# add all the builtins, cd, source,...
for cmd in ${(k)builtins}; do 
  executables+=$cmd
done 
# loop through all the aliases and add them to the array
for alias in ${(k)aliases}; do
    executables+=("$alias")
done 
# loop through all the functions and add them to the array
for func in ${(k)functions}; do
    executables+=("$func")
done 

# Loop through each directory in the path
# for directory in ${(s/:/)${PATH}}; do

#   # Loop through each file in the directory
#   for file in "${directory}"/*(N); do

#     # Check if the file is executable
#     if [[ -x "${file}" ]]; then 
#       # add only the executable name
#       executables+=("${file:t}") 
#     fi
#   done 
# done  
