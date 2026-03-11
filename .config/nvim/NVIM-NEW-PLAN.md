# Neovim Native Pack Migration Plan

This file is a restart-friendly handoff for rebuilding the Neovim setup as a clean, parallel config using Neovim 0.12 native package management instead of `lazy.nvim`.

## Goal

Build a new config in `~/.config/nvim-new` first, keep `~/.config/nvim` working during the migration, and only switch over once the new config is stable enough for daily use.

## Why This Approach

- The current config is tightly coupled to `lazy.nvim` bootstrapping and lazy-specific spec fields.
- A clean-room rebuild is lower risk than trying to mechanically translate the existing plugin spec files.
- A parallel config allows side-by-side testing without breaking the current editor setup.
- This is a good opportunity to separate editor behavior from machine provisioning.

## High-Level Direction

- Use `vim.pack` in Neovim 0.12 for plugin installation and lockfile management.
- Use plain Lua modules for setup instead of returning lazy plugin specs.
- Recreate lazy-loading only where it is actually useful, using native commands, autocommands, and key wrappers.
- Prefer system/bootstrap-managed external tools over Mason.

## Recommended New Layout

```text
~/.config/nvim-new/
  init.lua
  lua/core/options.lua
  lua/core/keymaps.lua
  lua/core/autocmds.lua
  lua/core/diagnostics.lua
  lua/plugins/init.lua
  lua/plugins/ui.lua
  lua/plugins/editor.lua
  lua/plugins/search.lua
  lua/plugins/git.lua
  lua/plugins/lsp.lua
  lua/plugins/treesitter.lua
  lua/plugins/completion.lua
  lua/plugins/dap.lua
  lua/util/*.lua
  README.md
  nvim-pack-lock.json
```

Exact module names can change, but the core idea is:

- `core/*` for built-in editor behavior
- `plugins/*` for explicit plugin setup code
- no lazy-style spec files

## Current Config: What Should Be Preserved

### Core Behavior

Carry forward behavior from:

- `~/.config/nvim/lua/config/options.lua`
- `~/.config/nvim/lua/config/keymaps.lua`
- `~/.config/nvim/lua/config/autocmds.lua`
- `~/.config/nvim/lua/config/diagnostics.lua`

Notable defaults currently in use:

- leader key is `<Space>`
- relative numbers enabled
- `unnamedplus` clipboard
- `rg --vimgrep` for grep
- persistent undo
- 2-space indentation
- wrapped lines enabled
- yank highlight
- auto `checktime` on focus/buffer enter
- diagnostics configured with number highlights and limited inline virtual text

### Keymaps Worth Preserving

From `~/.config/nvim/lua/config/keymaps.lua` and plugin configs:

- `j`/`k` use display-line movement when no count is given
- `<C-d>` / `<C-u>` recenter the screen
- tmux navigation on `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`
- window resize on `<C-Up>`, `<C-Down>`, `<C-Left>`, `<C-Right>`
- toggle maps:
  - `<leader>ts` spell
  - `<leader>tw` wrap
  - `<leader>tl` line numbers
  - `<leader>td` diagnostics
  - `<leader>tD` inline diagnostics text
  - `<leader>ti` inlay hints
  - `<leader>tf` autoformat
- git signs maps such as `[h`, `]h`, `<leader>gs`, `<leader>gr`, `<leader>gp`, `<leader>gb`, `<leader>gd`
- search/file maps from `fzf-lua`, especially `<leader>ff`, `<leader>fg`, `<leader>sg`, `<leader>sf`, `<leader>sk`, `<leader>b`
- OpenCode/Sidekick maps under `<leader>a*` and `<C-.>`
- notification maps under `<leader>n*`
- format buffer on `<leader>fo`
- lazilygit on `<leader>lg`
- zen mode on `<leader>Z`

These should be reviewed for actual usage before porting everything.

### Plugins/Features Worth Evaluating for Porting

Current feature buckets:

