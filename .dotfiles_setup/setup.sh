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
SUMMARY_FAILED_TASKS=0
TASK_FAILURES=""
SUMMARY_EVENT_FILE="$(mktemp)"
SUMMARY_WARNING_FILE="$(mktemp)"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  COLOR_RESET=$'\033[0m'
  COLOR_DIM=$'\033[2m'
  COLOR_BLUE=$'\033[34m'
  COLOR_CYAN=$'\033[36m'
  COLOR_GREEN=$'\033[32m'
  COLOR_YELLOW=$'\033[33m'
  COLOR_RED=$'\033[31m'
  COLOR_MAGENTA=$'\033[35m'
  COLOR_TABLE_BORDER=$'\033[2;37m'
  COLOR_TABLE_TEXT=$'\033[36m'
  COLOR_TABLE_NUMBER=$'\033[34m'
else
  COLOR_RESET=""
  COLOR_DIM=""
  COLOR_BLUE=""
  COLOR_CYAN=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_RED=""
  COLOR_MAGENTA=""
  COLOR_TABLE_BORDER=""
  COLOR_TABLE_TEXT=""
  COLOR_TABLE_NUMBER=""
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

count_event() {
  [ -n "${SUMMARY_EVENT_FILE:-}" ] || return 0
  printf '%s\n' "$1" >>"$SUMMARY_EVENT_FILE"
}

info() { log_emit "INFO" "$COLOR_BLUE" "$*"; }
warn() {
  SUMMARY_WARNS=$((SUMMARY_WARNS + 1))
  count_event "warn"
  append_warning "$*"
  log_emit "WARN" "$COLOR_YELLOW" "$*"
}
error() { SUMMARY_ERRORS=$((SUMMARY_ERRORS + 1)); count_event "error"; log_emit "ERROR" "$COLOR_RED" "$*"; }
done_log() { log_emit "DONE" "$COLOR_GREEN" "$*"; }
plan() { SUMMARY_PLANS=$((SUMMARY_PLANS + 1)); count_event "plan"; log_emit "PLAN" "$COLOR_CYAN" "$*"; }
skip() { SUMMARY_SKIPS=$((SUMMARY_SKIPS + 1)); count_event "skip"; log_emit "SKIP" "$COLOR_DIM" "$*"; }
module_log() { log_emit "MODULE" "$COLOR_MAGENTA" "$*"; }
task_log() { log_emit "TASK" "$COLOR_CYAN" "$*"; }
run_log() { SUMMARY_RUNS=$((SUMMARY_RUNS + 1)); count_event "run"; log_emit "RUN" "$COLOR_DIM" "$*"; }
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

record_task_failure_state() {
  local exit_code="$1"
  local line_no="$2"
  local command="$3"
  local reason="${4:-}"

  [ -n "${TASK_ERROR_FILE:-}" ] || return 0

  {
    printf 'TASK_ERROR_EXIT_CODE=%q\n' "$exit_code"
    printf 'TASK_ERROR_LINE=%q\n' "$line_no"
    printf 'TASK_ERROR_COMMAND=%q\n' "$command"
    printf 'TASK_ERROR_REASON=%q\n' "$reason"
  } >"$TASK_ERROR_FILE"
}

task_fail() {
  local reason="$1"
  local exit_code="${2:-1}"
  local line_no="${BASH_LINENO[0]:-${LINENO}}"
  local command="${FUNCNAME[1]:-$CURRENT_TASK}"

  record_task_failure_state "$exit_code" "$line_no" "$command" "$reason"
  return "$exit_code"
}

list_setup_functions() {
  declare -F | awk '$3 ~ /^setup_/ { print $3 }' | sort
}

summary_print() {
  local plans runs skips warns errors event

  plans=0
  runs=0
  skips=0
  warns=0
  errors=0

  while IFS= read -r event; do
    case "$event" in
      plan) plans=$((plans + 1)) ;;
      run) runs=$((runs + 1)) ;;
      skip) skips=$((skips + 1)) ;;
      warn) warns=$((warns + 1)) ;;
      error) errors=$((errors + 1)) ;;
    esac
  done <"$SUMMARY_EVENT_FILE"

  SUMMARY_PLANS=$plans
  SUMMARY_RUNS=$runs
  SUMMARY_SKIPS=$skips
  SUMMARY_WARNS=$warns
  SUMMARY_ERRORS=$errors

  summary_table_print
  summary_issue_table_print
  summary_warnings_print
  summary_failures_print
}

summary_inner_width() {
  local -n widths_ref=$1
  local total=-1
  local width

  for width in "${widths_ref[@]}"; do
    total=$((total + width + 3))
  done

  printf '%s' "$total"
}

summary_table_span_border() {
  local width="$1"
  printf '%b+%s+%b\n' "$COLOR_TABLE_BORDER" "$(printf '%*s' "$width" '' | tr ' ' '-')" "$COLOR_RESET"
}

