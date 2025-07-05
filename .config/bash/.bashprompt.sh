
#!/bin/bash

# source ~/.config/bash/.colors
# source ~/.config/bash/.git-prompt.sh


GIT_PS1_SHOWUPSTREAM="auto"     # '<' behind, '>' ahead, '<>' diverged, '=' no difference
GIT_PS1_SHOWDIRTYSTATE=1        # staged '+', unstaged '*'
GIT_PS1_SHOWSTASHSTATE=1        # '$' something is stashed
GIT_PS1_SHOWUNTRACKEDFILES=1    # '%' untracked files
VAL=10


# Custom PS1 prompt with dynamic length pwd
function dynamic_pwd {
    local dir=$(pwd)
    local max_length=50  # Maximum length of the pwd to display

    if [[ ${#dir} -gt $max_length ]]; then
        dir="$(displayUnicode)$(echo $dir | tail -c $max_length)"
    fi

    echo "$dir"
}

dynamic_dir_length(){
    current_dir=$PWD
    # while [condition == "true"]; do
    #     if [${#$WORK_DIR} -gt 5]; then
    #         break
    #     else
    #         condition="false"
    #     fi

    # done
    while [[ ${#current_dir} -gt 5 ]]; do
        let "VAL-=1"
    done

    $current_dir=$current_dir | sed 's//*[/]/'


    #sed 's/*.\///' <<< 'hello/hej/he'
    PROMPT_DIRTRIM=$VAL
}

# happy_sad(){
# 	# Happy/sad
# 	if [ "$?" -eq "0" ]; then
# 		PS1+="[${GREEN}:)${DEFAULT}]-"
# 	else
# 		PS1+="[${RED}:(${DEFAULT}]-"
# 	fi
# }

function lastDigits {
    local num_digits=3
    local hostname_num=$(echo $(hostname) | grep -oE '[0-9]+')
    last_dig=${hostname_num: -$num_digits}
    echo $last_dig
}

function displayUnicode() {
    printf "\u2026"
}

my_PS1(){
	PS1="\n"
    # PS1+="┌─"
    # PS1+="─"
    PS1+="${BP_GRAY}\t${BP_DEFAULT} "

    #happy_sad

	# User
	PS1+="${BP_PINK}@$(lastDigits)${BP_DEFAULT} "

	# Working dir
	PS1+="${BP_DEFAULT}${BP_LIGHTBLUE}$(dynamic_pwd)"

	# Current git branch
	PS1+="${BP_RED}\$(__git_ps1)${BP_DEFAULT}"

	# New line and arrow
	# PS1+="${BP_DEFAULT}\n└─▶ "
	PS1+="${BP_DEFAULT}\n▶ "

    export PS1
}

PROMPT_COMMAND=my_PS1
