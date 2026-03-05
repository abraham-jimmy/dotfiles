#!/usr/bin/env bash
set -euo pipefail

setup_10_dotfiles() {
  local dotdir="$HOME/.dotfiles"
  local repo_https="https://github.com/abraham-jimmy/dotfiles.git"
  local repo_ssh="git@github.com:abraham-jimmy/dotfiles.git"
  local bootstrap_dotfiles="$HOME/.dotfiles-src"

  if [ ! -d "$dotdir" ]; then
    run "git clone --bare $repo_https $dotdir"
  fi

  dotfiles() {
    /usr/bin/git --git-dir="$dotdir/" --work-tree="$HOME" "$@"
  }

  run "dotfiles checkout"
  run "dotfiles config --local status.showUntrackedFiles no"
  run "dotfiles config user.name 'Jimmy Abraham'"
  run "dotfiles config user.email 'abrahamjimmy@hotmail.com'"

  if [ "${SSH_ENABLED:-0}" -eq 1 ]; then
    run "dotfiles remote set-url origin $repo_ssh"
  fi

  if [ -d "$bootstrap_dotfiles" ]; then
    run "rm -rf $bootstrap_dotfiles"
  fi
}
