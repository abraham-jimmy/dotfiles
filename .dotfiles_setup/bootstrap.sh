#!/usr/bin/env bash
set -euo pipefail

# curl -fsSL https://raw.githubusercontent.com/user/dotfiles/main/bootstrap.sh | bash


REPO_HTTPS="https://github.com/abraham-jimmy/dotfiles.git"
DIR="$HOME/.dotfiles-src"

if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO_ID="${ID:-}"
  DISTRO_LIKE="${ID_LIKE:-}"
else
  echo "Unsupported system"
  exit 1
fi

normalize_distro() {
  local id="$1"
  local like="$2"

  case "$id" in
    arch|cachyos|endeavouros|manjaro)
      echo arch
      return
      ;;
    ubuntu|debian)
      echo debian
      return
      ;;
    fedora)
      echo fedora
      return
      ;;
  esac

  case " $like " in
    *" arch "*) echo arch ;;
    *" debian "*|*" ubuntu "*) echo debian ;;
    *" fedora "*|*" rhel "*) echo fedora ;;
    *)
      echo "Unsupported distro: ${id:-unknown} (ID_LIKE=${like:-unknown})"
      exit 1
      ;;
  esac
}

DISTRO="$(normalize_distro "$DISTRO_ID" "$DISTRO_LIKE")"

install_pkg_bootstrap() {
  case "$DISTRO" in
    debian)
      sudo apt update
      sudo apt install -y "$@"
      ;;
    arch)
      sudo pacman -Sy --noconfirm "$@"
      ;;
    fedora)
      sudo dnf install -y "$@"
      ;;
    *)
      echo "Unsupported distro: $DISTRO"
      exit 1
      ;;
  esac
}

need() { command -v "$1" >/dev/null 2>&1; }

need curl || install_pkg_bootstrap curl
need git  || install_pkg_bootstrap git

if [ ! -d "$DIR" ]; then
  git clone "$REPO_HTTPS" "$DIR"
else
  git -C "$DIR" pull --ff-only || true
fi

exec bash "$DIR/setup.sh"
