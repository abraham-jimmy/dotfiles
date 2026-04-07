# Neovim New

Parallel Neovim 0.12 config built around native `vim.pack`.

`~/.config/nvim` remains the current `lazy.nvim`-based reference while this config is rebuilt in a cleaner capability-based layout.

## Status

- Phase 1 and Phase 2 are in place.
- Core editor behavior loads without plugin assumptions.
- Plugin choices will be added incrementally after explicit review.

## Layout

- `init.lua`: entrypoint.
- `lua/core/`: editor behavior and startup wiring.
- `lua/util/`: small shared helpers.
- `lua/pack/`: native package registration.
- `lua/plugins/`: capability-based plugin setup modules.
- `lua/lang/`: per-language toolchain modules for LSP, formatting, linting, and diagnostics choices.
- `nvim-pack-lock.json`: native package lockfile placeholder.

External binaries for the new config should be owned by `~/.dotfiles_setup/modules/neovim_tools.sh`, not Mason. That setup is now source-first and user-local instead of distro-package-driven for Neovim-specific tools.

## Run

```bash
NVIM_APPNAME=nvim-new nvim
nnew
```

## Current Scope

- leader and editor environment setup
- options, keymaps, autocmds, diagnostics
- toggle and project root helpers
- first workflow plugin added: `fzf-lua` for files, buffers, grep, and keymap search, with picker previews visible by default
- `nvim-hlslens` is enabled for `/` search highlighting and match counters while moving through search results
- `gitsigns.nvim` is enabled for live gutter hunks and quick stage/reset/blame actions while editing
- git review plugin added: `codediff.nvim` for richer repo/file/history diffs
- `mini.files` is enabled as the file explorer for Miller-column browsing and filesystem edits
- `mini.ai` is enabled with Treesitter-backed function, class, and conditional textobjects
- `mini.indentscope` is enabled for indent-scope guides and motions, with a toggle on `<leader>tI`
- `mini.move` is enabled for moving lines and selections with Alt-based motions
- `mini.pairs` is enabled for lightweight autopairs, with a toggle on `<leader>tp`
- `mini.surround` is enabled for surround add/delete/replace editing with the `gs*` key family
- `mini.trailspace` is enabled for passive trailing-whitespace highlighting in files not covered by formatters
- `nvim-tree` is enabled as the persistent sidebar tree, alongside `mini.files`
- language tooling foundations are added with `nvim-lspconfig`, `conform.nvim`, and `nvim-lint`, but per-language choices are still under review
- currently enabled LSP servers: `bashls`, `basedpyright`, `clangd`, `hyprls`, `jsonls`, `lua_ls`, `marksman`, `nixd`, and `yamlls`
- `nvim-new` keeps Neovim 0.12 native `:lsp` commands as the real backend, with compatibility aliases for `:LspInfo`, `:LspStart`, `:LspRestart`, `:LspStop`, `:LspDisable`, and `:LspLog`
- Python LSP root detection now prefers `.git`, then `.venv`, then Python project files, so repo-local `.venv/bin/python` wins over nested `requirements.txt` roots when available
- `basedpyright` now notifies once per workspace attach with the detected root and interpreter path, and warns when the expected repo-local `.venv/bin/python` is missing
- formatting is handled by `conform.nvim` with `<leader>fo` and `:FormatToggle`
- `todo-comments.nvim` is enabled in passive highlight-only mode for comment TODO/FIX/HACK/NOTE tags
- `nvim-treesitter` is enabled with parser auto-install for better syntax highlighting, indentation, and incremental selection
- `blink.cmp` is enabled for LSP, path, and buffer completion with a minimal preset
- `flash.nvim` is enabled for fast in-buffer jumps, enhanced `f`/`t` motions, and Treesitter-based movement
- `zen-mode.nvim` is enabled for distraction-free editing with a wide centered window and `<leader>Z`
- `tmux.nvim` restores tmux-aware pane navigation on `<C-h>`, `<C-j>`, `<C-k>`, and `<C-l>`
- `sidekick.nvim` is enabled for the tmux-backed OpenCode workflow, with NES intentionally disabled for now
- `kanagawa.nvim` is the active colorscheme, using the `kanagawa-dragon` variant
- `nvim-notify` is enabled for animated notifications and history, without Telescope integration
- `nvim-web-devicons` is enabled so pickers and status components can show filetype icons
- `dashboard-nvim` is the startup screen, with recent files, recent projects, quick actions backed by `fzf-lua`, random Neovim ASCII art via `ascii.nvim`, and the statusline hidden there
- `mini.statusline` is the active statusline, showing mode, macro recording, diff, diagnostics, LSP, file, search count, and cursor location
- `mini.clue` replaces `which-key` with trigger-based key discovery for leader, `g`, `z`, `[`, `]`, marks, registers, `<C-w>`, and insert completion, plus a pinned bottom-right clue panel in `mini.files` and `nvim-tree`
- minimal C/C++ debugging is enabled with `nvim-dap`, `nvim-dap-view`, `nvim-dap-virtual-text`, and `codelldb`
- no broader plugin parity yet