- UI/theme: `catppuccin`, `mini.statusline`, `alpha-nvim`, `notify`, `which-key`, `zen-mode`
- editing: `mini.*`, `indent-blankline`, `flash`, `ts-comments`, `todo-comments`, `render-markdown`
- search/nav: `fzf-lua`, `telescope` only for notify integration right now
- git: `gitsigns`, `codediff`, `snacks` for `lazygit`
- LSP/tools: `nvim-lspconfig`, `mason`, `mason-lspconfig`, `mason-tool-installer`, `lazydev`, `clangd_extensions`, `conform`
- syntax/completion: `nvim-treesitter`, `nvim-ts-autotag`, `blink.cmp`, `nvim-cmp`
- debugging: `nvim-dap`, `nvim-dap-view`, `nvim-dap-virtual-text`, `hydra` (if still needed after the minimal C/C++ DAP slice)
- workflow: `sidekick.nvim`, `tmux.nvim`, `nvim-colorizer`, `web-devicons`

## Important Findings About the Current Setup

### Lazy-Specific Coupling

The current config is not just using `lazy.nvim` for install/update. It also depends on lazy-specific config semantics:

- bootstrap logic lives in `~/.config/nvim/init.lua`
- plugin files use lazy-only fields such as `event`, `ft`, `cmd`, `keys`, `dependencies`, `lazy = false`, `opts_extend`, and `config = true`
- `~/.config/nvim/lua/plugins/treesitter.lua` directly imports `lazy.core.*`, which must be rewritten manually

### Existing Worktree Changes

Before this note was written, bare-repo status showed existing user changes in:

- `~/.config/nvim/README.md`
- `~/.config/nvim/lua/plugins/blink.lua`
- `~/.config/nvim/lua/plugins/lsp.lua`
- `~/.config/nvim/lua/plugins/sidekick.lua`
- deletion of `~/.config/nvim/lua/plugins/nvim-cmp.lua`

Those changes should be treated as user-owned context during future work unless explicitly superseded.

## Mason: Why Removing It Is Probably a Good Idea

### Reasons To Drop Mason

- It keeps Neovim focused on editor configuration instead of machine provisioning.
- It reduces hidden state inside `~/.local/share/nvim` and makes fresh-machine setup more predictable.
- It aligns better with this dotfiles repo, where `.dotfiles_setup/` is supposed to be the setup source of truth.
- It avoids having plugin installation and external tool installation managed in two different places.
- It should make the new config simpler, especially with `vim.pack` already replacing `lazy.nvim`.

### Reasons You Might Still Keep Mason

- It is convenient for trying a new LSP server or formatter quickly.
- It smooths over distro package naming differences.
- Some tools are easier to manage in-editor than via system packages.

### Recommendation

Prefer no Mason in `nvim-new`.

Instead:

- manage editor plugins with `vim.pack`
- manage external binaries in `.dotfiles_setup/`
- let Neovim configure only tools that are already installed on the machine

Expected external tools to eventually manage outside Neovim include:

- `clangd`
- `bash-language-server`
- Python LSP choice such as `pyright` or `basedpyright`
- `black`
- `stylua`
- `shfmt`
- `jq`
- `yamlfmt`
- `nixfmt`
- `fzf`
- `lazygit`

## Recommended Migration Order

### Phase 1 - Create the Parallel Config

- create `~/.config/nvim-new`
- add a minimal `init.lua`
- add `vim.pack` bootstrap and plugin declaration module
- confirm Neovim can start with the new config without touching the current one

### Phase 2 - Port Core Editor Behavior

- port options
- port keymaps
- port autocmds
- port diagnostics config
- port any small utility helpers needed by those modules

Goal: start using `nvim-new` for basic editing even before plugin parity.

### Phase 3 - Port Simple, Low-Risk Plugins

- colorscheme
- statusline
- gitsigns
- mini basics
- colorizer
- web-devicons

Goal: make the new setup pleasant enough for regular editing.

### Phase 4 - Port Search and Workflow Plugins

- `fzf-lua`
- `notify`
- `todo-comments`
- `zen-mode`
- `sidekick.nvim`
- `snacks.nvim` for `lazygit`

Goal: restore day-to-day navigation and workflow commands.

### Phase 5 - Port Syntax and Per-Language Tooling

- `nvim-treesitter`
- `nvim-ts-autotag`
- `nvim-lspconfig`
- `nvim-lint`
- `lazydev.nvim`
- `clangd_extensions.nvim`
- `conform.nvim`

