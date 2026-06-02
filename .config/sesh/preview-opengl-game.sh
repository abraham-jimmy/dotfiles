#!/usr/bin/env bash
set -euo pipefail

repo_dir="$HOME/Documents/git_repos/opengl_game"
cyan=$'\033[1;36m'
yellow=$'\033[1;33m'
reset=$'\033[0m'

printf '%bOPENGL GAME STATUS%b\n\n' "$cyan" "$reset"
/usr/bin/git -C "$repo_dir" -c color.status=always status -s

printf '\n%bOPENGL GAME LOG%b\n\n' "$yellow" "$reset"
/usr/bin/git -C "$repo_dir" log --graph --decorate --abbrev-commit --color=always --pretty='format:%C(yellow)%h%Creset %C(cyan)%cr%Creset %C(white)%s%Creset %C(auto)%d%Creset' -n 10
