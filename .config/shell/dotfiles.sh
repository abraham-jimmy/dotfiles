#! /usr/bin/env bash

# Bare repo wrapper
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

# Convenience aliases
alias dots='dotfiles status -s'
alias dotl='dotfiles lol2 -5'
alias dotlog='dotfiles lol2'
alias dotpush='dotfiles push origin main'
alias dotpull='dotfiles pull origin main'
alias dotcan='dotfiles commit --amend --no-edit'
alias dotdiff='dotfiles diff'
alias dotreset='dotfiles reset --hard'
alias dotundo='dotfiles reset --soft HEAD~1'

DOTDIRS=(
  .config/bob
  .config/nvim
  .config/nvim-new
  .config/sesh
  .config/shell
  .config/television
  .config/tmux
  .config/git
  .config/bash
  .config/zsh
  .config/wezterm
  .config/opencode
  .config/themes
  .config/alacritty
  .dotfiles_setup/
)

dotpick() {
  local choice name command description

  dotpick_entry() {
    printf '%s\t%s\t%s\n' "$1" "$2" "$3"
  }

  choice=$(
    {
      dotpick_entry "dotfiles" "bare repo git wrapper" 'Use the bare dotfiles repo directly'
      dotpick_entry "dots" "dotfiles status -s" 'Show short tracked dotfiles status'
      dotpick_entry "dotl" "dotfiles lol2 -5" 'Show the latest 5 dotfiles commits'
      dotpick_entry "dotlog" "dotfiles lol2" 'Show dotfiles commit history'
      dotpick_entry "dotdiff" "dotfiles diff" 'Show working tree diff for dotfiles'
      dotpick_entry "dotpull" "dotfiles pull origin main" 'Pull latest dotfiles from origin/main'
      dotpick_entry "dotpush" "dotfiles push origin main" 'Push current dotfiles branch to origin/main'
      dotpick_entry "dotcan" "dotfiles commit --amend --no-edit" 'Amend the last dotfiles commit without editing the message'
      dotpick_entry "dotreset" "dotfiles reset --hard" 'Hard reset dotfiles working tree to HEAD'
      dotpick_entry "dotundo" "dotfiles reset --soft HEAD~1" 'Undo the last dotfiles commit but keep changes staged'
      dotpick_entry "dotc" "dotc \"message\"" 'Commit staged dotfiles with a message, then show status'
      dotpick_entry "dotau" "dotau" 'Stage tracked updates plus configured dotfiles directories'
      dotpick_entry "dotadd" "dotadd <path>" 'Stage a specific path in the dotfiles repo'
      dotpick_entry "dotsync" "dotsync" 'Stage, suggest a commit message, commit, and push dotfiles'
      dotpick_entry "dot_smart_commit_message" "dot_smart_commit_message" 'Suggest a dotfiles commit message from staged changes'
      dotpick_entry "dotsetup" "dotsetup [args]" 'Run the dotfiles setup script'
      dotpick_entry "ds" "ds [args]" 'Alias for dotsetup'
    } |
      fzf \
        --prompt='Dotfiles Aliases > ' \
        --height=45% \
        --layout=reverse \
        --delimiter=$'\t' \
        --with-nth=1 \
        --preview='printf "%s\n\n%s\n" {2} {3}' \
        --preview-window='right:55%:wrap'
  ) || return

  IFS=$'\t' read -r name command description <<< "$choice"
  printf '%s\n' "$name"
}

alias dota='dotpick'

# Commit with message
dotc() {
  dotfiles commit -m "$1"
  dots
}

# Add tracked updates + configured dirs
dotau() {
  /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add -u

  for dir in "${DOTDIRS[@]}"; do
    if [[ -d "$HOME/$dir" ]]; then
      /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add "$HOME/$dir"
    fi
  done

  dots
}

# Add specific files
dotadd() {
  dotfiles add "$@"
  dots
}

