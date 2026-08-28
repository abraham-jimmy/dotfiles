#!/usr/bin/env bash
set -euo pipefail

REPO_HTTPS="https://github.com/abraham-jimmy/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
PROFILE_DIR=".dotfiles_setup/profiles"
DEBUG=0
REPAIR_SHELL=0
SOURCE_REF=HEAD
USE_WORKTREE_MANIFESTS=0
BOOTSTRAP_FROM_STDIN=0
PROMPT_TTY_AVAILABLE=0

[ -n "${BASH_SOURCE[0]:-}" ] || BOOTSTRAP_FROM_STDIN=1
if { exec 9<>/dev/tty; } 2>/dev/null; then
  PROMPT_TTY_AVAILABLE=1
fi

usage() {
  printf 'Usage: %s [--debug | --repair-shell]\n' "${0##*/}"
  printf '  no arguments    Sync configuration and optionally install software.\n'
  printf '  --debug         Validate and simulate the complete workstation setup.\n'
  printf '  --repair-shell  Restore private root shell startup files only.\n'
}

for arg in "$@"; do
  case "$arg" in
    --debug) DEBUG=1 ;;
    --repair-shell) REPAIR_SHELL=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ "$DEBUG" -eq 1 ] && [ "$REPAIR_SHELL" -eq 1 ]; then
  printf '%s\n' '--debug and --repair-shell cannot be used together.' >&2
  exit 2
fi

prompt_read() {
  local target="$1"
  local prompt="$2"
  local value

  if [ "$BOOTSTRAP_FROM_STDIN" -eq 0 ] && IFS= read -r -p "$prompt" value; then
    printf -v "$target" '%s' "$value"
    return 0
  fi

  if [ "$PROMPT_TTY_AVAILABLE" -eq 1 ] && IFS= read -r -u 9 -p "$prompt" value; then
    printf -v "$target" '%s' "$value"
    return 0
  fi

  printf 'Interactive input is unavailable while prompting: %s\n' "$prompt" >&2
  return 1
}

dotfiles() {
  /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

normalize_distro() {
  local id="$1"
  local like="$2"

  case "$id" in
    arch|cachyos|endeavouros|manjaro) printf 'arch\n'; return ;;
    ubuntu|debian) printf 'debian\n'; return ;;
    fedora) printf 'fedora\n'; return ;;
  esac

  case " $like " in
    *" arch "*) printf 'arch\n' ;;
    *" debian "*|*" ubuntu "*) printf 'debian\n' ;;
    *" fedora "*|*" rhel "*) printf 'fedora\n' ;;
    *) return 1 ;;
  esac
}

git_install_command() {
  local distro="$1"

  case "$distro" in
    arch) printf 'sudo pacman -S --noconfirm git' ;;
    debian) printf 'sudo apt update && sudo apt install -y git' ;;
    fedora) printf 'sudo dnf install -y git' ;;
    *) return 1 ;;
  esac
}

ensure_git() {
  local distro_id="" distro_like="" distro="" install_cmd="" answer=""

  if command -v /usr/bin/git >/dev/null 2>&1; then
    return
  fi

  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    distro_id="${ID:-}"
    distro_like="${ID_LIKE:-}"
    distro="$(normalize_distro "$distro_id" "$distro_like" || true)"
    install_cmd="$(git_install_command "$distro" || true)"
  fi

  printf 'Missing requirement: Git\n'
  if [ -n "$install_cmd" ]; then
    printf 'Install with: %s\n' "$install_cmd"
  fi
  printf 'Official downloads: https://git-scm.com/downloads\n'

  if [ "$DEBUG" -eq 1 ]; then
    printf 'Debug mode never installs missing requirements.\n' >&2
    exit 1
  fi

  prompt_read answer 'Install Git now? [y/N]: ' || exit 1

  case "$answer" in
    y|Y|yes|YES)
      if [ -z "$install_cmd" ]; then
        printf 'No supported automatic Git install command was found for this system.\n' >&2
        exit 1
      fi
      eval "$install_cmd"
      ;;
    *) exit 1 ;;
  esac

  if ! command -v /usr/bin/git >/dev/null 2>&1; then
    printf 'Git is still unavailable after installation.\n' >&2
    exit 1
  fi
}

