#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *) ;;
  esac
done

log(){ echo "[INFO] $*"; }
run(){ if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] $*"; else eval "$@"; fi; }

export DRY_RUN
export -f log run

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$SCRIPT_DIR/modules"

source "$MODULE_DIR/distro.sh"
source "$MODULE_DIR/installer.sh"
source "$MODULE_DIR/programs.sh"

install_all_programs

for f in "$MODULE_DIR"/*.sh; do
  case "$(basename "$f")" in
    distro.sh|installer.sh|programs.sh) continue ;;
  esac
  source "$f"
done

mapfile -t setup_fns < <(declare -F | awk '{print $3}' | grep '^setup_' | sort)

for fn in "${setup_fns[@]}"; do
  "$fn"
done
