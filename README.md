#### ZSH-AutoSuggestions

This is a repository containing the src for zsh-completions.

**How to Use**
- Copy the *auto_suggestions.zsh* file and source it. *curl -O https://raw.githubusercontent.com/4tlc/zsh_suggestions/main/auto_suggestions.zsh*
- Or to source it once without copying to machine run *source <(curl  https://raw.githubusercontent.com/4tlc/zsh_suggestions/main/auto_suggestions.zsh)*
- Begin typing and prompts will appear below the prompt
- Use *ctrl+n* to select the next and *ctrl+p* to select the previous

**Customizations**
- In editing *auto_suggestions.zsh*
- Change *__MAX_LENGTH* to change the number of the maximum number of matched items to print
- Change *__SELECTED_BG* and *__SELECTED_FG* to change the styling of the currently selected item
- Change *__MATCHED_FG* to change the styling of the non-selected matched items

**Demo Video**


https://user-images.githubusercontent.com/40186632/221368741-5c9897eb-148b-4e5c-b309-93aa7d96f1fa.mp4


**ToDo:**
* [ ] Implement inline expansion for the first suggestion
* [ ] Implement path expansions for editors, cd, ...
* [x] Implement selections, ctrl+n: next, ctrl+p: prev
* [x] Read .zsh_history
* [x] Save the current input in a variable
* [x] Implement comparing against the current input with possible commands
* [x] Implement reading each character typed
* [x] Get all executables, aliases, functions, builtins

**Issues:**
* [x] When reading at bottom line and printing below tput rc puts the cursor on the bottom because that was prev position. It needs to move up the length of matches - space to bottom
