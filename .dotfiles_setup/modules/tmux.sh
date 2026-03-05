#!/usr/bin/env bash
set -euo pipefail

setup_20_tmux() {
  local tpm="$HOME/.config/tmux/plugins/tpm"

  run "mkdir -p $HOME/.config/tmux/plugins"

  if [ ! -d "$tpm" ]; then
    run "git clone https://github.com/tmux-plugins/tpm $tpm"
  fi

  run "$tpm/bin/install_plugins"

  if pgrep tmux >/dev/null 2>&1; then
    run "tmux kill-server"
  fi
}
