#!/usr/bin/zsh
 
__update_command() {
  zle .$WIDGET
  local key="${KEYS[-1]}"
  __current_input="${BUFFER}"
  tput sc
  # echo ${${(s: :)CURSOR_POS}[1]} ${${(s: :)CURSOR_POS}[2]}
  # tput sc
  __set_fut_pos
  __show_matches
  tput cup $__fut_row $__fut_col
}

__remove_char() {
  zle backward-delete-char # remove the last character
  __current_input="${BUFFER}"
  __set_fut_pos
  __show_matches
  tput cup $__fut_row $__fut_col
}

function __show_matches(){
  # if there are no typed words, then clear the output and return
  if [[ ${#__current_input} -eq 0 ]]; then
    echo -n "\n\033[K"
    return
  fi 
  matches=()
  for ex in "${executables[@]}"; do
    if [[ "$ex" == "$__current_input"* ]]; then
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
  echo -n "\n$matches\033[K" # print out at most the shortest 5 matches, clearing the rest of spaces 
} 
 

function __set_fut_pos(){
  echo -ne "\033[6n"
  read -t 1 -s -d 'R' line < /dev/tty
  line="${line##*\[}"
  __fut_row=$((${line%%;*})) # extract the row number
  __fut_col=$((${line##*;}-1)) # extract the column number

  if [[ __fut_row -eq $(tput lines) ]]; then
  ((__fut_row-=1)) # subtract an extra when at the bottom the line moves up
  fi

  ((__fut_row-=1))
}
 
__current_input=""
__fut_row=""
__fut_col=""

zle -N self-insert __update_command  
zle -N __remove_in_copy __remove_char # change the action of delete key to deleting most recent and updating __current_input
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
