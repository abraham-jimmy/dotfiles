#!/usr/bin/env bash
set -euo pipefail

PKG_INDEX_REFRESHED=0

refresh_pkg_index_once() {
  if [ "$PKG_INDEX_REFRESHED" -eq 1 ]; then
    return
  fi

  case "$DISTRO" in
    debian)
      run "sudo apt update"
      ;;
    arch)
      :
      ;;
    fedora)
      run "sudo dnf makecache"
      ;;
    *)
      error "Unsupported distro: $DISTRO"
      exit 1
      ;;
  esac

  PKG_INDEX_REFRESHED=1
}

pkg_name() {
  local program="$1"
  case "$DISTRO" in
    arch)
      case "$program" in
        clangd|clang-format) echo clang ;;
        nodejs) echo nodejs ;;
        openssh) echo openssh ;;
        nvim) echo neovim ;;
        *) echo "$program" ;;
      esac
      ;;
    debian)
      case "$program" in
        clangd) echo clangd ;;
        clang-format) echo clang-format ;;
        openssh) echo openssh-client ;;
        nodejs) echo nodejs ;;
        nvim) echo neovim ;;
        *) echo "$program" ;;
      esac
      ;;
    fedora)
      case "$program" in
        clangd|clang-format) echo clang-tools-extra ;;
        openssh) echo openssh ;;
        nodejs) echo nodejs ;;
        nvim) echo neovim ;;
        *) echo "$program" ;;
      esac
      ;;
    *)
      echo "$program"
      ;;
  esac
}

install_package() {
  local pkg="$1"

  refresh_pkg_index_once

  case "$DISTRO" in
    debian)
      run "sudo apt install -y \"$pkg\""
      ;;
    arch)
      run "sudo pacman -S --noconfirm \"$pkg\""
      ;;
    fedora)
      run "sudo dnf install -y \"$pkg\""
      ;;
    *)
      error "Unsupported distro: $DISTRO"
      exit 1
      ;;
  esac
}

try_install_package() {
  local pkg="$1"

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    install_package "$pkg"
    return 0
  fi

  if install_package "$pkg"; then
    return 0
  fi

  return 1
}

ensure_program() {
  local cmd="$1"
  local program="$2"

  if command -v "$cmd" >/dev/null 2>&1; then
    skip "already installed: $cmd"
    return
  fi

  local pkg
  pkg="$(pkg_name "$program")"
  info "package required: $pkg"
  install_package "$pkg"

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    plan "would ensure command '$cmd' via package '$pkg'"
  else
    done_log "installed package: $pkg"
  fi
}

ensure_program_optional() {
  local cmd="$1"
  local program="$2"

  if command -v "$cmd" >/dev/null 2>&1; then
    skip "already installed: $cmd"
    return 0
  fi

  local pkg
  pkg="$(pkg_name "$program")"
  info "optional package required: $pkg"

  if try_install_package "$pkg"; then
    if [ "${DRY_RUN:-0}" -eq 1 ]; then
      plan "would ensure optional command '$cmd' via package '$pkg'"
    else
      done_log "installed optional package: $pkg"
    fi
    return 0
  fi

  warn "unable to install optional package '$pkg' for command '$cmd'"
  return 1
}

ensure_npm_global() {
  local cmd="$1"
  local package="$2"
  local prefix_dir="$HOME/.local"

  if command -v "$cmd" >/dev/null 2>&1; then
    skip "already installed: $cmd"
    return 0
  fi

  if ! command -v npm >/dev/null 2>&1; then
    warn "npm is unavailable; cannot install global package '$package'"
    return 1
  fi

  info "npm package required: $package"

  run "mkdir -p \"$prefix_dir/bin\""

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    run "npm install -g --prefix \"$prefix_dir\" \"$package\""
    plan "would ensure command '$cmd' via npm package '$package'"
    return 0
  fi

  if run "npm install -g --prefix \"$prefix_dir\" \"$package\""; then
    done_log "installed npm package: $package"
    return 0
  fi

  warn "unable to install npm package '$package'"
  return 1
}