summary_table_span_row() {
  local label="$1"
  local width="$2"
  local color="$3"

  printf '%b| %b%-*s%b %b|%b\n' \
    "$COLOR_TABLE_BORDER" \
    "$color" \
    $((width - 2)) \
    "$label" \
    "$COLOR_RESET" \
    "$COLOR_TABLE_BORDER" \
    "$COLOR_RESET"
}

summary_table_border() {
  local -n widths_ref=$1
  local border="+"
  local width

  for width in "${widths_ref[@]}"; do
    border+="$(printf '%*s' "$((width + 2))" '' | tr ' ' '-')+"
  done

  printf '%b%s%b\n' "$COLOR_TABLE_BORDER" "$border" "$COLOR_RESET"
}

summary_table_row() {
  local kind="$1"
  shift
  local -n widths_ref=$1
  shift
  local cells=("$@")
  local color line="|"
  local i value width

  for ((i = 0; i < ${#cells[@]}; i++)); do
    value="${cells[$i]}"
    width="${widths_ref[$i]}"

    case "$kind:$i" in
      issue_value:*) color="$COLOR_RED" ;;
      issue_header:*) color="$COLOR_RED" ;;
      header:*) color="$COLOR_TABLE_TEXT" ;;
      *) color="$COLOR_TABLE_NUMBER" ;;
    esac

    line+=" ${color}$(printf '%-*s' "$width" "$value")${COLOR_RESET} ${COLOR_TABLE_BORDER}|${COLOR_RESET}"
  done

  printf '%b%s%b\n' "$COLOR_TABLE_BORDER" "$line" "$COLOR_RESET"
}

