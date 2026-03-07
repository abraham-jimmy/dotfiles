# Git

Git config plus helper aliases for normal repos and dotfiles.

## Files

- `config`: core Git defaults and aliases.
- `gitignore`: global excludes file used via `core.excludesfile`.
- `git_aliases`: shell aliases/functions for Git and dotfiles.

## Dotfiles command

Main wrapper:

```bash
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
```

Useful helpers:

- `dots`: short status for dotfiles.
- `dotau`: add tracked updates and configured module dirs.
- `dotsync`: add, suggest commit message, commit, and push.

`dot_smart_commit_message` auto-suggests commit messages from staged changes.
