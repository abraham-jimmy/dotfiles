#!/usr/bin/env bash
set -euo pipefail

write_if_changed() {
  local path="$1"
  local content="$2"
  local tmp

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    echo "[dry-run] write $path"
    return
  fi

  mkdir -p "$(dirname "$path")"
  tmp="$(mktemp)"
  printf '%s' "$content" >"$tmp"

  if [ -f "$path" ] && cmp -s "$tmp" "$path"; then
    rm -f "$tmp"
    return
  fi

  mv "$tmp" "$path"
}

git_clone_or_update() {
  local repo="$1"
  local dest="$2"

  if [ -d "$dest/.git" ]; then
    run "git -C \"$dest\" pull --ff-only"
    return
  fi

  if [ -e "$dest" ]; then
    log "Skipping $dest (exists but is not a git repository)"
    return
  fi

  run "mkdir -p \"$(dirname "$dest")\""
  run "git clone \"$repo\" \"$dest\""
}

setup_15_shell_stubs() {
  write_if_changed "$HOME/.bashrc" $'[[ $- != *i* ]] && return\n[ -r "$HOME/.config/bash/.bashrc" ] && . "$HOME/.config/bash/.bashrc"\n'

  write_if_changed "$HOME/.bash_profile" $'[ -r "$HOME/.profile" ] && . "$HOME/.profile"\n[ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"\n'

  write_if_changed "$HOME/.zshenv" $'export ZDOTDIR="$HOME/.config/zsh"\n'

  write_if_changed "$HOME/.zshrc" $'[[ -r "$HOME/.config/zsh/.zshrc" ]] && source "$HOME/.config/zsh/.zshrc"\n'
}

setup_16_zsh_framework() {
  git_clone_or_update "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME/.oh-my-zsh"
  git_clone_or_update "https://github.com/romkatv/powerlevel10k.git" "$HOME/.local/share/powerlevel10k"
  git_clone_or_update "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.local/share/zsh/plugins/zsh-autosuggestions"
  git_clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting"
  git_clone_or_update "https://github.com/zsh-users/zsh-history-substring-search.git" "$HOME/.local/share/zsh/plugins/zsh-history-substring-search"
}

setup_17_default_shell() {
  local entry current_shell zsh_path

  entry="$(getent passwd "$USER" || true)"
  current_shell="${entry##*:}"
  zsh_path="$(command -v zsh || true)"

  if [ -z "$zsh_path" ]; then
    log "zsh is not installed; skipping default shell update"
    return
  fi

  if [ "$current_shell" = "$zsh_path" ]; then
    log "Default shell already set to zsh"
    return
  fi

  run "chsh -s \"$zsh_path\" \"$USER\""
}

setup_18_opencode() {
  local install_flag npm_pkg="opencode-ai"

  install_flag="${INSTALL_OPENCODE:-auto}"
  case "$install_flag" in
    0|false|FALSE|no|NO)
      log "Skipping optional OpenCode install (INSTALL_OPENCODE=$install_flag)"
      return
      ;;
  esac

  if command -v opencode >/dev/null 2>&1; then
    log "opencode already installed"
    return
  fi

  if ! command -v npm >/dev/null 2>&1; then
    log "npm is missing; skipping optional OpenCode install"
    return
  fi

  run "mkdir -p \"$HOME/.local/bin\""

  if run "npm install -g --prefix \"$HOME/.local\" \"$npm_pkg\""; then
    export PATH="$HOME/.local/bin:$PATH"

    if command -v opencode >/dev/null 2>&1; then
      log "Installed opencode via npm ($npm_pkg)"
    else
      log "Installed $npm_pkg, but opencode is not on PATH yet"
    fi
    return
  fi

  log "Optional OpenCode install failed; continuing setup"
}
