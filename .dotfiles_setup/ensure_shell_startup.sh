#!/usr/bin/env bash

set -euo pipefail

readonly START_MARKER='# >>> dotfiles startup >>>'
readonly END_MARKER='# <<< dotfiles startup <<<'
readonly EXCLUDE_START='# >>> generated shell startup files >>>'
readonly EXCLUDE_END='# <<< generated shell startup files <<<'
SELF_TEST_ROOT=
TEMP_FILES=()

usage() {
  printf 'Usage: %s [--home DIR] [--git-dir DIR] [--self-test]\n' "${0##*/}"
}

render_block() {
  case "$1" in
    zshrc)
      cat <<'EOF'
# >>> dotfiles startup >>>
[[ -r "$HOME/.config/zsh/.zshrc" ]] && source "$HOME/.config/zsh/.zshrc"
# <<< dotfiles startup <<<
EOF
      ;;
    bashrc)
      cat <<'EOF'
# >>> dotfiles startup >>>
if [[ $- == *i* ]]; then
  DOTFILES_BASHRC_LOADED=1
  [[ -r "$HOME/.config/bash/.bashrc" ]] && source "$HOME/.config/bash/.bashrc"
fi
# <<< dotfiles startup <<<
EOF
      ;;
    bash_profile)
      cat <<'EOF'
# >>> dotfiles startup >>>
[[ -r "$HOME/.profile" ]] && source "$HOME/.profile"
if [[ $- == *i* && -z "${DOTFILES_BASHRC_LOADED:-}" && -r "$HOME/.bashrc" ]]; then
  source "$HOME/.bashrc"
fi
# <<< dotfiles startup <<<
EOF
      ;;
    *)
      printf 'Unknown startup file kind: %s\n' "$1" >&2
      return 1
      ;;
  esac
}

render_legacy_stub() {
  case "$1" in
    zshrc)
      cat <<'EOF'
[[ -r "$HOME/.config/zsh/.zshrc" ]] && source "$HOME/.config/zsh/.zshrc"
EOF
      ;;
    bashrc)
      cat <<'EOF'
[[ $- != *i* ]] && return
[ -r "$HOME/.config/bash/.bashrc" ] && . "$HOME/.config/bash/.bashrc"
EOF
      ;;
    bash_profile)
      cat <<'EOF'
[ -r "$HOME/.profile" ] && . "$HOME/.profile"
[ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"
EOF
      ;;
  esac
}

validate_regular_target() {
  local target=$1
  if [[ -L "$target" ]]; then
    printf 'Refusing to replace symlink: %s\n' "$target" >&2
    return 1
  fi
  if [[ -e "$target" && ! -f "$target" ]]; then
    printf 'Refusing to replace non-regular file: %s\n' "$target" >&2
    return 1
  fi
  if [[ -f "$target" && $(stat -c '%h' "$target") -gt 1 ]]; then
    printf 'Refusing to detach hard-linked file: %s\n' "$target" >&2
    return 1
  fi
}

validate_startup_file() {
  local target=$1 kind=$2 block_tmp block_size start_count end_count
  validate_regular_target "$target" || return
  [[ -f "$target" ]] || return 0

  block_tmp=$(mktemp) || return
  TEMP_FILES+=("$block_tmp")
  render_block "$kind" > "$block_tmp" || return
  block_size=$(wc -c < "$block_tmp")

  if cmp -s -n "$block_size" "$block_tmp" "$target"; then
    start_count=$(grep -Fxc "$START_MARKER" "$target")
    end_count=$(grep -Fxc "$END_MARKER" "$target")
    if [[ $start_count -eq 1 && $end_count -eq 1 ]]; then
      return 0
    fi
    printf 'Refusing startup file with duplicate managed markers: %s\n' "$target" >&2
    return 1
  fi

  if cmp -s "$target" <(render_legacy_stub "$kind"); then
    return 0
  fi

  if grep -Fqx "$START_MARKER" "$target" || grep -Fqx "$END_MARKER" "$target"; then
    printf 'Refusing to rewrite an out-of-place or changed managed block: %s\n' "$target" >&2
    return 1
  fi

  case "$kind" in
    zshrc)
      if grep -Fq '.config/zsh/.zshrc' "$target"; then
        printf 'Refusing to add a duplicate dotfiles source to: %s\n' "$target" >&2
        return 1
      fi
      ;;
    bashrc)
      if grep -Fq '.config/bash/.bashrc' "$target"; then
        printf 'Refusing to add a duplicate dotfiles source to: %s\n' "$target" >&2
        return 1
      fi
      ;;
    bash_profile)
      if grep -Eq '\.(profile|bashrc)([^[:alnum:]_]|$)' "$target"; then
        printf 'Refusing to add duplicate profile startup to: %s\n' "$target" >&2
        return 1
      fi
      ;;
  esac
}

