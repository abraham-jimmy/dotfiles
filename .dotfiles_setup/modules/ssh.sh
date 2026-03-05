#!/usr/bin/env bash
set -euo pipefail

github_ssh_ok() {
  set +e
  out="$(ssh -T git@github.com 2>&1)"
  set -e
  echo "$out" | grep -q "successfully authenticated"
}

setup_90_ssh_prompt() {

  echo
  echo "Checking GitHub SSH authentication..."

  if github_ssh_ok; then
    echo "[INFO] SSH key to GitHub already configured."
    SSH_ENABLED=1
    export SSH_ENABLED
    return
  else
    echo "[INFO] No SSH key configured for GitHub."
  fi

  echo
  read -rp "Setup SSH key for GitHub? (yes/no): " answer
  [ "$answer" = "yes" ] || return

  local key="$HOME/.ssh/id_ed25519"

  run "mkdir -p $HOME/.ssh"
  run "chmod 700 $HOME/.ssh"

  if [ ! -f "$key" ]; then
    run "ssh-keygen -t ed25519 -C 'abrahamjimmy@hotmail.com' -f $key -N ''"
  fi

  echo
  echo "Add this SSH key to GitHub:"
  echo
  cat "${key}.pub"
  echo

  while true; do
    read -rp "Type 'yes' after adding the key to GitHub: " confirm
    [ "$confirm" = "yes" ] && break
  done

  echo
  echo "Verifying GitHub SSH authentication..."

  if github_ssh_ok; then
    echo "[INFO] SSH key successfully configured for GitHub."
    SSH_ENABLED=1
    export SSH_ENABLED
  else
    echo "[WARN] GitHub SSH authentication still not working."
    echo "Try running manually:"
    echo "ssh -T git@github.com"
  fi

  if [ -d "$HOME/.dotfiles-src" ]; then
    git -C "$HOME/.dotfiles-src" remote set-url origin git@github.com:abraham-jimmy/dotfiles.git || true
  fi
}
