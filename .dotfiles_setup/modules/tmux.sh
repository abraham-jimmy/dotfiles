#!/usr/bin/env bash
set -euo pipefail

confirm_tmux_restart() {
  local restart_mode response

  restart_mode="${RESTART_TMUX_ON_PLUGIN_CHANGE:-ask}"
  case "$restart_mode" in
    yes|YES|true|TRUE|1)
      return 0
      ;;
    no|NO|false|FALSE|0)
      return 1
      ;;
  esac

  if [ ! -t 0 ]; then
    warn "tmux plugins changed, but setup is non-interactive; skipping tmux restart (set RESTART_TMUX_ON_PLUGIN_CHANGE=yes to force it)"
    return 1
  fi

  info "tmux plugins were updated; restarting the tmux server is recommended"
  read -rp "Restart tmux server now? ([Y]es/no): " response
  case "$response" in
    ""|y|Y|yes|YES)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

tmux_plugins_snapshot() {
  local plugins_dir="$HOME/.config/tmux/plugins"
  local dir head

  [ -d "$plugins_dir" ] || return 0

  for dir in "$plugins_dir"/*; do
    [ -d "$dir" ] || continue

    if [ -d "$dir/.git" ]; then
      head="$(git -C "$dir" rev-parse HEAD 2>/dev/null || true)"
      printf '%s\t%s\n' "$(basename "$dir")" "$head"
    else
      printf '%s\t%s\n' "$(basename "$dir")" "no-git"
    fi
  done | sort
}

setup_20_tmux() {
  local tpm="$HOME/.config/tmux/plugins/tpm"
  local before_plugins after_plugins
  local plugins_changed=0 tpm_changed=0 tmux_changed=0

  run "mkdir -p $HOME/.config/tmux/plugins"

  git_clone_or_update "https://github.com/tmux-plugins/tpm" "$tpm" tpm_changed

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    plan "would sync tmux plugins and, if they changed, ask before restarting tmux"
    return
  fi

  before_plugins="$(tmux_plugins_snapshot)"
  run "$tpm/bin/install_plugins"
  after_plugins="$(tmux_plugins_snapshot)"

  if [ "$before_plugins" != "$after_plugins" ]; then
    plugins_changed=1
    done_log "tmux plugins changed"
  elif [ "$tpm_changed" -eq 0 ]; then
    skip "tmux plugins already current"
  fi

  if [ "$tpm_changed" -eq 1 ]; then
    tmux_changed=1
    done_log "tmux plugin manager changed"
  fi

  if [ "$plugins_changed" -eq 1 ]; then
    tmux_changed=1
  fi

  if [ "$tmux_changed" -eq 0 ]; then
    skip "tmux server reload not needed"
    return
  fi

  if ! pgrep tmux >/dev/null 2>&1; then
    skip "tmux server is not running; no reload needed"
    return
  fi

  if confirm_tmux_restart; then
    info "restarting tmux server to pick up plugin changes"
    run "tmux kill-server"
  else
    skip "leaving tmux server running"
  fi
}
