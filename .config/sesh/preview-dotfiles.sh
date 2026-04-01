#!/usr/bin/env bash
set -euo pipefail

cyan=$'\033[1;36m'
yellow=$'\033[1;33m'
reset=$'\033[0m'

printf '%bDOTFILES STATUS%b\n\n' "$cyan" "$reset"
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" -c color.status=always status -s

printf '\n%bDOTFILES LOG%b\n\n' "$yellow" "$reset"
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" log --graph --decorate --abbrev-commit --color=always --pretty='format:%C(yellow)%h%Creset %C(cyan)%cr%Creset %C(white)%s%Creset %C(auto)%d%Creset' -n 10
