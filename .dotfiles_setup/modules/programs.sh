#!/usr/bin/env bash
set -euo pipefail

PROGRAM_MANIFEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../profiles" && pwd)"

resolve_profile_programs() {
  local profile="$1"
  local manifest="$PROGRAM_MANIFEST_DIR/$profile.programs"
  local line kind value rest

  if [ ! -f "$manifest" ]; then
    error "missing program manifest: $manifest"
    return 1
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*) continue ;;
    esac

    IFS='|' read -r kind value rest <<< "$line"
    if [ "$kind" = "include" ]; then
      if ! resolve_profile_programs "$value"; then
        return 1
      fi
    else
      printf '%s\n' "$line"
    fi
  done < "$manifest"
}

install_all_programs() {
  local profile="${PROFILE:?}"
  local lines=()
  local line kind cmd program priority resolved

  if ! resolved="$(resolve_profile_programs "$profile")"; then
    return 1
  fi

  while IFS= read -r line; do
    IFS='|' read -r kind cmd program priority <<< "$line"
    case "$kind" in
      package|optional-package)
        lines+=("${priority:-50}|$kind|$cmd|$program")
        ;;
    esac
  done <<< "$resolved"

  if [ "${#lines[@]}" -eq 0 ]; then
    skip "profile has no system packages"
    return
  fi

  while IFS='|' read -r priority kind cmd program; do
    case "$kind" in
      package) ensure_program "$cmd" "$program" ;;
      optional-package) ensure_program_optional "$cmd" "$program" || true ;;
    esac
  done < <(printf '%s\n' "${lines[@]}" | sort -n -t '|' -k1,1)
}

list_profile_tasks() {
  local profile="$1"
  local line kind task _description _priority resolved

  if ! resolved="$(resolve_profile_programs "$profile")"; then
    return 1
  fi

  while IFS= read -r line; do
    IFS='|' read -r kind task _description _priority <<< "$line"
    if [ "$kind" = "task" ]; then
      printf '%s\n' "$task"
    fi
  done <<< "$resolved"
}