## Current Plugin Keymaps

- `fzf-lua`: `<leader>ff`, `<leader>fg`, `<leader>fp`, `<leader>sg`, `<leader>sf`, `<leader>sk`, `<leader>b`, `<leader>sr`, `<leader>sd`, `<leader>sw`, `<leader>sG`, `<leader>/`
- `nvim-hlslens`: `/`, `?`, `n`, `N`, `*`, `#`, `g*`, `g#`; `<leader>sh` clears search highlighting
- `todo-comments.nvim`: no keybinds; passive comment highlighting only
- `gitsigns.nvim`: `[h`, `]h`, `<leader>gs`, `<leader>gr`, `<leader>gS`, `<leader>gu`, `<leader>gR`, `<leader>gp`, `<leader>gb`, `<leader>gD`, `<leader>g~`, `gh`
- `codediff.nvim`: `<leader>gd` for repo changes explorer, `<leader>gf` for current file vs `HEAD`, and `<leader>gh` for diff history; when the current buffer is a tracked dotfiles file, all three switch to an isolated read-only review flow, and `<leader>?` toggles a persistent in-view hint panel inside codediff tabs
- `mini.files`: `<leader>e` current path toggle, `<leader>E` git root toggle; inside explorer use `l`, `h`, `=`, `g?`
- `mini.ai`: textobjects like `af` / `if`, `ac` / `ic`, `ai` / `ii` for functions, classes, and conditionals
- `mini.indentscope`: `ii`, `ai`, `[i`, `]i`; `<leader>tI` toggles the scope guides
- `mini.move`: `<M-h>`, `<M-j>`, `<M-k>`, `<M-l>` move lines/selections left, down, up, right
- `mini.pairs`: no insert-mode keymaps beyond pairing behavior; `<leader>tp` toggles it on and off
- `mini.surround`: `gsa`, `gsd`, `gsr`, `gsf`, `gsF`, `gsh`, `gsn`
- `mini.trailspace`: no keybinds; passive trailing-whitespace highlighting only
- `nvim-tree`: `<leader>o` toggle sidebar, `<leader>O` reveal current file; inside tree use `a`, `d`, `r`, `c`, `x`, `p`, `H`, `?`
- `nvim-lspconfig`: `gd`, `gr`, `gI`, `K`, `<leader>rn`, `<leader>ca`, `<leader>wa`, `<leader>wr`, `<leader>wl`, `<leader>li`; command aliases `:LspInfo`, `:LspStart`, `:LspRestart`, `:LspStop`, `:LspDisable`, `:LspLog`
- `nvim-lint`: `<leader>ll` runs the current buffer linters when a language has them configured
- `conform.nvim`: `<leader>fo` to format, `:FormatToggle` to toggle autoformat-on-save
- `nvim-treesitter`: `<C-Space>` to expand selection, `<BS>` to shrink selection
- `blink.cmp`: `<Tab>` / `<S-Tab>` to move through items, `<C-Space>` to open completion, `<C-e>` to close, `<C-y>` to confirm
- `flash.nvim`: `s` jump, `S` Treesitter jump, `r` remote operator jump, `R` Treesitter search; enhanced `f`, `F`, `t`, `T`, `;`, `,`
- `zen-mode.nvim`: `<leader>Z` toggles Zen Mode
- `tmux.nvim`: `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` to move between Neovim splits and tmux panes
- `sidekick.nvim`: `<C-.>`, `<leader>aa`, `<leader>ao`, `<leader>as`, `<leader>ad`, `<leader>at`, `<leader>af`, `<leader>av`, `<leader>ap`
- `nvim-notify`: `<leader>nh` for history, `<leader>nq` to dismiss, `<leader>nc` to clear history
- `nvim-web-devicons`: no keybinds; shared icons for pickers and statusline
- `dashboard-nvim`: startup keys `f`, `g`, `c`, `q` for files, grep, config, and quit
- `mini.statusline`: no keybinds; always-visible editor status, including `REC @<register>` while recording macros
- `mini.clue`: trigger hints for `<leader>`, `g`, `z`, `[`, `]`, `<C-w>`, `'`, `` ` ``, `"`, `<C-r>`, and `<C-x>`; sticky bottom-right help panel for fuller `mini.files` and `nvim-tree` keyboard references
- `nvim-dap`: `<leader>db`, `<leader>dB`, `<leader>dc`, `<leader>di`, `<leader>dU`, `<leader>dO`, `<leader>dt`, `<leader>du`, `<leader>dv`, `<leader>dL`