repo_file() {
  local path="$1"
  local line

  if [ "$USE_WORKTREE_MANIFESTS" -eq 1 ]; then
    if [ ! -f "$HOME/$path" ]; then
      printf 'Missing worktree manifest: %s\n' "$HOME/$path" >&2
      return 1
    fi
    while IFS= read -r line || [ -n "$line" ]; do
      printf '%s\n' "$line"
    done < "$HOME/$path"
    return
  fi

  dotfiles show "$SOURCE_REF:$path"
}

local_profile_file() {
  printf '%s/%s/%s.%s' "$HOME" "$PROFILE_DIR" "$1" "$2"
}

list_profiles_from_repo() {
  local path

  if [ "$USE_WORKTREE_MANIFESTS" -eq 1 ]; then
    for path in "$HOME/$PROFILE_DIR"/*.paths; do
      [ -f "$path" ] || continue
      basename "$path" .paths
    done | sort
    return
  fi

  dotfiles ls-tree -r --full-tree --name-only "$SOURCE_REF" -- ":(top)$PROFILE_DIR" |
    while IFS= read -r path; do
      case "$path" in
        "$PROFILE_DIR"/*.paths) basename "$path" .paths ;;
      esac
    done |
    sort
}

profile_paths_from_repo() {
  local content line

  if ! content="$(repo_file "$PROFILE_DIR/$1.paths")"; then
    return 1
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*) continue ;;
      *) printf '%s\n' "$line" ;;
    esac
  done <<< "$content"
}

profile_programs_from_repo() {
  local profile="$1"
  local content line kind value rest

  if ! content="$(repo_file "$PROFILE_DIR/$profile.programs")"; then
    return 1
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|'#'*) continue ;;
    esac

    IFS='|' read -r kind value rest <<< "$line"
    if [ "$kind" = "include" ]; then
      if ! profile_programs_from_repo "$value"; then
        return 1
      fi
    else
      printf '%s\n' "$line"
    fi
  done <<< "$content"
}

show_profile() {
  local profile="$1"
  local line kind command command_display package _priority task description programs

  if [ "$USE_WORKTREE_MANIFESTS" -eq 1 ]; then
    [ -f "$HOME/$PROFILE_DIR/$profile.paths" ] || {
      printf 'Missing worktree manifest: %s\n' "$HOME/$PROFILE_DIR/$profile.paths" >&2
      exit 1
    }
    [ -f "$HOME/$PROFILE_DIR/$profile.programs" ] || {
      printf 'Missing worktree manifest: %s\n' "$HOME/$PROFILE_DIR/$profile.programs" >&2
      exit 1
    }
  fi

  printf '\nProfile: %s\n' "$profile"
  printf 'Configuration paths:\n'
  while IFS= read -r line; do
    printf '  - %s\n' "$line"
  done < <(profile_paths_from_repo "$profile")

  printf 'Cone-mode root files (included automatically):\n'
  while IFS= read -r line; do
    case "$line" in
      */*) continue ;;
      *) printf '  - %s\n' "$line" ;;
    esac
  done < <(dotfiles ls-tree -r --full-tree --name-only "$SOURCE_REF")

  printf 'Optional software and setup tasks:\n'
  if ! programs="$(profile_programs_from_repo "$profile")"; then
    exit 1
  fi
  while IFS= read -r line; do
    IFS='|' read -r kind command package _priority <<< "$line"
    case "$kind" in
      package|optional-package)
        command_display="${command//,/ or }"
        printf '  - %-24s package: %s\n' "$command_display" "$package"
        ;;
      task)
        task="$command"
        description="$package"
        printf '  - %-24s %s\n' "$task" "$description"
        ;;
    esac
  done <<< "$programs"
  printf '\n'
}

