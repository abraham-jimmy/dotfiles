#!/usr/bin/env bash
set -euo pipefail

NVIM_TOOLS_BIN_DIR="$HOME/.local/bin"
NVIM_TOOLS_OPT_DIR="$HOME/.local/opt/neovim-tools"

ensure_neovim_tool_dirs() {
  run "mkdir -p \"$NVIM_TOOLS_BIN_DIR\" \"$NVIM_TOOLS_OPT_DIR\""
}

linux_arch() {
  case "$(uname -m)" in
    x86_64|amd64) printf 'x86_64' ;;
    aarch64|arm64) printf 'arm64' ;;
    *) return 1 ;;
  esac
}

install_release_binary() {
  local cmd="$1"
  local url="$2"
  local tmp

  if command -v "$cmd" >/dev/null 2>&1; then
    skip "already installed: $cmd"
    return 0
  fi

  ensure_neovim_tool_dirs
  tmp="$(mktemp)"

  if run "curl -fL \"$url\" -o \"$tmp\"" && run "install -m 0755 \"$tmp\" \"$NVIM_TOOLS_BIN_DIR/$cmd\""; then
    if [ "${DRY_RUN:-0}" -eq 1 ]; then
      plan "would install '$cmd' from upstream release"
    else
      done_log "installed upstream binary: $cmd"
    fi
    rm -f "$tmp"
    return 0
  fi

  rm -f "$tmp"
  warn "unable to install upstream binary '$cmd'"
  return 1
}

install_release_archive_tool() {
  local cmd="$1"
  local url="$2"
  local archive_kind="$3"
  local binary_relpath="$4"
  local install_name="$5"
  local archive_path extract_dir install_dir

  if command -v "$cmd" >/dev/null 2>&1; then
    skip "already installed: $cmd"
    return 0
  fi

  ensure_neovim_tool_dirs
  archive_path="$(mktemp)"
  extract_dir="$(mktemp -d)"
  install_dir="$NVIM_TOOLS_OPT_DIR/$install_name"

  if ! run "curl -fL \"$url\" -o \"$archive_path\""; then
    rm -f "$archive_path"
    rm -rf "$extract_dir"
    warn "unable to download archive for '$cmd'"
    return 1
  fi

  case "$archive_kind" in
    tar.gz)
      if ! run "tar -xzf \"$archive_path\" -C \"$extract_dir\""; then
        rm -f "$archive_path"
        rm -rf "$extract_dir"
        warn "unable to extract archive for '$cmd'"
        return 1
      fi
      ;;
    zip|vsix)
      if ! run "unzip -o \"$archive_path\" -d \"$extract_dir\""; then
        rm -f "$archive_path"
        rm -rf "$extract_dir"
        warn "unable to extract archive for '$cmd'"
        return 1
      fi
      ;;
    *)
      rm -f "$archive_path"
      rm -rf "$extract_dir"
      warn "unknown archive kind '$archive_kind' for '$cmd'"
      return 1
      ;;
  esac

  if run "rm -rf \"$install_dir\"" && run "mkdir -p \"$install_dir\"" && run "cp -R \"$extract_dir\"/. \"$install_dir\"/" && run "ln -sfn \"$install_dir/$binary_relpath\" \"$NVIM_TOOLS_BIN_DIR/$cmd\""; then
    if [ "${DRY_RUN:-0}" -eq 1 ]; then
      plan "would install '$cmd' from upstream archive"
    else
      done_log "installed upstream archive tool: $cmd"
    fi
    rm -f "$archive_path"
    rm -rf "$extract_dir"
    return 0
  fi

  rm -f "$archive_path"
  rm -rf "$extract_dir"
  warn "unable to install upstream archive tool '$cmd'"
  return 1
}

note_manual_tool() {
  local cmd="$1"
  local reason="$2"

  if command -v "$cmd" >/dev/null 2>&1; then
    skip "already installed: $cmd"
    return 0
  fi

  warn "manual prerequisite '$cmd' is missing ($reason)"
  return 1
}

install_hyprls() {
  local version="${HYPRLS_VERSION:-v0.13.0}"
  local arch

  arch="$(linux_arch)" || {
    warn "unsupported architecture for hyprls"
    return 1
  }

  case "$arch" in
    x86_64) install_release_archive_tool hyprls "https://github.com/hyprland-community/hyprls/releases/download/${version}/hyprls-linux-x86_64.tar.gz" tar.gz hyprls "hyprls-${version}-linux-x86_64" ;;
    arm64) install_release_archive_tool hyprls "https://github.com/hyprland-community/hyprls/releases/download/${version}/hyprls-linux-aarch64.tar.gz" tar.gz hyprls "hyprls-${version}-linux-aarch64" ;;
  esac
}

install_marksman() {
  local version="${MARKSMAN_VERSION:-2026-02-08}"
  local arch

  arch="$(linux_arch)" || {
    warn "unsupported architecture for marksman"
    return 1
  }

  case "$arch" in
    x86_64) install_release_binary marksman "https://github.com/artempyanykh/marksman/releases/download/${version}/marksman-linux-x64" ;;
    arm64) install_release_binary marksman "https://github.com/artempyanykh/marksman/releases/download/${version}/marksman-linux-arm64" ;;
  esac
}

install_shfmt() {
  local version="${SHFMT_VERSION:-v3.13.0}"
  local arch

  arch="$(linux_arch)" || {
    warn "unsupported architecture for shfmt"
    return 1
  }

  case "$arch" in
    x86_64) install_release_binary shfmt "https://github.com/mvdan/sh/releases/download/${version}/shfmt_${version}_linux_amd64" ;;
    arm64) install_release_binary shfmt "https://github.com/mvdan/sh/releases/download/${version}/shfmt_${version}_linux_arm64" ;;
  esac
}

