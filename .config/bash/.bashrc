

############################### Source all files in a folder ###############################
# str="$(find ~/.jimmy_bash_stuff/ -type f -print)"
# arr=( $str )
# for f in "${arr[@]}"; do
#    [[ -f $f ]] && . $f --source-only || echo "$f not found"
# done

source ~/.config/bash/.colors
source ~/.config/bash/.aliases
source ~/.config/bash/.bashprompt.sh
source ~/.config/bash/.git-prompt.sh

############################### Save history through all tmux ###############################
# avoid duplicates..
export HISTCONTROL=ignoredups:erasedups

# append history entries..
shopt -s histappend

# After each command, save and reload history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

############################### Run startup function ###############################
# enter tmuxa when entering bash on the teamserver
# run_startup

if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
  tmux attach-session | tmux attach-session -t
fi

############################### one-liner to add alias in .bashrc ###############################
# echo "alias ALIAS_NAME='COMMAND_AND_OR_SCRIPT_DIR'"&>> ~/.bashrc.user

# Examples
# echo "alias ALIAS_NAME='/path/to/script/or/thing'"&>> ~/.bashrc.user


############################### cd stuff ###############################
# zoxide
eval "$(zoxide init bash --cmd cd)"
# fuzzyfinder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

