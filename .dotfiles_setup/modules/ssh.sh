#!/usr/bin/env bash
set -euo pipefail

github_ssh_ok() {
  local out

  set +e
  out="$(ssh \
    -o BatchMode=yes \
    -o ConnectTimeout=5 \
    -o ConnectionAttempts=1 \
    -o StrictHostKeyChecking=accept-new \
    -T git@github.com 2>&1)"
  set -e
  [[ "$out" == *"successfully authenticated"* ]]
}

use_dotfiles_ssh_remote() {
  local repo="$HOME/.dotfiles"

  [ -d "$repo" ] || return
  run "/usr/bin/git --git-dir=\"$repo\" --work-tree=\"$HOME\" remote set-url origin git@github.com:abraham-jimmy/dotfiles.git"
}

setup_90_ssh_prompt() {
  local answer confirm
  local key="$HOME/.ssh/id_ed25519"

  info "checking GitHub SSH authentication"

  if [ "${DEBUG:-0}" -eq 1 ]; then
    plan "would check GitHub SSH authentication and optionally configure a key"
    return
  fi

  if github_ssh_ok; then
    done_log "SSH key to GitHub already configured"
    SSH_ENABLED=1
    export SSH_ENABLED
    use_dotfiles_ssh_remote
    return
  fi

  warn "No SSH key configured for GitHub"

  if ! prompt_read answer "Setup SSH key for GitHub? (yes/no): "; then
    skip "interactive input unavailable; skipping optional GitHub SSH setup"
    return 0
  fi
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
    prompt_read confirm "Type 'yes' after adding the key to GitHub: " || return 1
    [ "$confirm" = "yes" ] && break
  done

  info "verifying GitHub SSH authentication"

  if github_ssh_ok; then
    done_log "SSH key successfully configured for GitHub"
    SSH_ENABLED=1
    export SSH_ENABLED
    use_dotfiles_ssh_remote
  else
    warn "GitHub SSH authentication still not working"
    info "Try running manually:"
    show_text "ssh -T git@github.com"
  fi

}
