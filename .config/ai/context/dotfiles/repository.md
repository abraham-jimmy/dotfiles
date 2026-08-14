# Repository

## Git Model

Use this command shape for every repository operation:

```bash
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" <subcommand>
```

- Check tracked changes before editing with `status --short`.
- The repository config hides untracked files from status. When a target may be new, inspect that path with `ls-files --others --exclude-standard -- <path>`.
- Use `ls-files` rather than directory contents to determine what the repository currently tracks.
- Inspect the final scoped diff and run `diff --check` before handoff.

## Tracked Scope

`DOTDIRS` in `$HOME/.config/shell/dotfiles.sh` controls which module directories `dotau` stages broadly. It is not a complete tracked-file manifest. Update `DOTDIRS` when adding, renaming, or reorganizing a managed module directory.

Machine provisioning belongs under `$HOME/.dotfiles_setup`; individual config modules should not duplicate installer ownership.
