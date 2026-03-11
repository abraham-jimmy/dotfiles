#! /usr/bin/env bash

ndot() {
  local choice file _label _display
  local dim reset

  dim=$'\033[2m'
  reset=$'\033[0m'

  ndot_entry() {
    printf '%s\t%s\t%s%s%s\n' "$1" "$2" "$dim" "$2" "$reset"
  }

  choice=$(
    {
      ndot_entry "shell aliases" "~/.config/shell/aliases.sh"
      ndot_entry "shell dotfiles" "~/.config/shell/dotfiles.sh"
      ndot_entry "shell path" "~/.config/shell/path.sh"
      ndot_entry "shell picker" "~/.config/shell/ndot.sh"
      ndot_entry "bob config" "~/.config/bob/config.json"
      ndot_entry "bashrc" "~/.config/bash/.bashrc"
      ndot_entry "bash prompt" "~/.config/bash/.bashprompt.sh"
      ndot_entry "bash colors" "~/.config/bash/.colors"
      ndot_entry "bash git prompt" "~/.config/bash/.git-prompt.sh"
      ndot_entry "zshrc" "~/.config/zsh/.zshrc"
      ndot_entry "zsh p10k" "~/.config/zsh/.p10k.zsh"
      ndot_entry "git aliases" "~/.config/git/git_aliases"
      ndot_entry "git config" "~/.config/git/config"
      ndot_entry "git ignore" "~/.config/git/gitignore"
      ndot_entry "tmux config" "~/.config/tmux/tmux.conf"
      ndot_entry "tmux base" "~/.config/tmux/tmux-base.conf"
      ndot_entry "tmux plugins" "~/.config/tmux/tmux-plugins.conf"
      ndot_entry "tmux opencode" "~/.config/tmux/opencode-tmux.conf"
      ndot_entry "tmux popup" "~/.config/tmux/popuptmux"
      ndot_entry "nvim init" "~/.config/nvim/init.lua"
      ndot_entry "nvim keymaps" "~/.config/nvim/lua/config/keymaps.lua"
      ndot_entry "nvim options" "~/.config/nvim/lua/config/options.lua"
      ndot_entry "nvim autocmds" "~/.config/nvim/lua/config/autocmds.lua"
      ndot_entry "nvim diagnostics" "~/.config/nvim/lua/config/diagnostics.lua"
      ndot_entry "nvim config init" "~/.config/nvim/lua/config/init.lua"
      ndot_entry "nvim util" "~/.config/nvim/lua/util/init.lua"
      ndot_entry "nvim icons" "~/.config/nvim/lua/util/icons.lua"
      ndot_entry "nvim lsp" "~/.config/nvim/lua/plugins/lsp.lua"
      ndot_entry "nvim fzf" "~/.config/nvim/lua/plugins/fzf-lua.lua"
      ndot_entry "nvim treesitter" "~/.config/nvim/lua/plugins/treesitter.lua"
      ndot_entry "nvim conform" "~/.config/nvim/lua/plugins/conform.lua"
      ndot_entry "nvim colorscheme" "~/.config/nvim/lua/plugins/colorscheme.lua"
      ndot_entry "nvim gitsigns" "~/.config/nvim/lua/plugins/gitsigns.lua"
      ndot_entry "nvim mini" "~/.config/nvim/lua/plugins/mini.lua"
      ndot_entry "nvim markdown" "~/.config/nvim/lua/plugins/markdown.lua"
      ndot_entry "nvim dap" "~/.config/nvim/lua/plugins/dap.lua"
      ndot_entry "nvim cmp" "~/.config/nvim/lua/plugins/nvim-cmp.lua"
      ndot_entry "nvim notify" "~/.config/nvim/lua/plugins/notify.lua"
      ndot_entry "nvim misc" "~/.config/nvim/lua/plugins/misc.lua"
      ndot_entry "nvim dashboard" "~/.config/nvim/lua/plugins/statusline_dashboard.lua"
      ndot_entry "nvim sidekick" "~/.config/nvim/lua/plugins/sidekick.lua"
      ndot_entry "wezterm" "~/.config/wezterm/wezterm.lua"
      ndot_entry "opencode config" "~/.config/opencode/opencode.json"
      ndot_entry "opencode tui" "~/.config/opencode/tui.json"
      ndot_entry "opencode dotfiles cmd" "~/.config/opencode/commands/dotfiles.md"
      ndot_entry "opencode df cmd" "~/.config/opencode/commands/df.md"
      ndot_entry "opencode context" "~/.config/opencode/docs/dotfiles/context.md"
      ndot_entry "opencode reference" "~/.config/opencode/docs/dotfiles/reference.md"
      ndot_entry "setup script" "~/.dotfiles_setup/setup.sh"
      ndot_entry "bootstrap" "~/.dotfiles_setup/bootstrap.sh"
      ndot_entry "setup readme" "~/.dotfiles_setup/README.md"
      ndot_entry "setup shell" "~/.dotfiles_setup/modules/shell.sh"
      ndot_entry "setup neovim" "~/.dotfiles_setup/modules/neovim.sh"
      ndot_entry "setup tmux" "~/.dotfiles_setup/modules/tmux.sh"
      ndot_entry "setup dotfiles" "~/.dotfiles_setup/modules/dotfiles.sh"
      ndot_entry "setup programs" "~/.dotfiles_setup/modules/programs.sh"
      ndot_entry "setup installer" "~/.dotfiles_setup/modules/installer.sh"
      ndot_entry "setup distro" "~/.dotfiles_setup/modules/distro.sh"
      ndot_entry "setup ssh" "~/.dotfiles_setup/modules/ssh.sh"
      ndot_entry "dotfiles readme" "~/README.md"
    } |
      fzf \
        --prompt='Dotfiles > ' \
        --height=50% \
        --layout=reverse \
        --ansi \
        --delimiter=$'\t' \
        --with-nth=1 \
        --preview='file=$(printf "%s" {2} | sed "s#^~#$HOME#"); printf "%s\n\n" "$file"; if command -v bat >/dev/null 2>&1; then bat --style=plain --color=always "$file"; else rg --no-heading --color never "^" "$file"; fi' \
        --preview-window='right:60%:wrap'
  ) || return

  IFS=$'\t' read -r _label file _display <<< "$choice"
  nvim "${file/#\~/$HOME}"
}
