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

- `.config/nvim`
- `.config/shell`
- `.config/tmux`
- `.config/git`
- `.config/bash`
- `.config/zsh`
- `.config/wezterm`
- `.config/opencode`

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

## 4) Dependencies

Base dependency list comes from `.dotfiles_setup/modules/programs.sh`:

- `git`, `curl`, `openssh`
- `zsh`
- `nodejs`, `npm`
- `nvim`, `tmux`
- `fzf`, `zoxide`, `ripgrep`

Distro/package handling is in `.dotfiles_setup/modules/installer.sh`.

Supported distro families (normalized in `.dotfiles_setup/modules/distro.sh`):

- Arch family (`arch`, `cachyos`, `endeavouros`, `manjaro`)
- Debian/Ubuntu family
- Fedora family

## 5) High-Level Module Map

- `.config/nvim` - Neovim setup (`lazy.nvim`, plugins, config modules)
- `.config/shell` - shared aliases and cross-shell helper files
- `.config/tmux` - tmux base config + TPM plugins + popup workflows
- `.config/git` - Git config and shell helpers for dotfiles workflow
- `.config/bash` - Bash prompt, aliases, shell behavior
- `.config/zsh` - Zsh + Oh My Zsh + prompt/plugins
- `.config/wezterm` - terminal preferences
- `.config/opencode` - OpenCode preferences and helper context docs
- `.dotfiles_setup` - machine bootstrap/provisioning scripts

## 6) Operational Guidance for LLM Agents

- Start with `.config/opencode/docs/dotfiles/context.md`.
- Use full bare-repo command form, not aliases, unless explicitly requested.
- Confirm file is tracked (or intentionally untracked) before editing.
- Keep edits scoped to requested modules.
- Prefer module README files for local conventions.
- If setup behavior is relevant, inspect `.dotfiles_setup` files first.
- If you add or reorganize a tracked config directory, update `DOTDIRS` in `.config/shell/dotfiles.sh`.
- If you change module layout, ownership, or workflow behavior, update the relevant README/context docs in the same change unless the user says not to.

## 7) Suggested Task Startup Checklist

1. Read this file or quick context file.
2. Check tracked changes with `status -s`.
3. Locate target module (`.config/<module>`).
4. Make scoped edits.
5. Re-check diff/status before commit or handoff.
