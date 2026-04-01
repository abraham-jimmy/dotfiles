# sesh

Local `sesh` session definitions for tmux workflows.

## Files

- `sesh.toml`: named sessions, startup commands, previews, and wildcard session behavior.
- `preview-dotfiles.sh`: bare-repo status/log preview used by the `dotfiles` session.
- `start-dotfiles-session.sh`: tmux startup helper that opens `nvim-new` in a left split for the `dotfiles` session.
- `tv-preview-sesh.sh`: `tv sesh` preview router that forces the `dotfiles` entry to use the dotfiles git preview.

## Notes

- `sesh` is installed by `.dotfiles_setup/modules/shell.sh` from upstream release archives into `~/.local/bin`.
- tmux uses `tv sesh` on `C-t`, so the `sesh.toml` definitions here also show up in the `television` picker.
- The `dotfiles` session preview shows colorized bare-repo status and recent dotfiles commits so you can inspect the repo before opening the session.
- The `dotfiles` session starts with a tmux split, opens `nvim-new` from `~/.config` in the left pane, and keeps an interactive shell in the right pane.
