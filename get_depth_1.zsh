#!/bin/zsh

# loop through all files and directories at depth 1 of the current directory
for file in ./*; do
  # check if the file is a directory
  if [[ -d $file ]]; then
    echo "$file (directory)"
  else
    echo "$file (file)"
  fi
done

