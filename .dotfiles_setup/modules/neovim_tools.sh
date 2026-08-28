#!/usr/bin/env bash
set -euo pipefail

NVIM_TOOLS_BIN_DIR="$HOME/.local/bin"
NVIM_TOOLS_OPT_DIR="$HOME/.local/opt/neovim-tools"

managed_tool_path() {
  printf '%s/%s\n' "$NVIM_TOOLS_BIN_DIR" "$1"
}

path_is_healthy_executable() {
  local path="${1:-}"

  [ -n "$path" ] && [ -x "$path" ]
}

command_is_healthy() {
  local cmd="$1"
  local path

  path="$(command -v "$cmd" 2>/dev/null || true)"
  path_is_healthy_executable "$path"
}

managed_tool_is_healthy() {
  path_is_healthy_executable "$(managed_tool_path "$1")"
}

managed_tool_needs_repair() {
  local path

  path="$(managed_tool_path "$1")"

  if [ -L "$path" ] && [ ! -e "$path" ]; then
    return 0
  fi

  if [ -e "$path" ] && [ ! -x "$path" ]; then
    return 0
  fi

  return 1
}

should_skip_managed_tool_install() {
  local cmd="$1"

  if managed_tool_is_healthy "$cmd"; then
    skip "already installed: $cmd"
    return 0
  fi

  if managed_tool_needs_repair "$cmd"; then
    warn "repairing broken managed tool: $cmd"
    return 1
  fi

  if command_is_healthy "$cmd"; then
    skip "already installed: $cmd"
    return 0
  fi

  return 1
}

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
  local tmp target_path bin_path

  if [ "${DEBUG:-0}" -eq 1 ]; then
    plan "would install '$cmd' from upstream release: $url"
    return 0
  fi

  if should_skip_managed_tool_install "$cmd"; then
    return 0
  fi

  ensure_neovim_tool_dirs
  tmp="$(mktemp)"
  bin_path="$(managed_tool_path "$cmd")"
  target_path="$NVIM_TOOLS_BIN_DIR/$cmd"

  if run "curl -fL \"$url\" -o \"$tmp\"" && run "rm -f \"$bin_path\"" && run "install -m 0755 \"$tmp\" \"$target_path\""; then
    if ! path_is_healthy_executable "$target_path"; then
      rm -f "$tmp"
      warn "installed binary '$cmd' is not executable at '$target_path'"
      return 1
    fi

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
  local archive_path extract_dir install_dir extracted_binary_path installed_binary_path bin_path

  if [ "${DEBUG:-0}" -eq 1 ]; then
    plan "would install '$cmd' from upstream archive: $url"
    return 0
  fi

  if should_skip_managed_tool_install "$cmd"; then
    return 0
  fi

  ensure_neovim_tool_dirs
  archive_path="$(mktemp)"
  extract_dir="$(mktemp -d)"
  install_dir="$NVIM_TOOLS_OPT_DIR/$install_name"
  installed_binary_path="$install_dir/$binary_relpath"
  bin_path="$(managed_tool_path "$cmd")"

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
      if ! run "unzip -oq \"$archive_path\" -d \"$extract_dir\""; then
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

  extracted_binary_path="$extract_dir/$binary_relpath"
  if ! path_is_healthy_executable "$extracted_binary_path"; then
    rm -f "$archive_path"
    rm -rf "$extract_dir"
    warn "archive for '$cmd' did not contain executable '$binary_relpath'"
    return 1
  fi

  if run "rm -rf \"$install_dir\"" && run "mkdir -p \"$install_dir\"" && run "cp -R \"$extract_dir\"/. \"$install_dir\"/" && run "rm -f \"$bin_path\"" && run "ln -sfn \"$installed_binary_path\" \"$bin_path\""; then
    if ! path_is_healthy_executable "$installed_binary_path"; then
      rm -f "$archive_path"
      rm -rf "$extract_dir"
      warn "installed archive tool '$cmd' is missing executable '$binary_relpath'"
      return 1
    fi

    if ! path_is_healthy_executable "$bin_path"; then
      rm -f "$archive_path"
      rm -rf "$extract_dir"
      warn "managed tool link for '$cmd' is not executable at '$bin_path'"
      return 1
    fi

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

  if [ "${DEBUG:-0}" -eq 1 ]; then
    plan "would check manual prerequisite '$cmd' ($reason)"
    return 0
  fi

  if command -v "$cmd" >/dev/null 2>&1; then
    skip "already installed: $cmd"
    return 0
  fi

  warn "manual prerequisite '$cmd' is missing ($reason)"
  return 1
}

ensure_npm_global_module() {
  local package="$1"
  local module_path="$HOME/.local/lib/node_modules/$package"

  if [ "${DEBUG:-0}" -eq 1 ]; then
    plan "would ensure global npm module '$package'"
    return 0
  fi

  if [ -d "$module_path" ]; then
    skip "already installed: $package"
    return 0
  fi

  if ! command -v npm >/dev/null 2>&1; then
    warn "npm is unavailable; cannot install global package '$package'"
    return 1
  fi

  if run "npm install -g --prefix \"$HOME/.local\" \"$package\""; then
    done_log "installed npm package: $package"
    return 0
  fi

  warn "unable to install npm package '$package'"
  return 1
}

