#!/bin/zsh

# change this to allow for more/less suggestions
# if __MAX_LENGTH is 1 suggestions will only be printed
# suggestions after the first will be printed below
__MAX_LENGTH=6
__INLINE_PRINTING_FG=7 # this is the color of the inline completions
__DEFAULT_FG=4 # change this to the color you want your typed text to be
__SELECTED_FG="\033[30m"
# __SELECTED_BG="\033[46m" # uncomment this to give the selected a background
__MATCHED_FG="\033[37m"

__insert=true
 
function __set_fut_pos(){ 
  local space=$(($(tput lines) - __fut_row))
  local num_printed=$(($#__matches - 1))

  if [[ num_printed -ge $space ]]; then # if length is greater than space
    ((__fut_row-=$(( num_printed - space ))))  # move up length - space
    ((__fut_row--))
  fi
}
 
function __keypress() {
  POSTDISPLAY=""
  zle .$WIDGET
  __match_input
  __apply_highlighting
}

function __delete() {
  # remove the last character from buffer
  POSTDISPLAY=""
  zle backward-delete-char
  __match_input
  __apply_highlighting
}

function __match_input(){

  reset_selected_index # clear out the previous selection
  __current_input=$BUFFER
  __prev_length=$#__matches
  __matches=()
  __get_cur_pos
  if [ $#__current_input -eq 0 ]; then
    __clear_if_no_input
    tput cup $__fut_row $__fut_col
    return
  fi 
  __match_possibles
  __set_fut_pos
  __print_matches
  # remove the first ${#BUFFER} characters from __matches[1] 
  local first=${__matches[1]:$#__current_input}
  tput cup $__fut_row $__fut_col
  POSTDISPLAY=$first
}

function __clear_if_no_input(){
  # this is two because the first is the inline
  while [ $__prev_length -ge 2 ] 
    do
      echo -n "\n\033[K"
      ((__prev_length--))
    done
}

function __apply_highlighting() {
  region_highlight=()
  region_highlight=("P0 $#BUFFER fg=$__DEFAULT_FG")
	if [ $#POSTDISPLAY -gt 0 ]; then
    region_highlight+=("$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) fg=$__INLINE_PRINTING_FG")
  fi
}      

function __match_possibles(){
  # if there are no typed words, then clear the output and return
  for ex in "${__possibles[@]}"; do
    # if it matches the current input and is longer, to not print what is currently typed
    if [[ "$ex" == "$__current_input"* && ${#ex} -gt ${#__current_input} ]]; then 
      if [ $#__matches -lt $__MAX_LENGTH ]; then # if the length of matches is less than 5 add
        __matches+=$ex
      else
        # Find the longest string in the array
        longest_string=""
        index=0
        long_ind=0
        for string in "${__matches[@]}"; do
          index=$((index+1))
          if [ $#string -gt $#longest_string ]; then
            longest_string="$string"
            long_ind=($index)
          fi
        done
        if [ $#ex -lt $#longest_string ]; then
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
  for ((i=2; i<=${#__matches[@]}; i+=1)); do 
    if [ $i -eq $__selected_index ]; then
      echo -n "\n$__SELECTED_BG$__SELECTED_FG$__matches[$i]\033[39m\033[49m\033[K" # print out the selected match with colored background
    else
      echo -n "$__MATCHED_FG\n$__matches[$i]\033[K" # print out matches
    fi
  done 
  # if the matches have less then the previous number in matches then print out blank lines
  local remaining=$((__prev_length - i)) 
  while [ $remaining -ge 0 ] 
  do
    echo -n "\n\033[K"
    ((remaining--))
  done
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
  # POSTDISPLAY=""
  POSTDISPLAY=""

  if [ $#__matches -eq 0 ]; then
    return
  fi

  __selected_index=$(($__selected_index % ${#__matches} + 1))

  __print_selection
}

function __select_previous(){ 
  POSTDISPLAY=""
  if [ $#__matches -eq 0 ]; then
    return
  fi

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
  __apply_highlighting
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
zmodload zsh/mapfile
__possibles=("${(f@)mapfile[$HISTFILE]}") 
__matches=()
typeset -U __matches # make it a set

zle -N self-insert __keypress 
zle -N __remove __delete
zle -N __next __select_next
zle -N __prev __select_previous
bindkey "^?" __remove
bindkey "^P" __prev
bindkey "^N" __next

# add the following to possibles to match against
__possibles+=("${(k)commands[@]}")
__possibles+=("${(k)builtins[@]}")
__possibles+=("${(k)aliases[@]}")
__possibles+=("${(k)functions[@]}") 
typeset -U __possibles