## Language Review Notes

- `C/C++`: use `clangd` as the primary LSP, diagnostics source, and inlay-hint provider, with `--clang-tidy` enabled.
- `C/C++`: use `clang-format` for formatting and prefer project-local `.clang-format` files.
- `C/C++`: prefer `compile_commands.json` first, then `compile_flags.txt`, then `.clangd` as project metadata inputs.
- `C/C++`: keep standalone linting empty for now; add `cppcheck` or another extra tool only if `clangd` diagnostics prove insufficient.
- `C/C++`: keep `clangd_extensions.nvim` out unless plain `clangd` shows a real gap.
- `C/C++`: `clangd` / `clang-format` are still manual prerequisites; suggested installs are `sudo pacman -S clang jq shellcheck` on Arch-family systems, distro `apt install clangd clang-format jq shellcheck` on Debian/Ubuntu, or `apt.llvm.org` if you want newer LLVM packages there.
- `Python`: use `basedpyright` for LSP and type checking.
- `Python`: prefer repo-root detection from `.git` first, then `.venv`, before falling back to nested Python project files like `requirements.txt`.
- `Python`: use Ruff for linting, diagnostics, import organization, and formatting.
- `Python`: keep the initial type-checking level at `standard`; raise it later only if you want stricter project-wide feedback.
- `Python`: prefer project-local `pyproject.toml` / Ruff config and avoid separate `black` / `isort` unless a concrete compatibility need appears.
- `Python`: when `<root>/.venv/bin/python` exists, `basedpyright` is pointed at it automatically and announces that interpreter path on attach; if it is missing, `nvim-new` warns with the expected path.
- `Lua`: use `lua_ls` for LSP and `stylua` for formatting.
- `Lua`: use `lazydev.nvim` for Neovim config/plugin Lua work so `require()` libraries and Neovim-specific workspace data stay accurate without loading everything eagerly.
- `Lua`: skip a separate linter by default; add `selene` later only if you want stricter style/static rules beyond `lua_ls` diagnostics.
- `Lua`: keep Lua diagnostics primarily in `lua_ls` and prefer project-local `.luarc.json` only when you need project-specific overrides.
- `Shell`: use `bashls` for shell LSP on `bash` and `sh` files.
- `Shell`: use `shellcheck` for linting and diagnostics, and `shfmt` for formatting.
- `Shell`: treat `.shellcheckrc` and `.git` as useful project roots for shell tooling.
- `Zsh`: use the dedicated `zsh` linter from `nvim-lint` for syntax checking; do not pretend `bashls`, `shellcheck`, or `shfmt` are fully correct for Zsh-specific code.
- `Zsh`: keep LSP and formatting empty by default until there is a clearly better toolchain story.
- `JSON/YAML`: use `jsonls` and `yamlls` for validation/structure diagnostics; prefer `jq` for JSON formatting and `yamlfmt` for YAML formatting.
- `JSON/YAML`: keep YAML key ordering warnings off by default to avoid noisy config editing.
- `Hyprland`: use `hyprls` for Hyprland config completion, hover, diagnostics, and LSP formatting; prefer a workspace `.hyprlsignore` when some files should be excluded.
- `Nix`: use `nixd` for LSP and `nixfmt` for formatting.
- `Markdown`: use `marksman` for LSP-style structure, links, and document diagnostics; skip automatic formatting by default.
- `tmux`: keep dedicated LSP/formatter empty for now; rely on Neovim syntax support, whitespace hygiene, and manual edits until a clearly worthwhile tool appears.

