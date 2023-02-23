#!/usr/bin/zsh
 
function __keypress() {
  zle .$WIDGET
  __match_input
}

function __delete() {
  zle backward-delete-char # remove the last character
  __match_input
}

function __match_input(){
  __current_input="${BUFFER}"
  __get_cur_pos
  __find_matches
  __set_fut_pos
  __print_matches
  tput cup $__fut_row $__fut_col
}

function __find_matches(){
  __prev_length="${#__matches}"
  __matches=()
  # if there are no typed words, then clear the output and return
  if [[ ${#__current_input} -eq 0 ]]; then
    while [ $__prev_length -ge 1 ] 
    do
      echo -n "\n\033[K"
      ((__prev_length--))
    done
    return
  fi 
  for ex in "${__executables[@]}"; do
    if [[ "$ex" == "$__current_input"* ]]; then
      # if [[ $ex == "source" ]]; then
      #   echo "found $ex"
      # fi
      if [[ "${#__matches}" -lt __MAX_LENGTH ]]; then # if the length of matches is less than 5 add
        __matches+=$ex
      else
        # Find the longest string in the array
        longest_string=""
        index=0
        long_ind=0
        for string in "${__matches[@]}"; do
          index=$((index+1))
          if [[ "${#string}" -gt "${#longest_string}" ]]; then
            longest_string="$string"
            long_ind=($index)
          fi
        done
        if [[ "${#ex}" -lt "${#longest_string}" ]]; then
              __matches[$long_ind]=$ex # replace the longest string 
        fi
      fi
    fi
  done 

  # short so shortest is first
  __matches=("${(@f)$(printf '%s\n' "${__matches[@]}" | awk '{ print length, $0 }' | sort -n | cut -d ' ' -f 2-)}") 

  unset string
  unset index
  unset long_ind
  unset longest_string
} 

function __print_matches(){
  for ((i=1; i<=${#__matches[@]}; i+=1)); do 
    echo -n "\n$__matches[$i]\033[K" # print out matches
  done 
  # if the matches have less then the previous number in matches then print out blank lines
  remaining=$((__prev_length - i)) 
  while [ $remaining -ge 0 ] 
  do
    echo -n "\n\033[K"
    ((remaining--))
  done
  unset remaining
}
  
function __set_fut_pos(){ 
  space=$(($(tput lines) - __fut_row))
  if [[ ${#__matches[@]} -ge $space ]]; then # if length is greater than space
    ((__fut_row-=$((${#__matches} - space ))))  # move up length - space
    ((__fut_row--))
  fi
  unset space
} 

function __get_cur_pos(){
  echo -ne "\033[6n"
  read -t 1 -s -d 'R' line < /dev/tty
  line="${line##*\[}"
  __fut_row=$((${line%%;*}-1)) # extract the row number
  __fut_col=$((${line##*;}-1)) # extract the column number 
  unset line
}

# below only happen when file is sourced at beginning of session
__MAX_LENGTH=5 # change this to allow for more suggestions
__current_input=""
__fut_row=""
__fut_col=""
__executables=()

zle -N self-insert __keypress 
zle -N __remove_in_copy __delete # change the action of delete key to deleting most recent and updating __current_input
bindkey "^?" __remove_in_copy

# loop through $commands instead of path
for com in $commands; do
  __executables+=("${com:t}")
done
# add all the builtins, cd, source,...
for cmd in ${(k)builtins}; do 
  __executables+=$cmd
done 
# loop through all the aliases and add them to the array
for alias in ${(k)aliases}; do
  __executables+=("$alias")
done 
# loop through all the functions and add them to the array
for func in ${(k)functions}; do
  __executables+=("$func")
done 