summary_table_print() {
  local headers=("modules" "tasks" "plans" "runs" "skips" "warns")
  local values=(
    "$SUMMARY_MODULES"
    "$SUMMARY_TASKS"
    "$SUMMARY_PLANS"
    "$SUMMARY_RUNS"
    "$SUMMARY_SKIPS"
    "$SUMMARY_WARNS"
  )
  local widths=()
  local i header_len value_len inner_width

  for ((i = 0; i < ${#headers[@]}; i++)); do
    header_len=${#headers[$i]}
    value_len=${#values[$i]}
    if [ "$header_len" -gt "$value_len" ]; then
      widths+=("$header_len")
    else
      widths+=("$value_len")
    fi
  done

  inner_width="$(summary_inner_width widths)"

  printf '\n'
  summary_table_span_border "$inner_width"
  summary_table_span_row "SUMMARY" "$inner_width" "$COLOR_TABLE_TEXT"
  summary_table_border widths
  summary_table_row header widths "${headers[@]}"
  summary_table_border widths
  summary_table_row value widths "${values[@]}"
  summary_table_border widths
}

summary_issue_table_print() {
  local headers=("errors" "failed tasks")
  local values=("$SUMMARY_ERRORS" "$SUMMARY_FAILED_TASKS")
  local widths=()
  local i header_len value_len inner_width

  if [ "$SUMMARY_ERRORS" -eq 0 ] && [ "$SUMMARY_FAILED_TASKS" -eq 0 ]; then
    return 0
  fi

  for ((i = 0; i < ${#headers[@]}; i++)); do
    header_len=${#headers[$i]}
    value_len=${#values[$i]}
    if [ "$header_len" -gt "$value_len" ]; then
      widths+=("$header_len")
    else
      widths+=("$value_len")
    fi
  done

  inner_width="$(summary_inner_width widths)"

  printf '\n'
  summary_table_span_border "$inner_width"
  summary_table_span_row "ISSUES" "$inner_width" "$COLOR_RED"
  summary_table_border widths
  summary_table_row issue_header widths "${headers[@]}"
  summary_table_border widths
  summary_table_row issue_value widths "${values[@]}"
  summary_table_border widths
}

append_warning() {
  local message="$1"
  local module_name="global"
  local task_name=""

  [ -n "${SUMMARY_WARNING_FILE:-}" ] || return 0

  if [ -n "$CURRENT_MODULE" ]; then
    module_name="$CURRENT_MODULE"
  fi

  if [ -n "$CURRENT_TASK" ]; then
    task_name="$CURRENT_TASK"
  fi

  printf '%s\t%s\t%s\n' "$module_name" "$task_name" "$message" >>"$SUMMARY_WARNING_FILE"
}

summary_warnings_print() {
  local line current_module="" current_task="" module_name task_name message

  [ -s "$SUMMARY_WARNING_FILE" ] || return 0

  printf '\n'
  printf '%b[WARNINGS]%b\n' "$COLOR_YELLOW" "$COLOR_RESET"

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    IFS=$'\t' read -r module_name task_name message <<< "$line"

    if [ "$module_name" != "$current_module" ]; then
      if [ -n "$current_module" ]; then
        printf '\n'
      fi
      printf '%b- %s%b\n' "$COLOR_YELLOW" "$module_name" "$COLOR_RESET"
      current_module="$module_name"
      current_task=""
    fi

    if [ -n "$task_name" ] && [ "$task_name" != "$current_task" ]; then
      printf '%b  +- %s%b\n' "$COLOR_YELLOW" "$task_name" "$COLOR_RESET"
      current_task="$task_name"
    fi

    if [ -n "$task_name" ]; then
      printf '%b  |  +- %s%b\n' "$COLOR_YELLOW" "$message" "$COLOR_RESET"
    else
      printf '%b  +- %s%b\n' "$COLOR_YELLOW" "$message" "$COLOR_RESET"
    fi
  done <"$SUMMARY_WARNING_FILE"
}

summary_failures_print() {
  local block first_line=1 line

  [ -n "$TASK_FAILURES" ] || return 0

  printf '\n'
  printf '%b[FAILURES]%b\n' "$COLOR_RED" "$COLOR_RESET"

  while IFS= read -r block; do
    [ -n "$block" ] || continue

    if [ "$first_line" -eq 0 ]; then
      printf '\n'
    fi

    while IFS= read -r line; do
      if [ -n "$line" ]; then
        printf '%b- %s%b\n' "$COLOR_RED" "$line" "$COLOR_RESET"
      fi
    done <<< "$block"

    first_line=0
  done < <(printf '%s' "$TASK_FAILURES" | awk 'BEGIN { RS="\n\n" } { print }')
}

on_task_error() {
  local line_no="$1"
  local command="$2"
  local exit_code="$3"
  local reason=""

  if [ -n "${TASK_ERROR_FILE:-}" ] && [ -s "$TASK_ERROR_FILE" ]; then
    # shellcheck disable=SC1090
    source "$TASK_ERROR_FILE"
    reason="${TASK_ERROR_REASON:-}"
  fi

  record_task_failure_state "$exit_code" "$line_no" "$command" "$reason"
}

append_task_failure() {
  local block="$1"

  if [ -n "$TASK_FAILURES" ]; then
    TASK_FAILURES+=$'\n\n'
  fi

  TASK_FAILURES+="$block"
}

task_failed() {
  local name="$1"
  local module_name="$2"
  local exit_code="$3"
  local error_file="$4"
  local line_no=""
  local command=""
  local reason=""
  local failure_block

  SUMMARY_FAILED_TASKS=$((SUMMARY_FAILED_TASKS + 1))
  LOG_DEPTH=$((LOG_DEPTH - 1))

  if [ -s "$error_file" ]; then
    # shellcheck disable=SC1090
    source "$error_file"
    line_no="${TASK_ERROR_LINE:-}"
    command="${TASK_ERROR_COMMAND:-}"
    reason="${TASK_ERROR_REASON:-}"
    exit_code="${TASK_ERROR_EXIT_CODE:-$exit_code}"
  fi

  error "task failed: $name"
  error "module: $module_name"
  error "exit: $exit_code"

  if [ -n "$line_no" ]; then
    error "line: $line_no"
  fi

  if [ -n "$command" ]; then
    error "command: $command"
  fi

  if [ -n "$reason" ]; then
    error "reason: $reason"
  fi

  warn "continuing to next task"

  printf -v failure_block 'task: %s\nmodule: %s\nexit: %s' "$name" "$module_name" "$exit_code"

  if [ -n "$line_no" ]; then
    failure_block+=$'\n'
    failure_block+="line: $line_no"
  fi

  if [ -n "$command" ]; then
    failure_block+=$'\n'
    failure_block+="command: $command"
  fi

  if [ -n "$reason" ]; then
    failure_block+=$'\n'
    failure_block+="reason: $reason"
  fi

  append_task_failure "$failure_block"
  CURRENT_TASK=""
}

run_task() {
  local name="$1"
  local module_name="$2"
  local error_file status

  error_file="$(mktemp)"
  enter_task "$name"

  if (
    set -Eeuo pipefail
    CURRENT_MODULE="$module_name"
    CURRENT_TASK="$name"
    TASK_ERROR_FILE="$error_file"
    trap 'on_task_error "$LINENO" "$BASH_COMMAND" "$?"' ERR
    "$name"
  ); then
    leave_task "$name"
  else
    status=$?
    task_failed "$name" "$module_name" "$status" "$error_file"
  fi

  rm -f "$error_file"
}

export DRY_RUN SUMMARY_EVENT_FILE SUMMARY_WARNING_FILE
export -f append_task_failure count_event done_log enter_module enter_task error info leave_module leave_task list_setup_functions log log_emit module_log on_task_error plan record_task_failure_state run run_log run_task show_text skip summary_print task_fail task_failed task_log warn

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
run_task "install_all_programs" "modules/programs.sh"
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

  run_task "$fn" "$module_name"
done

if [ -n "$current_module" ]; then
  leave_module "${current_module#"$SCRIPT_DIR/"}"
fi

printf '\n'
done_log "setup complete"
summary_print
rm -f "$SUMMARY_EVENT_FILE"
rm -f "$SUMMARY_WARNING_FILE"
