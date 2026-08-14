# Neovim

- `$HOME/.config/nvim` is the stable `lazy.nvim` reference while `$HOME/.config/nvim-new` is the Neovim 0.12 native-`vim.pack` rewrite.
- Keep the stable config working until the user explicitly approves a final switch.
- Bob owns Neovim version selection. Setup owns installation checks and executable links; Bob's automatic PATH changes remain disabled.
- `$HOME/.dotfiles_setup/modules/neovim_tools.sh` owns external LSP, formatter, linter, and debug-adapter binaries for `nvim-new`; do not move that ownership into Mason without an explicit decision.
- Add or replace plugins in small reviewed slices and include keymap implications in each decision. Do not pursue mechanical parity with the stable config.

Use `NVIM_APPNAME=nvim-new nvim` when validating the rewrite. Read Lua source for current plugins, keymaps, language tooling, and UI behavior.
