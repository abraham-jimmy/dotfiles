#!/usr/bin/env bash
set -euo pipefail

PKG_INDEX_REFRESHED=0

refresh_pkg_index_once() {
  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    return
  fi

  if [ "$PKG_INDEX_REFRESHED" -eq 1 ]; then
    return
  fi

  case "$DISTRO" in
    debian)
      run "sudo apt update"
      ;;
    arch)
      run "sudo pacman -Sy"
      ;;
    fedora)
      run "sudo dnf makecache"
      ;;
    *)
      echo "Unsupported distro: $DISTRO"
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
        nodejs) echo nodejs ;;
        openssh) echo openssh ;;
        nvim) echo neovim ;;
        *) echo "$program" ;;
      esac
      ;;
    debian)
      case "$program" in
        openssh) echo openssh-client ;;
        nodejs) echo nodejs ;;
        nvim) echo neovim ;;
        *) echo "$program" ;;
      esac
      ;;
    fedora)
      case "$program" in
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

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    echo "[dry-run] install $pkg"
    return
  fi

  refresh_pkg_index_once

  case "$DISTRO" in
    debian)
      sudo apt install -y "$pkg"
      ;;
    arch)
      sudo pacman -S --noconfirm "$pkg"
      ;;
    fedora)
      sudo dnf install -y "$pkg"
      ;;
    *)
      echo "Unsupported distro: $DISTRO"
      exit 1
      ;;
  esac
}

ensure_program() {
  local cmd="$1"
  local program="$2"

  if command -v "$cmd" >/dev/null 2>&1; then
    log "$cmd already installed"
    return
  fi

  local pkg
  pkg="$(pkg_name "$program")"
  log "Installing $pkg"
  install_package "$pkg"
}
