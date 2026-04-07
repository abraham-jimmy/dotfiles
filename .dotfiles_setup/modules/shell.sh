#!/usr/bin/env bash
set -euo pipefail

SHELL_TOOLS_BIN_DIR="$HOME/.local/bin"
SHELL_TOOLS_OPT_DIR="$HOME/.local/opt/shell-tools"

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
  local changed_var="${3:-}"
  local head upstream changed=0

  if [ -d "$dest/.git" ]; then
    if [ "${DRY_RUN:-0}" -eq 1 ]; then
      plan "would check remote updates for repo: $dest"
      if [ -n "$changed_var" ]; then
        printf -v "$changed_var" '%s' "$changed"
      fi
      return 0
    fi

    if git -C "$dest" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
      run "git -C \"$dest\" fetch --quiet --all --prune"

      head="$(git -C "$dest" rev-parse HEAD 2>/dev/null || true)"
      upstream="$(git -C "$dest" rev-parse '@{u}' 2>/dev/null || true)"

      if [ -n "$head" ] && [ "$head" = "$upstream" ]; then
        skip "repo already up to date: $dest"
        if [ -n "$changed_var" ]; then
          printf -v "$changed_var" '%s' "$changed"
        fi
        return 0
      fi
    fi

    info "fast-forwarding repo: $dest"
    run "git -C \"$dest\" pull --ff-only"
    changed=1
    if [ -n "$changed_var" ]; then
      printf -v "$changed_var" '%s' "$changed"
    fi
    return 0
  fi

  if [ -e "$dest" ]; then
    skip "leaving path alone: $dest exists but is not a git repository"
    if [ -n "$changed_var" ]; then
      printf -v "$changed_var" '%s' "$changed"
    fi
    return 0
  fi

  info "cloning repo: $dest"
  run "mkdir -p \"$(dirname "$dest")\""
  run "git clone \"$repo\" \"$dest\""
  changed=1
  if [ -n "$changed_var" ]; then
    printf -v "$changed_var" '%s' "$changed"
  fi
  return 0
}

shell_tool_path_is_healthy_executable() {
  local path="${1:-}"

  [ -n "$path" ] && [ -x "$path" ]
}

managed_shell_tool_path() {
  printf '%s/%s\n' "$SHELL_TOOLS_BIN_DIR" "$1"
}

ensure_shell_tool_dirs() {
  run "mkdir -p \"$SHELL_TOOLS_BIN_DIR\" \"$SHELL_TOOLS_OPT_DIR\""
}

shell_tools_linux_arch() {
  case "$(uname -m)" in
    x86_64|amd64) printf 'x86_64' ;;
    aarch64|arm64) printf 'arm64' ;;
    *) return 1 ;;
  esac
}

managed_shell_tool_is_current() {
  local cmd="$1"
  local install_dir="$2"
  local binary_relpath="$3"
  local bin_path installed_binary_path

  bin_path="$(managed_shell_tool_path "$cmd")"
  installed_binary_path="$install_dir/$binary_relpath"

  [ -L "$bin_path" ] || return 1
  [ "$(readlink "$bin_path")" = "$installed_binary_path" ] || return 1
  shell_tool_path_is_healthy_executable "$installed_binary_path"
}