current_profile() {
  local profile stored current expected

  stored="$(dotfiles config --local --get dotfiles.profile 2>/dev/null || true)"
  current="$(dotfiles sparse-checkout list 2>/dev/null | sort || true)"

  while IFS= read -r profile; do
    expected="$(profile_paths_from_repo "$profile" | sort)"
    if [ -n "$current" ] && [ "$current" = "$expected" ]; then
      printf '%s\n' "$profile"
      return
    fi
  done < <(list_profiles_from_repo)

  if [ -n "$stored" ] && repo_file "$PROFILE_DIR/$stored.paths" >/dev/null 2>&1; then
    printf '%s\n' "$stored"
    return
  fi

  if [ "$USE_WORKTREE_MANIFESTS" -eq 1 ] &&
     [ "$(dotfiles config --local --get core.sparseCheckout 2>/dev/null || true)" != "true" ] &&
     [ -f "$HOME/$PROFILE_DIR/workstation.paths" ]; then
    printf 'workstation\n'
  fi
}

select_profile() {
  local current="$1"
  local profile answer
  local profiles=()

  mapfile -t profiles < <(list_profiles_from_repo)
  if [ "${#profiles[@]}" -eq 0 ]; then
    printf 'No sparse profiles were found in %s.\n' "$PROFILE_DIR" >&2
    exit 1
  fi

  printf '\nAvailable profiles:\n' >&2
  for profile in "${profiles[@]}"; do
    if [ "$profile" = "$current" ]; then
      printf '  - %s (current)\n' "$profile" >&2
    else
      printf '  - %s\n' "$profile" >&2
    fi
  done

  while true; do
    if [ -n "$current" ]; then
      prompt_read answer "Select profile [$current]: " || return 1
      answer="${answer:-$current}"
    else
      prompt_read answer 'Select profile: ' || return 1
    fi

    for profile in "${profiles[@]}"; do
      if [ "$answer" = "$profile" ]; then
        printf '%s\n' "$answer"
        return
      fi
    done
    printf 'Unknown profile: %s\n' "$answer" >&2
  done
}

