my-self-insert() {
  zle .$WIDGET
  local key="${BUFFER: -1}"
  CURRENT_INPUT="${CURRENT_INPUT}${key}"
  echo "${CURRENT_INPUT}"
}

CURRENT_INPUT=""

zle -N self-insert my-self-insert
