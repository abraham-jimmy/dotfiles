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

- `.config/nvim`
- `.config/shell`
- `.config/tmux`
- `.config/git`
- `.config/bash`
- `.config/zsh`
- `.config/wezterm`
- `.config/opencode`

## Bootstrap

New machine entrypoint:

```bash
curl -fsSL https://raw.githubusercontent.com/abraham-jimmy/dotfiles/main/.dotfiles_setup/bootstrap.sh | bash
```

## Core Dependencies

From `.dotfiles_setup/modules/programs.sh`:

- `git`, `curl`, `openssh`, `zsh`
- `nodejs`, `npm`
- `nvim`, `tmux`
- `fzf`, `zoxide`, `ripgrep`

## Working Rules

- Prefer editing files inside tracked modules.
- Do not change unrelated files outside tracked modules unless explicitly requested.
- Before edits, inspect current tracked state with `status -s`.
- If you add or reorganize a tracked config directory, update `DOTDIRS` in `.config/shell/dotfiles.sh`.
- If you change workflow, ownership, or layout, update the affected README/context docs in the same change unless told not to.

## If More Detail Is Needed

Read `@/home/jimmy/.config/opencode/docs/dotfiles/reference.md`.
