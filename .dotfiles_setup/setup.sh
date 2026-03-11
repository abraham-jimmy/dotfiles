#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *) ;;
  esac
done

LOG_DEPTH=0
MODULE_COUNT=0
CURRENT_MODULE=""
CURRENT_TASK=""
SUMMARY_MODULES=0
SUMMARY_TASKS=0
SUMMARY_PLANS=0
SUMMARY_RUNS=0
SUMMARY_SKIPS=0
SUMMARY_WARNS=0
SUMMARY_ERRORS=0

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  COLOR_RESET=$'\033[0m'
  COLOR_DIM=$'\033[2m'
  COLOR_BLUE=$'\033[34m'
  COLOR_CYAN=$'\033[36m'
  COLOR_GREEN=$'\033[32m'
  COLOR_YELLOW=$'\033[33m'
  COLOR_RED=$'\033[31m'
  COLOR_MAGENTA=$'\033[35m'
else
  COLOR_RESET=""
  COLOR_DIM=""
  COLOR_BLUE=""
  COLOR_CYAN=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_RED=""
  COLOR_MAGENTA=""
fi

indent_prefix() {
  local prefix=""
  local i

  if [ "$LOG_DEPTH" -gt 0 ]; then
    for ((i = 1; i < LOG_DEPTH; i++)); do
      prefix+="|  "
    done
    prefix+="+- "
  fi

  printf '%s' "$prefix"
}

log_emit() {
  local level="$1"
  local color="$2"
  local message="$3"
  local prefix line

  prefix="$(indent_prefix)"
  while IFS= read -r line || [ -n "$line" ]; do
    printf '%b%s[%-6s]%b %s\n' "$color" "$prefix" "$level" "$COLOR_RESET" "$line"
  done <<< "$message"
}

info() { log_emit "INFO" "$COLOR_BLUE" "$*"; }
warn() { SUMMARY_WARNS=$((SUMMARY_WARNS + 1)); log_emit "WARN" "$COLOR_YELLOW" "$*"; }
error() { SUMMARY_ERRORS=$((SUMMARY_ERRORS + 1)); log_emit "ERROR" "$COLOR_RED" "$*"; }
done_log() { log_emit "DONE" "$COLOR_GREEN" "$*"; }
plan() { SUMMARY_PLANS=$((SUMMARY_PLANS + 1)); log_emit "PLAN" "$COLOR_CYAN" "$*"; }
skip() { SUMMARY_SKIPS=$((SUMMARY_SKIPS + 1)); log_emit "SKIP" "$COLOR_DIM" "$*"; }
module_log() { log_emit "MODULE" "$COLOR_MAGENTA" "$*"; }
task_log() { log_emit "TASK" "$COLOR_CYAN" "$*"; }
run_log() { SUMMARY_RUNS=$((SUMMARY_RUNS + 1)); log_emit "RUN" "$COLOR_DIM" "$*"; }
log() { info "$*"; }

show_text() {
  local text="$1"
  local prefix line

  prefix="$(indent_prefix)"
  while IFS= read -r line || [ -n "$line" ]; do
    printf '%s%s\n' "$prefix" "$line"
  done <<< "$text"
}

enter_module() {
  local name="$1"

  if [ "$MODULE_COUNT" -gt 0 ]; then
    printf '\n'
  fi

  CURRENT_MODULE="$name"
  MODULE_COUNT=$((MODULE_COUNT + 1))
  SUMMARY_MODULES=$((SUMMARY_MODULES + 1))
  module_log "$name"
  LOG_DEPTH=$((LOG_DEPTH + 1))
}

leave_module() {
  local name="${1:-$CURRENT_MODULE}"

  LOG_DEPTH=$((LOG_DEPTH - 1))
  done_log "completed $name"
  CURRENT_MODULE=""
}