# Hybrid smart commit message (Conventional Commits + fast heuristics)
dot_smart_commit_message() {
  local file_status p1 p2 path scope type action subject scope_text scope_list file_label stats stat_parts
  local -i docs_only=1
  local -i add_count=0 del_count=0 mod_count=0 file_count=0
  local -a scopes=()
  local -a unmapped_paths=()
  typeset -A seen_scopes
  typeset -A seen_unmapped

  typeset -g -a DOTSMART_UNMAPPED_PATHS
  typeset -g -i DOTSMART_UNMAPPED_COUNT
  DOTSMART_UNMAPPED_PATHS=()
  DOTSMART_UNMAPPED_COUNT=0

  while IFS=$'\t' read -r file_status p1 p2; do
    [[ -z "$file_status" ]] && continue
    ((file_count++))

    case "$file_status" in
      A*) ((add_count++)) ;;
      D*) ((del_count++)) ;;
      *)  ((mod_count++)) ;;
    esac

    path="$p1"
    [[ "$file_status" == R* || "$file_status" == C* ]] && path="$p2"

    case "$path" in
      *.md|*.txt|*.adoc|*.rst|*/README|*/README.*|README|README.*)
        ;;
      *)
        docs_only=0
        ;;
    esac

    case "$path" in
      .config/bob/*)     scope="bob" ;;
      .config/nvim/*)    scope="nvim" ;;
      .config/nvim-new/*) scope="nvim-new" ;;
      .config/shell/*)   scope="shell" ;;
      .config/tmux/*)    scope="tmux" ;;
      .config/git/*)     scope="git" ;;
      .config/bash/*|.bash*) scope="bash" ;;
      .config/zsh/*|.zsh*)   scope="zsh" ;;
      .config/wezterm/*) scope="wezterm" ;;
      .config/opencode/*) scope="opencode" ;;
      .config/*)
        scope="config"
        if [[ -z "${seen_unmapped[$path]}" ]]; then
          unmapped_paths+=("$path")
          seen_unmapped[$path]=1
        fi
        ;;
      *)
        scope="home"
        if [[ -z "${seen_unmapped[$path]}" ]]; then
          unmapped_paths+=("$path")
          seen_unmapped[$path]=1
        fi
        ;;
    esac

    if [[ -z "${seen_scopes[$scope]}" ]]; then
      scopes+=("$scope")
      seen_scopes[$scope]=1
    fi
  done < <(dotfiles diff --cached --name-status)

  if (( file_count == 0 )); then
    echo "chore(config): update settings"
    return
  fi

  if (( docs_only == 1 )); then
    type="docs"
  elif (( add_count > 0 && del_count == 0 && mod_count == 0 )); then
    type="feat"
  else
    type="chore"
  fi

  if (( add_count > 0 && del_count == 0 && mod_count == 0 )); then
    action="add"
  elif (( del_count > 0 && add_count == 0 && mod_count == 0 )); then
    action="remove"
  else
    action="update"
  fi

  scope_list="${(j:, :)scopes}"

  if (( ${#scopes[@]} == 1 )); then
    scope_text="${scopes[1]}"
  else
    scope_text="config"
  fi

  if (( docs_only == 1 )); then
    if (( ${#scopes[@]} == 0 )); then
      subject="docs"
    else
      subject="${scope_list} docs"
    fi
  elif (( ${#scopes[@]} == 1 )); then
    subject="${scopes[1]} settings"
  else
    subject="${scope_list} settings"
  fi

  file_label="files"
  (( file_count == 1 )) && file_label="file"
  stat_parts=""
  (( add_count > 0 )) && stat_parts+=" +${add_count}"
  (( mod_count > 0 )) && stat_parts+=" ~${mod_count}"
  (( del_count > 0 )) && stat_parts+=" -${del_count}"
  stat_parts="${stat_parts# }"

  if [[ -n "$stat_parts" ]]; then
    stats="(${file_count} ${file_label}: ${stat_parts})"
  else
    stats="(${file_count} ${file_label})"
  fi

  DOTSMART_UNMAPPED_PATHS=("${unmapped_paths[@]}")
  DOTSMART_UNMAPPED_COUNT=${#unmapped_paths[@]}

  echo "${type}(${scope_text}): ${action} ${subject} ${stats}"
}

# Add -> commit -> push workflow
dotsync() {
  local c_reset c_green c_yellow c_blue c_cyan
  c_reset=$'\033[0m'
  c_green=$'\033[32m'
  c_yellow=$'\033[33m'
  c_blue=$'\033[34m'
  c_cyan=$'\033[36m'

  printf "%b\n" "${c_blue}==> dotsync${c_reset} staging tracked dotfiles"
  dotau
  if dotfiles diff --cached --quiet; then
    printf "%b\n" "${c_yellow}No changes staged.${c_reset}"
    return
  fi

  local suggested_msg msg action_choice edited_msg
  suggested_msg="$(dot_smart_commit_message)"

  if (( ${#suggested_msg} > 72 )); then
    printf "%b\n" "${c_yellow}Recommendation:${c_reset} subject is long (${#suggested_msg} chars). Consider shortening scope text before commit."
  fi

  if (( DOTSMART_UNMAPPED_COUNT > 0 )); then
    local preview
    preview="${DOTSMART_UNMAPPED_PATHS[1]}"
    (( DOTSMART_UNMAPPED_COUNT > 1 )) && preview+=" (+$(( DOTSMART_UNMAPPED_COUNT - 1 )) more)"
    printf "%b\n" "${c_yellow}Warning:${c_reset} unmapped path pattern detected: ${preview}"
    printf "%b\n" "${c_yellow}Tip:${c_reset} add a scope mapping in dot_smart_commit_message for better commit scopes."
  fi

  printf "%b\n" "${c_cyan}Suggested message${c_reset}: ${c_green}${suggested_msg}${c_reset}"
  printf "%b" "${c_cyan}Action${c_reset} [enter=use, e=edit, n=new]: "
  read -r action_choice

  case "${action_choice:l}" in
    "")
      msg="$suggested_msg"
      ;;
    e|edit)
      msg="$suggested_msg"
      if whence vared >/dev/null 2>&1; then
        vared -p "Edit commit message: " -c msg
      else
        printf "%b" "${c_cyan}Edited message${c_reset} (enter keeps suggested): "
        read -r edited_msg
        [[ -n "$edited_msg" ]] && msg="$edited_msg"
      fi
      ;;
    n|new)
      printf "%b" "${c_cyan}New commit message${c_reset}: "
      read -r msg
      ;;
    *)
      msg="$suggested_msg"
      printf "%b\n" "${c_yellow}Unknown action '${action_choice}', using suggested message.${c_reset}"
      ;;
  esac

  [[ -z "$msg" ]] && msg="$suggested_msg"
  printf "%b\n" "${c_green}Using message:${c_reset} $msg"

  dotfiles commit -m "$msg" || return
  printf "%b\n" "${c_blue}==>${c_reset} pushing to origin/main"
  dotpush
  printf "%b\n" "${c_green}Done.${c_reset} latest commits:"
  dotl
}

#########################
# DOTFILES SETUP REMINDER
#########################

# Initialize bare repo
# git init --bare ~/.dotfiles
# dotfiles config status.showUntrackedFiles no

# On a new system
# git clone --bare <git-repo-url> $HOME/.dotfiles
# alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
# dotfiles checkout
# dotfiles config --local status.showUntrackedFiles no
