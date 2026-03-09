# Shell

Shared shell helpers used by both Bash and Zsh.

## Files

- `aliases.sh`: common aliases and shell functions.
- `dotfiles.sh`: dotfiles repo aliases, helpers, `DOTDIRS`, setup reminder, and alias picker.
- `ndot.sh`: flat `fzf` picker for common dotfiles.

`dotpick` shows dotfiles workflow helpers in an `fzf` picker so you can quickly search the available aliases/functions.

## Good future additions

- `exports.sh`: shared environment variables.
- `path.sh`: PATH tweaks and tool-specific bin directories.
- `functions.sh`: larger shell helpers that do more than a short alias.
- `completion.sh`: shared completion setup where it makes sense.
- `env.sh`: machine-local toggles loaded conditionally.

`~/.config/shell` is a good home for cross-shell config that should stay shell-agnostic.
