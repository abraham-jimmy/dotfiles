#!/usr/bin/env bash
set -euo pipefail

# curl -fsSL https://raw.githubusercontent.com/user/dotfiles/main/bootstrap.sh | bash


REPO_HTTPS="https://github.com/abraham-jimmy/dotfiles.git"
DIR="$HOME/.dotfiles-src"

if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO="$ID"
else
  echo "Unsupported system"
  exit 1
fi

install_pkg_bootstrap() {
  case "$DISTRO" in
    ubuntu|debian)
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
