#!/usr/bin/env bash
set -euo pipefail

github_ssh_ok() {
  set +e
  out="$(ssh -T git@github.com 2>&1)"
  set -e
  echo "$out" | grep -q "successfully authenticated"
}

setup_90_ssh_prompt() {
  local answer confirm
  local key="$HOME/.ssh/id_ed25519"

  info "checking GitHub SSH authentication"

  if github_ssh_ok; then
    done_log "SSH key to GitHub already configured"
    SSH_ENABLED=1
    export SSH_ENABLED
    return
  fi

  warn "No SSH key configured for GitHub"

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    plan "would prompt for GitHub SSH setup and verify access"
    return
  fi

  read -rp "Setup SSH key for GitHub? (yes/no): " answer
  if [ "$answer" != "yes" ]; then
    skip "skipping GitHub SSH setup"
    return
  fi

  run "mkdir -p $HOME/.ssh"
  run "chmod 700 $HOME/.ssh"

  if [ ! -f "$key" ]; then
    run "ssh-keygen -t ed25519 -C 'abrahamjimmy@hotmail.com' -f $key -N ''"
  fi

  info "Add this SSH key to GitHub:"
  show_text "$(<"${key}.pub")"

  while true; do
    read -rp "Type 'yes' after adding the key to GitHub: " confirm
    [ "$confirm" = "yes" ] && break
  done

  info "verifying GitHub SSH authentication"

  if github_ssh_ok; then
    done_log "SSH key successfully configured for GitHub"
    SSH_ENABLED=1
    export SSH_ENABLED
  else
    warn "GitHub SSH authentication still not working"
    info "Try running manually:"
    show_text "ssh -T git@github.com"
  fi

  if [ -d "$HOME/.dotfiles-src" ]; then
    run "git -C \"$HOME/.dotfiles-src\" remote set-url origin git@github.com:abraham-jimmy/dotfiles.git" || true
  fi
}
