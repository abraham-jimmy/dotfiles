#!/usr/bin/env bash
set -euo pipefail

setup_10_dotfiles() {
  local dotdir="$HOME/.dotfiles"
  local repo_https="https://github.com/abraham-jimmy/dotfiles.git"
  local repo_ssh="git@github.com:abraham-jimmy/dotfiles.git"
  local bootstrap_dotfiles="$HOME/.dotfiles-src"
  local status_untracked current_name current_email current_origin
  local worktree_ready=0 config_ready=0 remote_ready=1 first_install=0

  if [ ! -d "$dotdir" ]; then
    first_install=1
    run "git clone --bare $repo_https $dotdir"
  fi

  dotfiles() {
    /usr/bin/git --git-dir="$dotdir/" --work-tree="$HOME" "$@"
  }

  if [ "$first_install" -eq 1 ]; then
    info "planning initial dotfiles checkout and repo config"
    run "dotfiles checkout"
    run "dotfiles config --local status.showUntrackedFiles no"
    run "dotfiles config user.name 'Jimmy Abraham'"
    run "dotfiles config user.email 'abrahamjimmy@hotmail.com'"

    if [ "${SSH_ENABLED:-0}" -eq 1 ]; then
      run "dotfiles remote set-url origin $repo_ssh"
    fi

    return
  fi

  if [ -f "$HOME/.config/shell/dotfiles.sh" ]; then
    worktree_ready=1
  fi

  status_untracked="$(dotfiles config --local --get status.showUntrackedFiles 2>/dev/null || true)"
  current_name="$(dotfiles config --get user.name 2>/dev/null || true)"
  current_email="$(dotfiles config --get user.email 2>/dev/null || true)"

  if [ "$status_untracked" = "no" ] && [ "$current_name" = "Jimmy Abraham" ] && [ "$current_email" = "abrahamjimmy@hotmail.com" ]; then
    config_ready=1
  fi

  if [ "${SSH_ENABLED:-0}" -eq 1 ]; then
    current_origin="$(dotfiles remote get-url origin 2>/dev/null || true)"
    if [ "$current_origin" != "$repo_ssh" ]; then
      remote_ready=0
    fi
  fi

  if [ "$worktree_ready" -eq 1 ] && [ "$config_ready" -eq 1 ] && [ "$remote_ready" -eq 1 ]; then
    skip "dotfiles repo already checked out and configured"
    return
  fi

  if [ "$worktree_ready" -eq 0 ]; then
    info "checking out dotfiles work tree"
    run "dotfiles checkout"
  else
    skip "dotfiles work tree already checked out"
  fi

  if [ "$status_untracked" != "no" ]; then
    run "dotfiles config --local status.showUntrackedFiles no"
  else
    skip "dotfiles status.showUntrackedFiles already set to no"
  fi

  if [ "$current_name" != "Jimmy Abraham" ]; then
    run "dotfiles config user.name 'Jimmy Abraham'"
  else
    skip "dotfiles user.name already configured"
  fi

  if [ "$current_email" != "abrahamjimmy@hotmail.com" ]; then
    run "dotfiles config user.email 'abrahamjimmy@hotmail.com'"
  else
    skip "dotfiles user.email already configured"
  fi

  if [ "${SSH_ENABLED:-0}" -eq 1 ]; then
    if [ "$remote_ready" -eq 0 ]; then
      run "dotfiles remote set-url origin $repo_ssh"
    else
      skip "dotfiles origin already uses SSH"
    fi
  fi

  # Can't delete before installation is complete, not sure how to solve
  # if [ -d "$bootstrap_dotfiles" ]; then
  #   run "rm -rf $bootstrap_dotfiles"
  # fi
}
