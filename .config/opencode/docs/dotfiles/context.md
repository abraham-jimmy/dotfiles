# Dotfiles Quick Context

Use this file as the first context when working on my dotfiles.

## Start Here

- Dotfiles are managed as a bare repo at `$HOME/.dotfiles`.
- Use full commands (no alias assumptions).
- Setup source of truth is `.dotfiles_setup/`.

## Canonical Commands

```bash
# Bare dotfiles git wrapper pattern
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" <git-subcommand>

# List tracked files
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" ls-files

# Show tracked changes
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status -s

# Show recent commits
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" log --oneline -n 20
```

## Tracked Modules

Defined by `DOTDIRS` in `.config/shell/dotfiles.sh`:

- `.config/bob`
- `.config/nvim`
- `.config/nvim-new`
- `.config/sesh`
- `.config/shell`
- `.config/television`
- `.config/tmux`
- `.config/git`
- `.config/bash`
- `.config/zsh`
- `.config/themes`
- `.config/alacritty`
- `.config/wezterm`
- `.config/opencode`
- `.dotfiles_setup/`

## Bootstrap

New machine entrypoint:

```bash
curl -fsSL https://raw.githubusercontent.com/abraham-jimmy/dotfiles/main/.dotfiles_setup/bootstrap.sh | bash
```

- `setup.sh --dry-run` prints grouped module/task output with `PLAN` lines for pending actions and ends with a horizontal summary table with `SUMMARY` inside the table.
- If warnings occurred, setup prints them in yellow after the summary and groups them by module/task; if errors or failed tasks occurred, setup also prints a separate issues table and failure details after the summary.
- Successful installer command output is suppressed; setup shows captured command output only for failures.
- Setup tasks now run independently: normal no-op states short-circuit cleanly, and a failed task logs its context and reason before setup continues.
- Setup modules increasingly short-circuit cleanly when state is already correct (dotfiles repo config, Bob install, tmux reloads, repo fast-forwards).
- tmux restarts are now confirmation-based when plugin changes are detected and a server is running, with yes as the default answer.

## Core Dependencies

From `.dotfiles_setup/modules/programs.sh` and related setup modules:

- `git`, `curl`, `openssh`, `zsh`
- `nodejs`, `npm`
- `unzip`, `tmux`
- `fzf`, `zoxide`, `ripgrep`
- `opencode` via official installer (`latest` by default, optional pin)
- `television` and `sesh` via upstream release archives in `.dotfiles_setup/modules/shell.sh`
- `nvim` via Bob (`nightly` by default, optional pin)
- Neovim external tools via `.dotfiles_setup/modules/neovim_tools.sh` (source-first, user-local, and self-healing on rerun when managed links break)
- Some LLVM/system-style tools like `clangd` and `clang-format` may still be intentionally manual prerequisites.

## Working Rules

- Prefer editing files inside tracked modules.
- Do not change unrelated files outside tracked modules unless explicitly requested.
- Before edits, inspect current tracked state with `status -s`.
- For Neovim migration work, treat `.config/nvim` as the stable reference and test the parallel rewrite with `NVIM_APPNAME=nvim-new nvim`.
- For `nvim-new`, treat `.dotfiles_setup/modules/neovim_tools.sh` as the source of truth for external LSP, formatter, linter, and debug-adapter binaries.
- If you add or reorganize a tracked config directory, update `DOTDIRS` in `.config/shell/dotfiles.sh`.
- If you change workflow, ownership, or layout, update the affected README/context docs in the same change unless told not to.

## If More Detail Is Needed

Read `@/home/jimmy/.config/opencode/docs/dotfiles/reference.md`.
