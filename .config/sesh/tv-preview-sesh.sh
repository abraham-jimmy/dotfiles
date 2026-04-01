#!/usr/bin/env bash
set -euo pipefail

value="${1:-}"

if [ -z "$value" ]; then
  exit 0
fi

if [ "$value" = "dotfiles" ]; then
  exec bash "$HOME/.config/sesh/preview-dotfiles.sh"
fi

exec sesh preview "$value"