install_managed_shell_archive_tool() {
  local cmd="$1"
  local url="$2"
  local binary_relpath="$3"
  local install_name="$4"
  local archive_path extract_dir install_dir installed_binary_path extracted_binary_path bin_path

  ensure_shell_tool_dirs
  archive_path="$(mktemp)"
  extract_dir="$(mktemp -d)"
  install_dir="$SHELL_TOOLS_OPT_DIR/$install_name"
  installed_binary_path="$install_dir/$binary_relpath"
  extracted_binary_path="$extract_dir/$binary_relpath"
  bin_path="$(managed_shell_tool_path "$cmd")"

  if managed_shell_tool_is_current "$cmd" "$install_dir" "$binary_relpath"; then
    skip "already installed: $cmd"
    rm -f "$archive_path"
    rm -rf "$extract_dir"
    return 0
  fi

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    run "curl -fL \"$url\" -o \"$archive_path\""
    run "tar -xzf \"$archive_path\" -C \"$extract_dir\""
    run "rm -rf \"$install_dir\""
    run "mkdir -p \"$install_dir\""
    run "cp -R \"$extract_dir\"/. \"$install_dir\"/"
    run "rm -f \"$bin_path\""
    run "ln -sfn \"$installed_binary_path\" \"$bin_path\""
    plan "would install '$cmd' from upstream archive"
    rm -f "$archive_path"
    rm -rf "$extract_dir"
    return 0
  fi

  if ! run "curl -fL \"$url\" -o \"$archive_path\""; then
    rm -f "$archive_path"
    rm -rf "$extract_dir"
    warn "unable to download archive for '$cmd'"
    return 1
  fi

  if ! run "tar -xzf \"$archive_path\" -C \"$extract_dir\""; then
    rm -f "$archive_path"
    rm -rf "$extract_dir"
    warn "unable to extract archive for '$cmd'"
    return 1
  fi

  if ! shell_tool_path_is_healthy_executable "$extracted_binary_path"; then
    rm -f "$archive_path"
    rm -rf "$extract_dir"
    warn "archive for '$cmd' did not contain executable '$binary_relpath'"
    return 1
  fi

  if run "rm -rf \"$install_dir\"" && run "mkdir -p \"$install_dir\"" && run "cp -R \"$extract_dir\"/. \"$install_dir\"/" && run "rm -f \"$bin_path\"" && run "ln -sfn \"$installed_binary_path\" \"$bin_path\""; then
    if ! shell_tool_path_is_healthy_executable "$installed_binary_path"; then
      rm -f "$archive_path"
      rm -rf "$extract_dir"
      warn "installed shell tool '$cmd' is missing executable '$binary_relpath'"
      return 1
    fi

    if ! shell_tool_path_is_healthy_executable "$bin_path"; then
      rm -f "$archive_path"
      rm -rf "$extract_dir"
      warn "managed shell tool link for '$cmd' is not executable at '$bin_path'"
      return 1
    fi

    if [ "${DRY_RUN:-0}" -eq 1 ]; then
      plan "would install '$cmd' from upstream archive"
    else
      done_log "installed upstream shell tool: $cmd"
    fi
    rm -f "$archive_path"
    rm -rf "$extract_dir"
    return 0
  fi

  rm -f "$archive_path"
  rm -rf "$extract_dir"
  warn "unable to install upstream archive tool '$cmd'"
  return 1
}

install_television() {
  local version arch target

  case "${INSTALL_TELEVISION:-auto}" in
    0|false|FALSE|no|NO)
      skip "skipping television install (INSTALL_TELEVISION=${INSTALL_TELEVISION:-auto})"
      return 0
      ;;
  esac

  version="${TELEVISION_VERSION:-0.15.4}"
  arch="$(shell_tools_linux_arch)" || {
    warn "unsupported architecture for television"
    return 1
  }

  case "$arch" in
    x86_64) target="x86_64-unknown-linux-gnu" ;;
    arm64) target="aarch64-unknown-linux-gnu" ;;
  esac

  install_managed_shell_archive_tool \
    tv \
    "https://github.com/alexpasmantier/television/releases/download/${version}/tv-${version}-${target}.tar.gz" \
    "tv-${version}-${target}/tv" \
    "television-${version}-${target}"
}

install_sesh() {
  local version arch target

  case "${INSTALL_SESH:-auto}" in
    0|false|FALSE|no|NO)
      skip "skipping sesh install (INSTALL_SESH=${INSTALL_SESH:-auto})"
      return 0
      ;;
  esac

  version="${SESH_VERSION:-v2.24.2}"
  arch="$(shell_tools_linux_arch)" || {
    warn "unsupported architecture for sesh"
    return 1
  }

  case "$arch" in
    x86_64) target="Linux_x86_64" ;;
    arm64) target="Linux_arm64" ;;
  esac

  install_managed_shell_archive_tool \
    sesh \
    "https://github.com/joshmedeski/sesh/releases/download/${version}/sesh_${target}.tar.gz" \
    "sesh" \
    "sesh-${version}-${arch}"
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

setup_18a_television() {
  install_television
}

setup_18b_sesh() {
  install_sesh
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
