# Neovim

Neovim config based on `lazy.nvim` with a simple module layout.

## Layout

- `init.lua`: bootstrap and startup.
- `lua/config/`: core behavior (options, keymaps, autocmds, diagnostics).
- `lua/plugins/`: plugin specs.
- `lua/util/`: shared helpers.

## Highlights

- Leader key is `<Space>`.
- Theme is Catppuccin.
- LSP, Treesitter, formatting, and fuzzy finding are enabled.
