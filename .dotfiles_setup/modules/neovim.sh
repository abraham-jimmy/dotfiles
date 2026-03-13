#!/usr/bin/env bash
set -euo pipefail

ensure_bob() {
  local bob_path expected_bin expected_dir install_cmd

  export PATH="$HOME/.local/bin:$PATH"
  expected_bin="$HOME/.local/bin/bob"
  expected_dir="$HOME/.local/share/bob_bin"

  if command -v bob >/dev/null 2>&1; then
    skip "bob already installed: $(command -v bob)"
    return 0
  fi

  info "installing bob"

  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    run 'curl -fsSL "https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh" | bash'
    return 0
  fi

  install_cmd='curl -fsSL "https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh" | bash'

  if run "$install_cmd"; then
    bob_path="$(command -v bob || true)"

    if [ -n "$bob_path" ] && [ -x "$bob_path" ]; then
      done_log "bob ready"
      return 0
    fi

    if [ -x "$expected_bin" ]; then
      done_log "bob ready: $expected_bin"
      return 0
    fi

    error "bob installer completed, but bob is still unavailable"
    error "checked: $expected_bin"
    error "expected install dir: $expected_dir"
    error "PATH: $PATH"
    task_fail "bob installer completed, but bob is still unavailable"
  fi

  task_fail "bob install failed; skipping Neovim setup"
}

setup_19_neovim() {
  local install_flag nvim_version nvim_proxy

  install_flag="${INSTALL_NEOVIM:-auto}"
  case "$install_flag" in
    0|false|FALSE|no|NO)
      skip "Skipping Neovim setup (INSTALL_NEOVIM=$install_flag)"
      return
      ;;
  esac

  write_if_changed "$HOME/.config/bob/config.json" $'{\n  "add_neovim_binary_to_path": false\n}\n'

  ensure_bob || return

  nvim_version="${NVIM_VERSION:-nightly}"
  info "Neovim target version: $nvim_version"

  case "$nvim_version" in
    stable|nightly)
      run "bob update \"$nvim_version\" || bob install \"$nvim_version\""
      run "bob use \"$nvim_version\""
      ;;
    latest)
      run "bob install latest"
      run "bob use latest"
      ;;
    *)
      run "bob use \"$nvim_version\""
      ;;
  esac

  nvim_proxy="$HOME/.local/share/bob/nvim-bin/nvim"
  run "mkdir -p \"$HOME/.local/bin\""
  run "ln -sfn \"$nvim_proxy\" \"$HOME/.local/bin/nvim\""
  run "ln -sfn \"$nvim_proxy\" \"$HOME/.local/bin/vim\""

  if [ "${DRY_RUN:-0}" -eq 0 ]; then
    done_log "Neovim selected via bob ($nvim_version)"
  fi
}
