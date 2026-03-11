#!/usr/bin/env bash
set -euo pipefail

write_if_changed() {
  local path="$1"
  local content="$2"
  local tmp action

  tmp="$(mktemp)"
  printf '%s' "$content" >"$tmp"

  if [ -f "$path" ] && cmp -s "$tmp" "$path"; then
    rm -f "$tmp"
    skip "unchanged file: $path"
    return
  fi

  if [ -e "$path" ]; then
    action="update"
  else
    action="create"
  fi

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    plan "would $action file: $path"
    rm -f "$tmp"
    return
  fi

  mkdir -p "$(dirname "$path")"

  mv "$tmp" "$path"

  case "$action" in
    create) done_log "created file: $path" ;;
    update) done_log "updated file: $path" ;;
  esac
}

git_clone_or_update() {
  local repo="$1"
  local dest="$2"
  local head upstream

  if [ -d "$dest/.git" ]; then
    if [ "${DRY_RUN:-0}" -eq 1 ]; then
      plan "would check remote updates for repo: $dest"
      return 0
    fi

    if git -C "$dest" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
      run "git -C \"$dest\" fetch --quiet --all --prune"

      head="$(git -C "$dest" rev-parse HEAD 2>/dev/null || true)"
      upstream="$(git -C "$dest" rev-parse '@{u}' 2>/dev/null || true)"

      if [ -n "$head" ] && [ "$head" = "$upstream" ]; then
        skip "repo already up to date: $dest"
        return 1
      fi
    fi

    info "fast-forwarding repo: $dest"
    run "git -C \"$dest\" pull --ff-only"
    return 0
  fi

  if [ -e "$dest" ]; then
    skip "leaving path alone: $dest exists but is not a git repository"
    return 1
  fi

  info "cloning repo: $dest"
  run "mkdir -p \"$(dirname "$dest")\""
  run "git clone \"$repo\" \"$dest\""
  return 0
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
    skip "zsh is not installed; leaving default shell unchanged"
    return
  fi

  if [ "$current_shell" = "$zsh_path" ]; then
    skip "default shell already set to zsh"
    return
  fi

  info "updating default shell to $zsh_path"
  run "chsh -s \"$zsh_path\" \"$USER\""
}

setup_18_opencode() {
  local install_flag opencode_version install_cmd

  install_flag="${INSTALL_OPENCODE:-auto}"
  case "$install_flag" in
    0|false|FALSE|no|NO)
      skip "skipping optional OpenCode install (INSTALL_OPENCODE=$install_flag)"
      return
      ;;
  esac

  opencode_version="${OPENCODE_VERSION:-latest}"
  export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"
  info "OpenCode target version: $opencode_version"

  if [ "$opencode_version" = "latest" ]; then
    install_cmd='curl -fsSL "https://opencode.ai/install" | bash -s -- --no-modify-path'
  else
    install_cmd="curl -fsSL \"https://opencode.ai/install\" | bash -s -- --version \"$opencode_version\" --no-modify-path"
  fi

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    run "$install_cmd"
    return
  fi

  if run "$install_cmd"; then
    if command -v opencode >/dev/null 2>&1; then
      done_log "OpenCode ready ($opencode_version)"
    else
      warn "OpenCode installer completed, but opencode is not on PATH yet"
    fi
    return
  fi

  warn "optional OpenCode install failed; continuing setup"
}
