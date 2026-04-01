# Shell

Shared shell helpers used by both Bash and Zsh.

## Files

- `aliases.sh`: common aliases and shell functions.
- `dotfiles.sh`: dotfiles repo aliases, helpers, `DOTDIRS`, setup reminder, and alias picker.
- `path.sh`: shared PATH entries for local user-level tool installs such as `sesh`, `tv`, and `opencode`.

`DOTDIRS` is the source of truth for tracked config directories and now includes both `~/.config/sesh` and `~/.config/television` alongside `~/.config/nvim` and `~/.config/nvim-new`.

`aliases.sh` includes `nnew` to launch the parallel `nvim-new` config with `NVIM_APPNAME=nvim-new`.

`dotpick` shows dotfiles workflow helpers in an `fzf` picker so you can quickly search the available aliases/functions.

Bash and Zsh both load `tv init` when `television` is installed so shell `Ctrl-t` and `Ctrl-r` use `tv` instead of the default `fzf` bindings.

## Good future additions

- `exports.sh`: shared environment variables.
- `functions.sh`: larger shell helpers that do more than a short alias.
- `completion.sh`: shared completion setup where it makes sense.
- `env.sh`: machine-local toggles loaded conditionally.

`~/.config/shell` is a good home for cross-shell config that should stay shell-agnostic.
