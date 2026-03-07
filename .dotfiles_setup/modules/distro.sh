#!/usr/bin/env bash
set -euo pipefail

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
      echo "Unsupported distro: ${id:-unknown} (ID_LIKE=${like:-unknown})" >&2
      exit 1
      ;;
  esac
}

DISTRO="$(normalize_distro "$DISTRO_ID" "$DISTRO_LIKE")"

export DISTRO
export DISTRO_ID
export DISTRO_LIKE
