#!/usr/bin/env bash
set -euo pipefail

PROGRAMS=(
  "git:git:10"
  "curl:curl:10"
  "unzip:unzip:10"
  "ssh:openssh:10"
  "zsh:zsh:20"
  "node:nodejs:20"
  "npm:npm:20"
  "tmux:tmux:30"
  "fzf:fzf:30"
  "zoxide:zoxide:30"
  "rg:ripgrep:30"
)

install_all_programs() {
  local lines=()
  local entry cmd program prio rest

  for entry in "${PROGRAMS[@]}"; do
    cmd="${entry%%:*}"
    rest="${entry#*:}"
    program="${rest%%:*}"
    prio="${entry##*:}"
    lines+=("${prio}:${cmd}:${program}")
  done

  IFS=$'\n' read -r -d '' -a sorted < <(printf '%s\n' "${lines[@]}" | sort -n && printf '\0')

  for entry in "${sorted[@]}"; do
    rest="${entry#*:}"
    cmd="${rest%%:*}"
    program="${rest##*:}"
    ensure_program "$cmd" "$program"
  done
}
