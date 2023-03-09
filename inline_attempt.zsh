#!/bin/zsh

__MAX_LENGTH=5 # change this to allow for more/less suggestions
__SELECTED_FG="\033[30m"
__SELECTED_BG="\033[46m"
__MATCHED_FG="\033[30m"
__INLINE_PRINTING_FG="\033[96m"
__DEFAULT_FG="\033[34m" # change this to the color you want your typed text to be
 
function __set_fut_pos(){ 
  space=$(($(tput lines) - __fut_row))
  if [[ ${#__matches[@]} -ge $space ]]; then # if length is greater than space
    ((__fut_row-=$((${#__matches} - space ))))  # move up length - space
    ((__fut_row--))
  fi
  unset space
}
 
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
  __prev_length="${#__matches}"
  __matches=()
  __get_cur_pos
  if [[ ${#__current_input} -eq 0 ]]; then
    __clear_if_no_input
    tput cup $__fut_row $__fut_col
    return
  fi 
  __match_possibles
  __set_fut_pos
  __print_matches
  tput cup $__fut_row $((__fut_col + 1))
  # remove the characters that are in matched and buffer
  # remove the first ${#BUFFER} characters from __matches[1]
  len="${#BUFFER}"
  first=$__matches[1]
  first=${__matches[1]:$len} 
  echo -en "$__INLINE_PRINTING_FG$first$__DEFAULT_FG"
  tput cup $__fut_row $__fut_col
  unset len
  unset first
}

function __clear_if_no_input(){
  while [ $__prev_length -ge 1 ] 
    do
      echo -n "\n\033[K"
      ((__prev_length--))
    done
}

      
function __match_possibles(){
  # if there are no typed words, then clear the output and return
  for ex in "${__possibles[@]}"; do
    if [[ "$ex" == "$__current_input"* ]]; then
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
    if [[ $i == $__selected_index ]]; then
      echo -n "\n$__SELECTED_BG$__SELECTED_FG$__matches[$i]\033[39m\033[49m\033[K" # print out the selected match with colored background
    else
      echo -n "$__MATCHED_FG\n$__matches[$i]\033[K" # print out matches
    fi
  done 
  # if the matches have less then the previous number in matches then print out blank lines
  remaining=$((__prev_length - i)) 
  while [ $remaining -ge 0 ] 
  do
    echo -n "\n\033[K"
    ((remaining--))
  done
  unset remaining
  echo -n "$__DEFAULT_FG"
}

function __get_cur_pos(){
  echo -ne "\033[6n"
  read -t 1 -s -d 'R' line < /dev/tty
  line="${line##*\[}"
  __fut_row=$((${line%%;*}-1)) # extract the row number
  __fut_col=$((${line##*;}-1)) # extract the column number 
  unset line
}

function __select_next(){
  if [[ ${#__matches} -eq 0 ]]; then
    return
  fi

  __selected_index=$((((((__selected_index)) % ${#__matches})) + 1))

  __print_selection
}

function __select_previous(){
  if [[ ${#__matches} -eq 0 ]]; then
    return
  fi

  # 0 -> len 
  # len -> len - 1
  # len - 1 -> len - 2
  # __selected_index=${$(($((((__selected_index % ${#__matches})) - 1))))#-}
  ((__selected_index--))
  if [[ $__selected_index -eq -1 || $__selected_index -eq 0 ]]; then
    __selected_index=${#__matches}
  fi 
  
  __print_selection
}

function __print_selection(){
  __get_cur_pos
  __print_matches
  tput cup $__fut_row $__fut_col # add the to_replace - current_input
  LBUFFER=$__matches[$__selected_index]
  RBUFFER=""
}

function reset_selected_index(){
  __selected_index=0
}

if [[ ! "$precmd_functions" == *reset_selected_index* ]]; then
    precmd_functions+=(reset_selected_index)
fi


__selected_index=0
__current_input=""
__fut_row=""
__fut_col=""
# __idx_selected=0
zmodload zsh/mapfile
#__hist=("${(f@)mapfile[test.txt]}") 
__possibles=("${(f@)mapfile[$HISTFILE]}") 
__matches=()
typeset -U __matches # make it a set

zle -N self-insert __keypress 
zle -N __remove_in_copy __delete # change the action of delete key to deleting most recent and updating __current_input
zle -N __next __select_next
zle -N __prev __select_previous
bindkey "^?" __remove_in_copy
bindkey "^P" __prev
bindkey "^N" __next

# add the following to possibles to match against
__possibles+=("${(k)commands[@]}")
__possibles+=("${(k)builtins[@]}")
__possibles+=("${(k)aliases[@]}")
__possibles+=("${(k)functions[@]}")

typeset -U __possibles
# remove duplicates # loop through $commands
# for com in $commands; do
#   # take the last in the path, the name
#   __possibles+=("${com:t}")
# done
# add all the builtins, cd, source,...
# for cmd in ${(k)builtins}; do 
#   __possibles+=$cmd
# done 
# loop through all the aliases and add them to the array
# for alias in ${(k)aliases}; do
#   __possibles+=$alias
# done 
# loop through all the functions and add them to the array
# for func in ${(k)functions}; do
#   __possibles+=$func
# done