enter_task() {
  CURRENT_TASK="$1"
  SUMMARY_TASKS=$((SUMMARY_TASKS + 1))
  task_log "$CURRENT_TASK"
  LOG_DEPTH=$((LOG_DEPTH + 1))
}

leave_task() {
  local name="${1:-$CURRENT_TASK}"

  LOG_DEPTH=$((LOG_DEPTH - 1))
  done_log "completed $name"
  CURRENT_TASK=""
}

run() {
  local cmd="$*"

  if [ "$DRY_RUN" -eq 1 ]; then
    plan "would run: $cmd"
    return 0
  fi

  run_log "$cmd"
  eval "$cmd"
}

list_setup_functions() {
  declare -F | awk '$3 ~ /^setup_/ { print $3 }' | sort
}

summary_print() {
  local summary

  printf -v summary 'modules: %s\ntasks: %s\nplanned actions: %s\nexecuted commands: %s\nskipped items: %s\nwarnings: %s\nerrors: %s' \
    "$SUMMARY_MODULES" \
    "$SUMMARY_TASKS" \
    "$SUMMARY_PLANS" \
    "$SUMMARY_RUNS" \
    "$SUMMARY_SKIPS" \
    "$SUMMARY_WARNS" \
    "$SUMMARY_ERRORS"

  printf '\n'
  log_emit "SUMMARY" "$COLOR_MAGENTA" "$summary"
}

on_error() {
  local exit_code=$?
  local line_no="$1"
  local command="$2"
  local location="setup"

  if [ -n "$CURRENT_MODULE" ]; then
    location="$CURRENT_MODULE"
    if [ -n "$CURRENT_TASK" ]; then
      location+=" / $CURRENT_TASK"
    fi
  fi

  error "failed in $location at line $line_no"
  error "command: $command"
  exit "$exit_code"
}

trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

export DRY_RUN
export -f done_log enter_module enter_task error info leave_module leave_task list_setup_functions log log_emit module_log on_error plan run run_log show_text skip summary_print task_log warn

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$SCRIPT_DIR/modules"

declare -A SETUP_FN_MODULE=()
declare -A KNOWN_SETUP_FNS=()

source "$MODULE_DIR/distro.sh"
source "$MODULE_DIR/installer.sh"
source "$MODULE_DIR/programs.sh"

while IFS= read -r fn; do
  KNOWN_SETUP_FNS["$fn"]=1
done < <(list_setup_functions)

for f in "$MODULE_DIR"/*.sh; do
  case "$(basename "$f")" in
    distro.sh|installer.sh|programs.sh) continue ;;
  esac
  source "$f"

  while IFS= read -r fn; do
    if [ -z "${KNOWN_SETUP_FNS[$fn]:-}" ]; then
      KNOWN_SETUP_FNS["$fn"]=1
      SETUP_FN_MODULE["$fn"]="$f"
    fi
  done < <(list_setup_functions)
done

if [ "$DRY_RUN" -eq 1 ]; then
  info "setup start (dry-run)"
else
  info "setup start"
fi

enter_module "modules/programs.sh"
enter_task "install_all_programs"
install_all_programs
leave_task "install_all_programs"
leave_module "modules/programs.sh"

mapfile -t setup_fns < <(printf '%s\n' "${!SETUP_FN_MODULE[@]}" | sort)

current_module=""

for fn in "${setup_fns[@]}"; do
  module_path="${SETUP_FN_MODULE[$fn]}"
  module_name="${module_path#"$SCRIPT_DIR/"}"

  if [ "$module_path" != "$current_module" ]; then
    if [ -n "$current_module" ]; then
      leave_module "${current_module#"$SCRIPT_DIR/"}"
    fi

    enter_module "$module_name"
    current_module="$module_path"
  fi

  enter_task "$fn"
  "$fn"
  leave_task "$fn"
done

if [ -n "$current_module" ]; then
  leave_module "${current_module#"$SCRIPT_DIR/"}"
fi

printf '\n'
done_log "setup complete"
summary_print