path_is_selected() {
  local file="$1"
  local selected

  case "$file" in
    */*) ;;
    *) return 0 ;;
  esac

  while IFS= read -r selected; do
    if [ "$file" = "$selected" ] || [[ "$file" == "$selected/"* ]]; then
      return 0
    fi
  done
  return 1
}

worktree_hash() {
  local path="$1"

  if [ -L "$path" ]; then
    printf '%s' "$(readlink "$path")" | /usr/bin/git hash-object --stdin
  elif [ -f "$path" ]; then
    /usr/bin/git hash-object --no-filters "$path"
  else
    return 1
  fi
}

check_initial_conflicts() {
  local profile="$1"
  local file expected actual
  local conflicts=()
  local selected_paths

  selected_paths="$(profile_paths_from_repo "$profile")"
  while IFS= read -r file; do
    if ! path_is_selected "$file" <<< "$selected_paths"; then
      continue
    fi
    if [ ! -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
      continue
    fi

    expected="$(dotfiles rev-parse "HEAD:$file")"
    actual="$(worktree_hash "$HOME/$file" 2>/dev/null || true)"
    if [ "$actual" != "$expected" ]; then
      conflicts+=("$file")
    fi
  done < <(dotfiles ls-tree -r --full-tree --name-only HEAD)

  if [ "${#conflicts[@]}" -eq 0 ]; then
    return
  fi

  printf 'Checkout aborted. Existing files differ from the selected profile:\n' >&2
  printf '  - %s\n' "${conflicts[@]}" >&2
  printf 'Move or reconcile these files, then rerun bootstrap.\n' >&2
  exit 1
}

apply_profile() {
  local profile="$1"
  local first_checkout="$2"

  if [ "$first_checkout" -eq 1 ]; then
    check_initial_conflicts "$profile"
    dotfiles config --local dotfiles.initializing true
    dotfiles read-tree HEAD
  fi

  dotfiles sparse-checkout init --cone
  profile_paths_from_repo "$profile" | dotfiles sparse-checkout set --cone --stdin
  dotfiles checkout -- ':(top)**'
  dotfiles config --local dotfiles.profile "$profile"
  dotfiles config --local dotfiles.initialized true
  dotfiles config --local --unset dotfiles.initializing 2>/dev/null || true
  dotfiles config --local status.showUntrackedFiles no
}

configure_shell_startup() {
  local helper="$HOME/.dotfiles_setup/internal/ensure_shell_startup.sh"

  if [ ! -f "$helper" ]; then
    printf 'Missing shell startup helper: %s\n' "$helper" >&2
    return 1
  fi

  bash "$helper" --home "$HOME" --git-dir "$DOTFILES_DIR"
}

validate_local_debug() {
  local script_dir profile path line tracked program_file kind field2 field3 field4
  local failed=0
  local scripts=()
  local path_files=()

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ ! -f "$script_dir/internal/install_programs.sh" ] || [ ! -d "$script_dir/profiles" ]; then
    printf '%s\n' 'Full --debug validation requires a local dotfiles checkout.' >&2
    exit 1
  fi

  shopt -s nullglob

  printf '[DEBUG] validating shell scripts\n'
  scripts=("$script_dir"/*.sh "$script_dir"/internal/*.sh "$script_dir"/modules/*.sh)
  for path in "${scripts[@]}"; do
    if ! bash -n "$path"; then
      failed=1
    fi
  done

  printf '[DEBUG] validating generated shell startup files\n'
  if ! bash "$script_dir/internal/ensure_shell_startup.sh" --self-test; then
    failed=1
  fi

  printf '[DEBUG] validating profile manifests\n'
  path_files=("$script_dir"/profiles/*.paths)
  if [ "${#path_files[@]}" -eq 0 ]; then
    printf '[DEBUG] no profile path manifests found\n' >&2
    failed=1
  fi

  for path in "${path_files[@]}"; do
    profile="$(basename "$path" .paths)"
    program_file="$(local_profile_file "$profile" programs)"
    if [ ! -f "$program_file" ]; then
      printf '[DEBUG] missing program manifest: %s\n' "$program_file" >&2
      failed=1
      continue
    fi

    while IFS= read -r line; do
      case "$line" in
        ''|'#'*) continue ;;
      esac
      tracked="$(/usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" ls-files -- ":(top)$line" ":(top)$line/**")"
      if [ -z "$tracked" ]; then
        printf '[DEBUG] untracked profile path: %s (%s)\n' "$line" "$profile" >&2
        failed=1
      fi
    done < "$path"

    while IFS= read -r line; do
      case "$line" in
        ''|'#'*) continue ;;
      esac
      IFS='|' read -r kind field2 field3 field4 <<< "$line"
      case "$kind" in
        include)
          if [ ! -f "$(local_profile_file "$field2" programs)" ]; then
            printf '[DEBUG] missing included program manifest: %s\n' "$field2" >&2
            failed=1
          fi
          ;;
        package|optional-package)
          if [ -z "$field2" ] || [ -z "$field3" ] || [[ ! "$field4" =~ ^[0-9]+$ ]]; then
            printf '[DEBUG] invalid package entry in %s: %s\n' "$profile" "$line" >&2
            failed=1
          fi
          ;;
        task)
          if [ -z "$field2" ] || [ -z "$field3" ]; then
            printf '[DEBUG] invalid task entry in %s: %s\n' "$profile" "$line" >&2
            failed=1
          fi
          ;;
        *)
          printf '[DEBUG] unknown program entry in %s: %s\n' "$profile" "$line" >&2
          failed=1
          ;;
      esac
    done < "$program_file"
  done

  if [ "$failed" -ne 0 ]; then
    printf '[DEBUG] validation failed\n' >&2
    exit 1
  fi

  printf '[DEBUG] simulating complete workstation installer\n'
  bash "$script_dir/internal/install_programs.sh" --debug --profile workstation
}

if [ "$REPAIR_SHELL" -eq 1 ]; then
  ensure_git
  bare_repo="$(/usr/bin/git --git-dir="$DOTFILES_DIR" rev-parse --is-bare-repository 2>/dev/null || true)"
  if [ "$bare_repo" != "true" ]; then
    printf 'A complete bare dotfiles repository is required at: %s\n' "$DOTFILES_DIR" >&2
    exit 1
  fi
  configure_shell_startup
  printf 'Shell startup files repaired.\n'
  exit
fi

if [ "$DEBUG" -eq 1 ]; then
  ensure_git
  validate_local_debug
  exit
fi

ensure_git

first_checkout=0
dirty=0
needs_fast_forward=0
profile_applied=1

if [ -e "$DOTFILES_DIR" ]; then
  bare_repo="$(/usr/bin/git --git-dir="$DOTFILES_DIR" rev-parse --is-bare-repository 2>/dev/null || true)"
  if [ "$bare_repo" != "true" ] || ! /usr/bin/git --git-dir="$DOTFILES_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
    printf 'The dotfiles path exists but is not a complete bare repository: %s\n' "$DOTFILES_DIR" >&2
    printf 'Move or remove that path after inspecting it, then rerun bootstrap.\n' >&2
    exit 1
  fi
fi

if [ ! -d "$DOTFILES_DIR" ]; then
  printf 'Cloning bare dotfiles repository...\n'
  /usr/bin/git clone --bare "$REPO_HTTPS" "$DOTFILES_DIR"
  first_checkout=1
else
  initialized="$(dotfiles config --local --get dotfiles.initialized 2>/dev/null || true)"
  initializing="$(dotfiles config --local --get dotfiles.initializing 2>/dev/null || true)"

  if [ "$initialized" = "true" ]; then
    :
  elif [ ! -f "$DOTFILES_DIR/index" ] || [ "$initializing" = "true" ]; then
    first_checkout=1
    printf 'Resuming an incomplete initial checkout.\n'
  elif [ -f "$HOME/.config/shell/dotfiles.sh" ]; then
    dotfiles config --local dotfiles.initialized true
  else
    first_checkout=1
    printf 'Resuming an incomplete initial checkout.\n'
  fi

  if [ "$first_checkout" -eq 1 ]; then
    :
  elif [ -n "$(dotfiles status --porcelain)" ]; then
    dirty=1
    # shellcheck disable=SC2034
    USE_WORKTREE_MANIFESTS=1
    printf 'Tracked changes detected; skipping fetch and profile changes.\n'
  else
    printf 'Fetching dotfiles updates...\n'
    dotfiles fetch origin main
    if dotfiles merge-base --is-ancestor origin/main HEAD; then
      SOURCE_REF=HEAD
    elif dotfiles merge-base --is-ancestor HEAD origin/main; then
      SOURCE_REF=origin/main
      needs_fast_forward=1
    else
      printf 'Local main and origin/main have diverged; resolve them with the normal dotfiles Git workflow.\n' >&2
      exit 1
    fi
  fi
fi

active_profile="$(current_profile || true)"
profile="$(select_profile "$active_profile")"
show_profile "$profile"
prompt_read answer "Apply profile '$profile'? [y/N]: " || exit 1
case "$answer" in
  y|Y|yes|YES) ;;
  *) printf 'No configuration changes made.\n'; exit 0 ;;
esac

if [ "$dirty" -eq 1 ]; then
  if [ -z "$active_profile" ] || [ "$profile" != "$active_profile" ]; then
    printf 'Cannot change sparse profile while tracked changes are present.\n' >&2
    exit 1
  fi
  profile_applied=0
else
  if [ "$needs_fast_forward" -eq 1 ]; then
    dotfiles merge --ff-only origin/main
  fi
  apply_profile "$profile" "$first_checkout"
fi

if [ "$profile_applied" -eq 1 ]; then
  printf 'Configuration profile applied: %s\n' "$profile"
else
  printf 'Configuration checkout unchanged; using current profile: %s\n' "$profile"
fi
configure_shell_startup
printf 'Native Git reapply command:\n'
# shellcheck disable=SC2016
printf '  /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" sparse-checkout set --cone --stdin < "$HOME/%s/%s.paths"\n' "$PROFILE_DIR" "$profile"
prompt_read answer "Install optional software for '$profile'? [y/N]: " || exit 1
case "$answer" in
  y|Y|yes|YES)
    exec bash "$HOME/.dotfiles_setup/internal/install_programs.sh" --profile "$profile"
    ;;
  *)
    printf 'Software installation skipped. Rerun bootstrap whenever you want to install it.\n'
    ;;
esac
