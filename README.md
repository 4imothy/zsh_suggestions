This is a repository containing the src for zsh-completions.

ToDo:
* [ ] Implement path expansions for editors, cd, ...
* [x] Implement selections, ctrl+n: next, ctrl+p: prev
* [x] Read .zsh_history
* [x] Save the current input in a variable
* [x] Implement comparing against the current input with possible commands
* [x] Implement reading each character typed
* [x] Create go script to get the path info 

Issues:
* [x] When reading at bottom line and printing below tput rc puts the cursor on the bottom because that was prev position. It needs to move up the length of matches - space to bottom