ensure_startup_file() {
  local target=$1 kind=$2 parent block_tmp output_tmp block_size legacy=0
  parent=${target%/*}

  mkdir -p "$parent" || return
  block_tmp=$(mktemp "$parent/.dotfiles-startup.block.XXXXXX") || return
  TEMP_FILES+=("$block_tmp")
  output_tmp=$(mktemp "$parent/.dotfiles-startup.output.XXXXXX") || return
  TEMP_FILES+=("$output_tmp")
  render_block "$kind" > "$block_tmp" || return

  if [[ -f "$target" ]]; then
    block_size=$(wc -c < "$block_tmp")
    if cmp -s -n "$block_size" "$block_tmp" "$target"; then
      rm -f -- "$block_tmp" "$output_tmp"
      return 0
    fi

    if cmp -s "$target" <(render_legacy_stub "$kind"); then
      legacy=1
    fi

    cat "$block_tmp" > "$output_tmp" || return
    if [[ $legacy -eq 0 ]]; then
      printf '\n' >> "$output_tmp" || return
      cat "$target" >> "$output_tmp" || return
    fi
    cp --attributes-only --preserve=mode,ownership,xattr "$target" "$output_tmp" || return
  else
    cat "$block_tmp" > "$output_tmp" || return
    chmod 600 "$output_tmp" || return
  fi

  mv -f -- "$output_tmp" "$target" || return
  rm -f -- "$block_tmp"
  printf 'Configured untracked startup file: %s\n' "$target"
}

validate_git_excludes() {
  local exclude_file=$1 line state=before index=0
  local expected=(/.bash_profile /.bashrc /.zshenv /.zshrc)
  validate_regular_target "$exclude_file" || return
  [[ -f "$exclude_file" ]] || return 0

  while IFS= read -r line || [[ -n $line ]]; do
    case "$state" in
      before)
        if [[ $line == "$EXCLUDE_START" ]]; then
          state=inside
        elif [[ $line == "$EXCLUDE_END" ]]; then
          printf 'Refusing malformed managed exclude block: %s\n' "$exclude_file" >&2
          return 1
        fi
        ;;
      inside)
        if [[ $line == "$EXCLUDE_END" && $index -eq ${#expected[@]} ]]; then
          state=after
        elif [[ $index -lt ${#expected[@]} && $line == "${expected[$index]}" ]]; then
          ((index += 1))
        else
          printf 'Refusing changed managed exclude block: %s\n' "$exclude_file" >&2
          return 1
        fi
        ;;
      after)
        if [[ $line == "$EXCLUDE_START" || $line == "$EXCLUDE_END" ]]; then
          printf 'Refusing duplicate managed exclude block: %s\n' "$exclude_file" >&2
          return 1
        fi
        ;;
    esac
  done < "$exclude_file"

  if [[ $state == inside ]]; then
    printf 'Refusing incomplete managed exclude block: %s\n' "$exclude_file" >&2
    return 1
  fi
}

ensure_git_excludes() {
  local exclude_file=$1 parent block_tmp output_tmp
  parent=${exclude_file%/*}
  mkdir -p "$parent" || return

  if [[ -f "$exclude_file" ]] && grep -Fqx "$EXCLUDE_START" "$exclude_file"; then
    return 0
  fi

  block_tmp=$(mktemp "$parent/.dotfiles-exclude.block.XXXXXX") || return
  TEMP_FILES+=("$block_tmp")
  output_tmp=$(mktemp "$parent/.dotfiles-exclude.output.XXXXXX") || return
  TEMP_FILES+=("$output_tmp")
  cat > "$block_tmp" <<'EOF'
# >>> generated shell startup files >>>
/.bash_profile
/.bashrc
/.zshenv
/.zshrc
# <<< generated shell startup files <<<
EOF

  if [[ -f "$exclude_file" && -s "$exclude_file" ]]; then
    cat "$exclude_file" > "$output_tmp" || return
    if [[ $(tail -c 1 "$exclude_file" | wc -l) -eq 0 ]]; then
      printf '\n' >> "$output_tmp"
    fi
    printf '\n' >> "$output_tmp"
  fi
  cat "$block_tmp" >> "$output_tmp" || return
  chmod 600 "$output_tmp" || return
  mv -f -- "$output_tmp" "$exclude_file" || return
  rm -f -- "$block_tmp"
  printf 'Excluded generated startup files in: %s\n' "$exclude_file"
}

configure_startup_files() {
  local home=$1 git_dir=$2
  validate_startup_file "$home/.zshrc" zshrc || return
  validate_startup_file "$home/.bashrc" bashrc || return
  validate_startup_file "$home/.bash_profile" bash_profile || return
  validate_regular_target "$home/.zshenv" || return
  validate_git_excludes "$git_dir/info/exclude" || return

  ensure_startup_file "$home/.zshrc" zshrc || return
  ensure_startup_file "$home/.bashrc" bashrc || return
  ensure_startup_file "$home/.bash_profile" bash_profile || return
  ensure_git_excludes "$git_dir/info/exclude" || return

  if [[ -f "$home/.zshenv" ]] && cmp -s "$home/.zshenv" <(printf '%s\n' "export ZDOTDIR=\"\$HOME/.config/zsh\""); then
    rm -f -- "$home/.zshenv" || return
    printf 'Removed legacy tracked startup file: %s\n' "$home/.zshenv"
  elif [[ -f "$home/.zshenv" ]] && grep -Eq '^[[:space:]]*[^#]*ZDOTDIR[[:space:]]*=' "$home/.zshenv"; then
    printf 'Warning: %s sets ZDOTDIR and may bypass %s/.zshrc.\n' "$home/.zshenv" "$home" >&2
  fi
}

assert_file_contains() {
  local file=$1 text=$2
  grep -Fq "$text" "$file" || {
    printf 'Self-test failed: %s does not contain %s\n' "$file" "$text" >&2
    return 1
  }
}

cleanup_self_test() {
  if [[ -n ${SELF_TEST_ROOT:-} ]]; then
    rm -rf -- "$SELF_TEST_ROOT"
    SELF_TEST_ROOT=
  fi
}

cleanup() {
  if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
    rm -f -- "${TEMP_FILES[@]}"
  fi
  cleanup_self_test
}

self_test() {
  local test_root test_home test_git before after
  test_root=$(mktemp -d)
  SELF_TEST_ROOT=$test_root
  test_home="$test_root/home"
  test_git="$test_root/git"
  mkdir -p "$test_home"
  /usr/bin/git init --bare --quiet "$test_git"

  printf 'export PRIVATE_ZSH=1' > "$test_home/.zshrc"
  printf 'export PRIVATE_BASH=1\n' > "$test_home/.bashrc"
  printf '%s\n' "export ZDOTDIR=\"\$HOME/.config/zsh\"" > "$test_home/.zshenv"
  cp "$test_home/.zshrc" "$test_root/original.zshrc"
  chmod 640 "$test_home/.zshrc"
  configure_startup_files "$test_home" "$test_git" >/dev/null

  [[ $(stat -c '%a' "$test_home/.zshrc") == 640 ]]
  [[ ! -e "$test_home/.zshenv" ]]
  [[ $(sed -n '1p' "$test_home/.zshrc") == "$START_MARKER" ]]
  [[ $(sed -n '2p' "$test_home/.zshrc") == "[[ -r \"\$HOME/.config/zsh/.zshrc\" ]] && source \"\$HOME/.config/zsh/.zshrc\"" ]]
  cmp -s "$test_root/original.zshrc" <(tail -n +5 "$test_home/.zshrc")
  assert_file_contains "$test_home/.zshrc" 'export PRIVATE_ZSH=1'
  assert_file_contains "$test_home/.bashrc" 'export PRIVATE_BASH=1'
  assert_file_contains "$test_home/.bash_profile" 'DOTFILES_BASHRC_LOADED'
  assert_file_contains "$test_git/info/exclude" '/.zshenv'
  HOME="$test_home" bash --noprofile --norc -c 'source "$HOME/.bashrc"; [[ $PRIVATE_BASH == 1 ]]'
  /usr/bin/git -C "$test_home" --git-dir="$test_git" --work-tree="$test_home" check-ignore -q -- .zshrc

  before=$(cksum "$test_home/.zshrc" "$test_home/.bashrc" "$test_home/.bash_profile" "$test_git/info/exclude")
  configure_startup_files "$test_home" "$test_git" >/dev/null
  after=$(cksum "$test_home/.zshrc" "$test_home/.bashrc" "$test_home/.bash_profile" "$test_git/info/exclude")
  [[ "$before" == "$after" ]]

  printf '%s\n' "$START_MARKER" > "$test_home/.brokenrc"
  if validate_startup_file "$test_home/.brokenrc" zshrc >/dev/null 2>&1; then
    printf 'Self-test failed: malformed managed block was accepted\n' >&2
    return 1
  fi

  rm -f -- "$test_home/.zshrc" "$test_home/.bashrc" "$test_home/.bash_profile"
  render_legacy_stub zshrc > "$test_home/.zshrc"
  render_legacy_stub bashrc > "$test_home/.bashrc"
  render_legacy_stub bash_profile > "$test_home/.bash_profile"
  configure_startup_files "$test_home" "$test_git" >/dev/null
  [[ $(sed -n '1p' "$test_home/.zshrc") == "$START_MARKER" ]]
  [[ $(grep -Fc '.config/zsh/.zshrc' "$test_home/.zshrc") -eq 1 ]]

  rm -f -- "$test_home/.zshrc" "$test_home/.bashrc"
  printf 'private zsh\n' > "$test_home/.zshrc"
  ln -s "$test_home/.zshrc" "$test_home/.bashrc"
  before=$(cksum "$test_home/.zshrc")
  if configure_startup_files "$test_home" "$test_git" >/dev/null 2>&1; then
    printf 'Self-test failed: symlinked startup file was accepted\n' >&2
    return 1
  fi
  after=$(cksum "$test_home/.zshrc")
  [[ $before == "$after" ]]

  printf 'Shell startup helper self-test passed.\n'
  cleanup_self_test
}

main() {
  local home=${HOME:?HOME is not set} git_dir=${DOTFILES_DIR:-$HOME/.dotfiles}

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --home)
        [[ $# -ge 2 ]] || { usage >&2; return 2; }
        home=$2
        shift 2
        ;;
      --git-dir)
        [[ $# -ge 2 ]] || { usage >&2; return 2; }
        git_dir=$2
        shift 2
        ;;
      --self-test)
        self_test
        return
        ;;
      -h|--help)
        usage
        return
        ;;
      *)
        usage >&2
        return 2
        ;;
    esac
  done

  configure_startup_files "$home" "$git_dir"
}

trap cleanup EXIT
main "$@"