At this stage, explicitly avoid Mason and wire language tools directly.

For each language, review and decide:

- primary LSP server
- linting tool / diagnostics source
- formatter
- any language-specific extras worth keeping (for example `lazydev.nvim`, `clangd_extensions.nvim`, autotag support, test adapters, or compiler helpers)

Prefer organizing `nvim-new` around per-language toolchain modules so LSP, linting, formatting, and language-specific helpers stay together.

### Phase 6 - Resolve Completion Strategy

Current config has both `blink.cmp` and `nvim-cmp` history/config. Decide on one.

Recommended default:

- prefer `blink.cmp` if you want a modern, smaller completion setup and it covers your use cases
- keep `nvim-cmp` only if there is a specific feature gap that matters to you

Goal: avoid carrying both completion systems into the new setup.

### Phase 7 - Port DAP Only If Still Needed

- `nvim-dap`
- `nvim-dap-view`
- `nvim-dap-virtual-text`
- `hydra`

Keep debugging separate from the first usable milestone unless it is part of daily work.

Current direction:

- start with a minimal C/C++ DAP setup using `codelldb`
- keep `.vscode/launch.json` support
- defer hydra until the base flow proves worth keeping

### Phase 8 - Bootstrap / Docs / Final Switch

If `nvim-new` becomes the real setup:

- decide whether to rename `nvim-new` -> `nvim`
- update `.dotfiles_setup/` if external tool ownership changed
- update Neovim README docs
- if a tracked config directory is added or renamed, update `DOTDIRS` in `~/.config/shell/dotfiles.sh`
- keep `~/.config/opencode/docs/dotfiles/context.md` and `~/.config/opencode/docs/dotfiles/reference.md` in sync if workflow/layout guidance changes

## Risks / Things To Watch

- `vim.pack` in Neovim 0.12 is still marked experimental upstream, even though it is intended for real use.
- `lazy-lock.json` does not carry over; the new config should use `nvim-pack-lock.json`.
- `nvim-treesitter` install/update flow needs a native replacement for `build = ":TSUpdate"`.
- manual lazy-loading should be introduced carefully; overdoing it can make the config harder to maintain than just eagerly loading a few extra plugins.
- `notify` currently uses a short dependency name (`"telescope.nvim"`) that should be made explicit in a fresh config.
- `render-markdown.nvim` currently references `echasnovski/mini.nvim`, while the rest of the config mostly uses standalone `mini.*` plugins; that should be rationalized.
- per-language tool ownership should be explicit so LSP, linting, diagnostics, and formatting do not drift apart.
- LSP naming/setup should be cleaned up during the rewrite, especially server naming consistency.

## Suggested Success Criteria

The new config is ready for broader use when:

- it starts cleanly with no `lazy.nvim` dependency
- core editing behavior feels familiar
- search, git, notifications, and core LSP work reliably
- external tools are installed reproducibly outside Neovim
- plugin updates are handled through `vim.pack` and tracked lockfile state

## Good Restart Context For Future Sessions

When restarting this work, the model should assume:

- the preferred strategy is a clean-room parallel config in `~/.config/nvim-new`
- the desired package manager is native `vim.pack`, not `lazy.nvim`
- Mason is probably being removed unless a concrete reason appears to keep it
- `.dotfiles_setup/` is the source of truth for machine bootstrap and external tool installation
- `.dotfiles_setup/modules/neovim_tools.sh` should own the `nvim-new` external toolchain once language choices stabilize, preferring source-first user-local installs over distro package managers for Neovim-specific tools
- the current `~/.config/nvim` is a reference implementation and should not be broken during migration
- user already expressed interest in preserving current keybinds, settings, and useful plugin behavior, not necessarily exact implementation details
- completion stack should be simplified rather than duplicated if possible

## Next Recommended Step

On the next session, start by scaffolding `~/.config/nvim-new` with:

1. `init.lua`
2. `lua/core/{options,keymaps,autocmds,diagnostics}.lua`
3. `lua/plugins/init.lua` with a minimal `vim.pack.add()` list
4. a small README describing how to launch/test the parallel config

After that, port a minimal daily-driver feature set before chasing full parity.
