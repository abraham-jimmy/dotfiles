# Neovim

- `$HOME/.config/nvim` is the active Neovim 0.12 native-`vim.pack` configuration.
- Bob owns Neovim version selection. Setup owns installation checks and executable links; Bob's automatic PATH changes remain disabled.
- `$HOME/.dotfiles_setup/modules/neovim_tools.sh` owns external LSP, formatter, linter, and debug-adapter binaries for Neovim; do not move that ownership into Mason without an explicit decision.
- Add or replace plugins in small reviewed slices and include keymap implications in each decision. Do not pursue mechanical parity with the stable config.

Use `nvim` without `NVIM_APPNAME` when validating the configuration. Read Lua source for current plugins, keymaps, language tooling, and UI behavior.
