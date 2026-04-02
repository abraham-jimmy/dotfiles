# television

Local `television` (`tv`) configuration and custom channels.

## Files

- `config.toml`: global `tv` UI, keybindings, and shell integration settings.
- `cable/sesh.toml`: custom `sesh` channel used by the tmux popup workflow.
- `themes/kanagawa-dragon.toml`: custom `tv` theme matched to the shared `kanagawa-dragon` palette.

## Notes

- `television` is installed by `.dotfiles_setup/modules/shell.sh` from upstream release archives into `~/.local/bin`.
- Bash and Zsh load `tv init` when `tv` is available so shell `Ctrl-t` / `Ctrl-r` integration comes online automatically.
- `tv sesh` uses `~/.config/sesh/tv-preview-sesh.sh` so the `dotfiles` entry always shows the dotfiles status/log preview instead of the live tmux pane preview.
- `config.toml` uses the local `kanagawa-dragon` theme file under `themes/` instead of a built-in `television` theme.
