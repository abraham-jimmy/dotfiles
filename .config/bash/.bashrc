

############################### Source all files in bash_stuff folder ###############################
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
# echo "alias ALIAS_NAME='/proj/crbs/user/TeamCore/scripts/sdc_script.sh'"&>> ~/.bashrc.user
# echo "alias comp_db='/proj/crbs/user/TeamCore/enilseb/scripts/compile_commands_cd.sh'"&>> ~/.bashrc.user


###### vs-code hook #####
# VSCODE_IPC_HOOK_CLI="/run/$USER/7472306/vscode-ipc-553a1c67-c5da-432f-8bbe-c14d79c5f132.sock"
# source ~/.connect_vscode.sh
# alias code=$'VSCODE_IPC_HOOK_CLI=/run/user/`id -u`/$(ls -lt /run/user/`id -u`/ | egrep \.sock$ | head -1 | awk \'END {print $NF}\') `ls -lt ~/.vscode-server/bin/** | fgrep bin/remote-cli/code | head -1 | awk \'END {print $NF}\'`'

############################### cd stuff ###############################
# zoxide
eval "$(zoxide init bash --cmd cd)"
# fuzzyfinder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

