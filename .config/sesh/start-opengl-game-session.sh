#!/usr/bin/env bash
set -euo pipefail

repo_dir="$HOME/Documents/git_repos/opengl_game"
shell_path="${SHELL:-/bin/bash}"
shell_flags='-i'

case "$(basename "$shell_path")" in
  bash|zsh)
    shell_flags='-il'
    ;;
esac

if ! command -v tmux >/dev/null 2>&1; then
  cd "$repo_dir"
  exec opencode
fi

if [ -z "${TMUX:-}" ]; then
  cd "$repo_dir"
  exec opencode
fi

# Startup commands only run for new sessions, but keep reruns harmless.
if [ "$(tmux display-message -p '#{window_panes}')" -gt 1 ]; then
  tmux select-pane -L >/dev/null 2>&1 || true
  exit 0
fi

right_pane="$(tmux split-window -d -h -c "$repo_dir" -P -F '#{pane_id}' "exec nvim")"
tmux split-window -d -v -l 10 -c "$repo_dir" "exec \"$shell_path\" $shell_flags"
tmux resize-pane -t "$right_pane" -x 150 >/dev/null 2>&1 || true

cd "$repo_dir"
exec opencode
