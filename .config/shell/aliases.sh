#! /usr/bin/env bash

# Export for opencode to use edit mode
export EDITOR=nvim

alias vi='nvim'
alias n='nvim'
alias oc='opencode'

alias ll='ls -lAth'
alias ..='cd ..'

alias ds='dotsetup'
alias nva='nvim ~/.config/shell/aliases.sh'
alias nvb='nvim ~/.config/bash/.bashrc'
alias nvg='nvim ~/.config/git/git_aliases'
alias nvn='nvim ~/.config/nvim/init.lua'
alias nvs='nvim ~/.dotfiles_setup/setup.sh'
alias nvt='nvim ~/.config/tmux/tmux.conf'
alias nvz='nvim ~/.config/zsh/.zshrc'

nnew() {
	NVIM_APPNAME=nvim-new nvim "$@"
}

unalias gau 2>/dev/null
gau() {
	git add -u
	echo -e ${GREEN}"- Added files to commit"${DEFAULT}
	git status
}

gbc() {
	git blame --color-by-age "$1"
}

t() {
	local session="${1:-main}"

	if ! command -v tmux >/dev/null 2>&1; then
		printf 'tmux is not installed\n' >&2
		return 1
	fi

	if ! tmux has-session -t "$session" 2>/dev/null; then
		tmux new-session -d -s "$session"
	fi

	if [[ -n "$TMUX" ]]; then
		tmux switch-client -t "$session"
	else
		tmux attach-session -t "$session"
	fi
}

dotsetup() {
	bash "$HOME/.dotfiles_setup/setup.sh" "$@"
}

run_startup() {
	read -n1 -s -r -p $'Press enter to enter tmux ...\n' key

	if [[ -z "$key" ]]; then
		t
	else
		echo "leaving script"
	fi
}

mkdird() {
	local folder_name
	folder_name=$(date +"%d%h_%H%M")

	if [[ -n "$1" ]]; then
		folder_name+="_$1"
	fi

	mkdir "$folder_name"
	ll
}

syncAiResources() {
	local client_root resource source_dir target_dir resource_path resource_name

	for client_root in "$HOME/.config/opencode" "$HOME/.config/claude"; do
		for resource in commands skills; do
			source_dir="$HOME/.config/ai/$resource"
			target_dir="$client_root/$resource"
			mkdir -p "$target_dir"

			for resource_path in "$source_dir"/*; do
				[[ -e "$resource_path" ]] || continue
				resource_name="${resource_path##*/}"
				rm -rf "$target_dir/$resource_name"
				ln -s "$resource_path" "$target_dir/$resource_name"
			done
		done
	done
}