ensure_c_headers() {
  local package

  if [ -f /usr/include/stdint.h ] && [ -f /usr/include/stdio.h ]; then
    skip "already installed: C development headers"
    return 0
  fi

  case "$DISTRO" in
    arch) package="glibc" ;;
    debian) package="libc6-dev" ;;
    fedora) package="glibc-headers" ;;
    *)
      warn "unable to select C development headers for distro '$DISTRO'"
      return 1
      ;;
  esac

  if [ "${DEBUG:-0}" -eq 1 ]; then
    plan "would ensure C development headers via package '$package'"
    return 0
  fi

  info "package required for Treesitter parsers: $package"
  if try_install_package "$package"; then
    done_log "installed package: $package"
    return 0
  fi

  warn "unable to install C development headers package '$package'"
  return 1
}

ensure_dotnet_sdk() {
  local package version major

  if command -v dotnet >/dev/null 2>&1; then
    while read -r version _; do
      major="${version%%.*}"
      case "$major" in
        '' | *[!0-9]*) continue ;;
      esac

      if [ "$major" -ge 10 ]; then
        skip "already installed: .NET SDK $version"
        return 0
      fi
    done < <(dotnet --list-sdks 2>/dev/null)
  fi

  case "$DISTRO" in
    arch) package="dotnet-sdk" ;;
    debian | fedora) package="dotnet-sdk-10.0" ;;
    *)
      warn "unable to select a .NET SDK for distro '$DISTRO'"
      return 1
      ;;
  esac

  if [ "${DEBUG:-0}" -eq 1 ]; then
    plan "would ensure .NET SDK via package '$package'"
    return 0
  fi

  info "package required for Roslyn: $package"
  if try_install_package "$package"; then
    done_log "installed package: $package"
    return 0
  fi

  warn "unable to install .NET SDK package '$package'"
  return 1
}

install_roslyn_language_server() {
  local version="${ROSLYN_LANGUAGE_SERVER_VERSION:-5.12.0-1.26426.8}"
  local install_dir="$NVIM_TOOLS_OPT_DIR/roslyn-language-server-$version"
  local bin_path

  if [ "${DEBUG:-0}" -eq 1 ]; then
    plan "would install roslyn-language-server dotnet tool version $version"
    return 0
  fi

  if should_skip_managed_tool_install roslyn-language-server; then
    return 0
  fi

  if ! command -v dotnet >/dev/null 2>&1; then
    warn "manual prerequisite 'dotnet' is missing (required for Roslyn and .NET projects)"
    return 1
  fi

  ensure_neovim_tool_dirs
  bin_path="$(managed_tool_path roslyn-language-server)"

  if run "rm -rf \"$install_dir\"" \
    && run "dotnet tool install roslyn-language-server --tool-path \"$install_dir\" --version \"$version\"" \
    && run "rm -f \"$bin_path\"" \
    && run "ln -s \"$install_dir/roslyn-language-server\" \"$bin_path\""; then
    if path_is_healthy_executable "$bin_path"; then
      done_log "installed dotnet tool: roslyn-language-server"
      return 0
    fi
  fi

  warn "unable to install roslyn-language-server"
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

install_glsl_analyzer() {
  local version="${GLSL_ANALYZER_VERSION:-v1.7.1}"
  local arch

  arch="$(linux_arch)" || {
    warn "unsupported architecture for glsl_analyzer"
    return 1
  }

  case "$arch" in
    x86_64) install_release_archive_tool glsl_analyzer "https://github.com/nolanderc/glsl_analyzer/releases/download/${version}/x86_64-linux-musl.zip" zip bin/glsl_analyzer "glsl_analyzer-${version}-linux-x86_64" ;;
    arm64) install_release_archive_tool glsl_analyzer "https://github.com/nolanderc/glsl_analyzer/releases/download/${version}/aarch64-linux-musl.zip" zip bin/glsl_analyzer "glsl_analyzer-${version}-linux-arm64" ;;
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
    x86_64) install_release_archive_tool ruff "https://github.com/astral-sh/ruff/releases/download/${version}/ruff-x86_64-unknown-linux-gnu.tar.gz" tar.gz ruff-x86_64-unknown-linux-gnu/ruff "ruff-${version}-linux-x86_64" ;;
    arm64) install_release_archive_tool ruff "https://github.com/astral-sh/ruff/releases/download/${version}/ruff-aarch64-unknown-linux-gnu.tar.gz" tar.gz ruff-aarch64-unknown-linux-gnu/ruff "ruff-${version}-linux-arm64" ;;
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
  ensure_npm_global tree-sitter tree-sitter-cli || true
  ensure_npm_global vtsls @vtsls/language-server || true
  ensure_npm_global vscode-json-language-server vscode-langservers-extracted || true
  ensure_npm_global vscode-eslint-language-server vscode-langservers-extracted || true
  ensure_npm_global vscode-html-language-server vscode-langservers-extracted || true
  ensure_npm_global vscode-css-language-server vscode-langservers-extracted || true
  ensure_npm_global yaml-language-server yaml-language-server || true
  ensure_npm_global_module ts-lit-plugin || true
  ensure_c_headers || true
  ensure_dotnet_sdk || true

  install_codelldb || true
  install_glsl_analyzer || true
  install_hyprls || true
  install_lua_language_server || true
  install_marksman || true
  install_roslyn_language_server || true
  install_ruff || true
  install_shfmt || true
  install_stylua || true
  install_yamlfmt || true

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
