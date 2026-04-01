# television

Local `television` (`tv`) configuration and custom channels.

## Files

- `config.toml`: global `tv` UI, keybindings, and shell integration settings.
- `cable/sesh.toml`: custom `sesh` channel used by the tmux popup workflow.

## Notes

- `television` is installed by `.dotfiles_setup/modules/shell.sh` from upstream release archives into `~/.local/bin`.
- Bash and Zsh load `tv init` when `tv` is available so shell `Ctrl-t` / `Ctrl-r` integration comes online automatically.
- `tv sesh` uses `~/.config/sesh/tv-preview-sesh.sh` so the `dotfiles` entry always shows the dotfiles status/log preview instead of the live tmux pane preview.