## Review Sequence

- Add and test plugins in small batches.
- Suggest useful or common keybinds for plugins during each review.
- Do a per-language review pass for LSP, linting, diagnostics, formatting, and any language-specific extras before calling the migration stable.

## Using CodeDiff

- Start with `<leader>gd` to browse repo changes, `<leader>gf` to compare the current file against `HEAD`, or `<leader>gh` to inspect history.
- `:DotfilesDiff`, `:DotfilesDiffFile`, and `:DotfilesDiffHistory` open the same review flows explicitly when you want dotfiles review without relying on the current repo context.
- `<leader>gd` and `<leader>gh` open panel-first views. You land in the codediff explorer/history panel first, not directly in a file diff. Press `<CR>` on an entry to open the actual diff for that file.
- In tracked dotfiles files, `<leader>gd`, `<leader>gf`, and `<leader>gh` switch to an isolated read-only review path instead of talking to the bare repo directly through codediff.
- Dotfiles repo and history review use a temporary snapshot of the bare dotfiles repo, while dotfiles file review compares `HEAD` against the current buffer contents.
- Once a file diff is open, codediff does not replace all normal-mode keys. Only its own diff keys are added on top, so ordinary motions still work by design.
- In the file diff view, use `q` to close, `t` to switch side-by-side vs inline, and `]c` / `[c` to move between hunks.
- In explorer/history views, use `<CR>` to open the selected file or commit entry, `R` to refresh, and `i` to switch list vs tree view.
- In normal repos, use `-` to stage or unstage a file, `<leader>hs` / `<leader>hu` / `<leader>hr` for hunk actions, and `do` / `dp` to apply diff changes across panes.
- In dotfiles review sessions, git actions and refresh are intentionally disabled because the view is read-only and isolated from the live bare repo.
- Use `g?` for codediff's built-in floating help, or `<leader>?` for the persistent clue panel while learning the view.

## Debugging Notes

- `C/C++`: use `codelldb` as the debug adapter for the initial DAP setup.
- `C/C++`: load `.vscode/launch.json` with `<leader>dL` when a project already defines launch configurations.
- `C/C++`: keep the current DAP scope minimal for now: core DAP, view pane, and virtual text only; no hydra yet.

## Language Tooling Review

- `C/C++`: start with `clangd` for LSP, diagnostics, inlay hints, and `clang-tidy`-backed feedback; use `clang-format` for formatting; do not add a second lint plugin unless a real gap appears.
- `C/C++`: expect project roots to come from `.clangd`, `compile_commands.json`, `compile_flags.txt`, or `.git`; revisit `clangd_extensions.nvim` only if a concrete feature is missing from plain `clangd`.

## Migration Rules

- Keep `~/.config/nvim` working during the rewrite.
- Review plugins one by one before adding them.
- When reviewing plugins, include suggested useful/common keybinds before deciding whether to keep them.
- Prefer external tool ownership in `~/.dotfiles_setup/`, not Mason.
