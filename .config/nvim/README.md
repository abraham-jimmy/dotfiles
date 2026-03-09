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
- Mason manages LSP servers and installs `black` for Python formatting.
- LSP, Treesitter, formatting, and fuzzy finding are enabled.

## AI workflow

- `blink.cmp` owns `<Tab>` / `<S-Tab>` for completion menu and snippet navigation.
- `sidekick.nvim` is used as a bridge to tmux-backed `opencode` sessions rather than Copilot NES.
- `<C-.>` and `<leader>aa` toggle the `opencode` Sidekick target; `<leader>ao` focuses it directly.
- `<leader>af`, `<leader>av`, `<leader>ad`, `<leader>at`, and `<leader>ap` send file, selection, diagnostics, current context, or prompts to the active `opencode` session.