install_stylua() {
  local version="${STYLUA_VERSION:-v2.4.0}"
  local arch

  arch="$(linux_arch)" || {
    warn "unsupported architecture for stylua"
    return 1
  }

  case "$arch" in
    x86_64) install_release_archive_tool stylua "https://github.com/JohnnyMorganz/StyLua/releases/download/${version}/stylua-linux-x86_64.zip" zip stylua "stylua-${version}-linux-x86_64" ;;
    arm64) install_release_archive_tool stylua "https://github.com/JohnnyMorganz/StyLua/releases/download/${version}/stylua-linux-aarch64.zip" zip stylua "stylua-${version}-linux-aarch64" ;;
  esac
}

install_yamlfmt() {
  local version="${YAMLFMT_VERSION:-v0.21.0}"
  local arch
  local clean_version="${version#v}"

  arch="$(linux_arch)" || {
    warn "unsupported architecture for yamlfmt"
    return 1
  }

  case "$arch" in
    x86_64) install_release_archive_tool yamlfmt "https://github.com/google/yamlfmt/releases/download/${version}/yamlfmt_${clean_version}_Linux_x86_64.tar.gz" tar.gz yamlfmt "yamlfmt-${version}-linux-x86_64" ;;
    arm64) install_release_archive_tool yamlfmt "https://github.com/google/yamlfmt/releases/download/${version}/yamlfmt_${clean_version}_Linux_arm64.tar.gz" tar.gz yamlfmt "yamlfmt-${version}-linux-arm64" ;;
  esac
}

install_lua_language_server() {
  local version="${LUA_LANGUAGE_SERVER_VERSION:-3.17.1}"
  local arch

  arch="$(linux_arch)" || {
    warn "unsupported architecture for lua-language-server"
    return 1
  }

  case "$arch" in
    x86_64) install_release_archive_tool lua-language-server "https://github.com/LuaLS/lua-language-server/releases/download/${version}/lua-language-server-${version}-linux-x64.tar.gz" tar.gz bin/lua-language-server "lua-language-server-${version}-linux-x64" ;;
    arm64) install_release_archive_tool lua-language-server "https://github.com/LuaLS/lua-language-server/releases/download/${version}/lua-language-server-${version}-linux-arm64.tar.gz" tar.gz bin/lua-language-server "lua-language-server-${version}-linux-arm64" ;;
  esac
}

install_ruff() {
  local version="${RUFF_VERSION:-0.15.5}"
  local arch

  arch="$(linux_arch)" || {
    warn "unsupported architecture for ruff"
    return 1
  }

  case "$arch" in
    x86_64) install_release_archive_tool ruff "https://github.com/astral-sh/ruff/releases/download/${version}/ruff-x86_64-unknown-linux-gnu.tar.gz" tar.gz ruff "ruff-${version}-linux-x86_64" ;;
    arm64) install_release_archive_tool ruff "https://github.com/astral-sh/ruff/releases/download/${version}/ruff-aarch64-unknown-linux-gnu.tar.gz" tar.gz ruff "ruff-${version}-linux-arm64" ;;
  esac
}

install_codelldb() {
  local version="${CODELLDB_VERSION:-v1.12.1}"
  local arch

  arch="$(linux_arch)" || {
    warn "unsupported architecture for codelldb"
    return 1
  }

  case "$arch" in
    x86_64) install_release_archive_tool codelldb "https://github.com/vadimcn/codelldb/releases/download/${version}/codelldb-linux-x64.vsix" vsix extension/adapter/codelldb "codelldb-${version}-linux-x64" ;;
    arm64) install_release_archive_tool codelldb "https://github.com/vadimcn/codelldb/releases/download/${version}/codelldb-linux-arm64.vsix" vsix extension/adapter/codelldb "codelldb-${version}-linux-arm64" ;;
  esac
}

setup_20_neovim_toolchain() {
  local install_flag

  install_flag="${INSTALL_NEOVIM_TOOLS:-auto}"
  case "$install_flag" in
    0|false|FALSE|no|NO)
      skip "Skipping Neovim external toolchain setup (INSTALL_NEOVIM_TOOLS=$install_flag)"
      return
      ;;
  esac

  ensure_npm_global bash-language-server bash-language-server || true
  ensure_npm_global basedpyright-langserver basedpyright || true
  ensure_npm_global vscode-json-language-server vscode-langservers-extracted || true
  ensure_npm_global yaml-language-server yaml-language-server || true

  install_codelldb || true
  install_hyprls || true
  install_lua_language_server || true
  install_marksman || true
  install_ruff || true
  install_shfmt || true
  install_stylua || true
  install_yamlfmt || true

  note_manual_tool clangd "use your system or LLVM upstream install for C/C++ LSP" || true
  note_manual_tool clang-format "use your system or LLVM upstream install for C/C++ formatting" || true
  note_manual_tool jq "install manually if you want JSON formatting via jq" || true
  note_manual_tool shellcheck "install manually if you want shell linting" || true

  case "${INSTALL_NIX_TOOLS:-auto}" in
    0|false|FALSE|no|NO)
      skip "Skipping optional Nix tooling (INSTALL_NIX_TOOLS=${INSTALL_NIX_TOOLS:-auto})"
      ;;
    *)
      note_manual_tool nixd "install manually in your Nix environment if you want Nix LSP" || true
      note_manual_tool nixfmt "install manually in your Nix environment if you want Nix formatting" || true
      ;;
  esac
}
