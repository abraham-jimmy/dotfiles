#!/usr/bin/env bash

set -eu

path="${1:-}"
[ -n "$path" ] || exit 0

branch="$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)" || exit 0
[ -n "$branch" ] || exit 0

printf ' %s ' "#[fg=#{@theme_git_bg},bg=#{@theme_bar_bg}]#{@left_separator}#[fg=#{@theme_git_fg},bg=#{@theme_git_bg}]@$branch#[fg=#{@theme_git_bg},bg=#{@theme_bar_bg}]#{@right_separator}"
