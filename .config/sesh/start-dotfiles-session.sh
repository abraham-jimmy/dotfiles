#!/usr/bin/env bash
set -euo pipefail

dotdir="$HOME/.config"
shell_path="${SHELL:-/bin/bash}"
shell_flags='-i'

case "$(basename "$shell_path")" in
  bash|zsh)
    shell_flags='-il'
    ;;
esac

if ! command -v tmux >/dev/null 2>&1; then
  cd "$dotdir"
  exec env NVIM_APPNAME=nvim-new nvim
fi

if [ -z "${TMUX:-}" ]; then
  cd "$dotdir"
  exec env NVIM_APPNAME=nvim-new nvim
fi

# Startup commands only run for new sessions, but keep reruns harmless.
if [ "$(tmux display-message -p '#{window_panes}')" -gt 1 ]; then
  tmux select-pane -L >/dev/null 2>&1 || true
  exit 0
fi

tmux split-window -d -h -c "$dotdir" "exec \"$shell_path\" $shell_flags"
tmux select-layout even-horizontal >/dev/null 2>&1 || true

cd "$dotdir"
exec env NVIM_APPNAME=nvim-new nvim
