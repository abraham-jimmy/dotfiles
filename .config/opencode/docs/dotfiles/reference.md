# Dotfiles Reference

Extended context for working in this dotfiles setup.

## 1) Repository Model

- Dotfiles are managed with a bare Git repo.
- Git dir: `$HOME/.dotfiles`
- Work tree: `$HOME`
- The usual alias is `dotfiles`, but automation should use full command form.

Canonical pattern:

```bash
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" <git-subcommand>
```

Useful read-only commands:

```bash
# What is tracked
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" ls-files

# Tracked working changes
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status -s

# Diffs
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" diff
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" diff --staged

# History
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" log --oneline -n 20
```

## 2) Tracked Scope

Primary tracked config scope is defined by `DOTDIRS` in `.config/shell/dotfiles.sh`:

- `.ai`
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

Other tracked files can exist outside these directories (for example top-level `README.md` and `.dotfiles_setup/*`).

## 3) Bootstrap and Build Flow

Main new-machine command:

```bash
curl -fsSL https://raw.githubusercontent.com/abraham-jimmy/dotfiles/main/.dotfiles_setup/bootstrap.sh | bash
```

Execution flow:

1. `.dotfiles_setup/bootstrap.sh`
2. `.dotfiles_setup/setup.sh`
3. `.dotfiles_setup/modules/*.sh` via discovered `setup_*` functions

What each stage does:

- `bootstrap.sh`
  - Detects distro via `/etc/os-release`
  - Ensures `curl` and `git`
  - Clones/updates source repo at `~/.dotfiles-src`
  - Executes `setup.sh`

- `setup.sh`
  - Loads distro + installer + program modules
  - Installs required programs
  - Sources remaining modules
  - Runs all `setup_*` functions in sorted order
  - Isolates each task so later tasks still run after an earlier task failure
  - Prints grouped module/task output with colored status labels on interactive terminals
  - Ends with a horizontal summary table with `SUMMARY` inside the table for modules, tasks, planned actions, runs, skips, and warnings, with separate colors for labels and numeric values
  - Prints a separate issues table for errors and failed tasks only when they occurred, then shows warnings grouped by module/task and failure details after the tables when needed

Dry-run behavior:

- `setup.sh --dry-run` shows `PLAN` lines instead of executing commands or writing files
- Output is grouped by module file and setup function so it is easier to scan
- Successful command output is suppressed during real runs; captured command output is replayed only when a command fails
- A final horizontal summary table shows how many modules, tasks, plans, runs, skips, and warnings occurred
- If any errors or failed tasks occurred, setup prints a separate issues table afterward
- Set `NO_COLOR=1` to force plain output

Rerun behavior:

- Dotfiles checkout/config in `.dotfiles_setup/modules/dotfiles.sh` short-circuits when the bare repo and expected config are already in place
- Git-based framework repos in `.dotfiles_setup/modules/shell.sh` only fast-forward after a fetch when the upstream changed; otherwise they log a skip
- Bob in `.dotfiles_setup/modules/neovim.sh` is installed if missing, verified before Neovim commands continue, then reused on later runs
- tmux restart in `.dotfiles_setup/modules/tmux.sh` only happens when TPM or plugin state changed, and setup asks before calling `tmux kill-server` unless `RESTART_TMUX_ON_PLUGIN_CHANGE=yes|no` is set; empty input defaults to yes
- A failed task now reports the task name, module, exit code, and best-known failing command or reason, then setup continues to the next task

## 4) Dependencies

Base dependency list comes from `.dotfiles_setup/modules/programs.sh`:

- `git`, `curl`, `openssh`
- `zsh`
- `nodejs`, `npm`
- `unzip`, `tmux`
- `fzf`, `zoxide`, `ripgrep`

Distro/package handling is in `.dotfiles_setup/modules/installer.sh`.

Managed tool installs outside the distro package list:

- OpenCode via the official installer in `.dotfiles_setup/modules/shell.sh` (`OPENCODE_VERSION=latest` by default)
- Television via upstream release archives in `.dotfiles_setup/modules/shell.sh` (`TELEVISION_VERSION=0.15.4` by default)
- Sesh via upstream release archives in `.dotfiles_setup/modules/shell.sh` (`SESH_VERSION=v2.24.2` by default)
- Neovim via Bob in `.dotfiles_setup/modules/neovim.sh` (`NVIM_VERSION=nightly` by default)
- Neovim external tools in `.dotfiles_setup/modules/neovim_tools.sh` (source-first, user-local `npm`, upstream binary ownership, and self-healing reruns for broken managed links)
- Some tools are intentionally still manual when they are better treated as system LLVM/toolchain dependencies, notably `clangd` and `clang-format`

Supported distro families (normalized in `.dotfiles_setup/modules/distro.sh`):

- Arch family (`arch`, `cachyos`, `endeavouros`, `manjaro`)
- Debian/Ubuntu family
- Fedora family

## 5) High-Level Module Map

- `.config/nvim` - current Neovim setup (`lazy.nvim`, plugins, config modules)
- `.config/nvim-new` - parallel Neovim 0.12 rewrite using native `vim.pack`
- `.config/bob` - Bob config for Neovim version management
- `.config/sesh` - sesh session definitions for tmux workflows
- `.config/shell` - shared aliases and cross-shell helper files
- `.config/television` - television config and custom channels such as the tmux sesh picker
- `.config/tmux` - tmux base config + TPM plugins + popup workflows
- `.config/git` - Git config and shell helpers for dotfiles workflow
- `.config/bash` - Bash prompt, aliases, shell behavior
- `.config/zsh` - Zsh + Oh My Zsh + prompt/plugins
- `.config/themes` - theme assets and shared appearance files
- `.config/alacritty` - Alacritty terminal preferences
- `.config/wezterm` - terminal preferences
- `.config/opencode` - OpenCode preferences and helper context docs
- `.ai` - AI implementation specs and task handoff documents
- `.dotfiles_setup` - machine bootstrap/provisioning scripts

## 6) Operational Guidance for LLM Agents

- Start with `.config/opencode/docs/dotfiles/context.md`.
- Use full bare-repo command form, not aliases, unless explicitly requested.
- Confirm file is tracked (or intentionally untracked) before editing.
- Keep edits scoped to requested modules.
- Prefer module README files for local conventions.
- For Neovim migration work, treat `.config/nvim` as the stable reference and `.config/nvim-new` as the active rewrite target; test with `NVIM_APPNAME=nvim-new nvim`.
- For `nvim-new`, treat `.dotfiles_setup/modules/neovim_tools.sh` as the ownership point for external LSP, formatter, linter, and debug-adapter binaries.
- If setup behavior is relevant, inspect `.dotfiles_setup` files first.
- If you add or reorganize a tracked config directory, update `DOTDIRS` in `.config/shell/dotfiles.sh`.
- If you change module layout, ownership, or workflow behavior, update the relevant README/context docs in the same change unless the user says not to.

## 7) Suggested Task Startup Checklist

1. Read this file or quick context file.
2. Check tracked changes with `status -s`.
3. Locate target module (`.config/<module>`).
4. Make scoped edits.
5. Re-check diff/status before commit or handoff.
