# tmux

tmux setup with base config, plugins, and popup helpers.

## Files

- `tmux.conf`: entrypoint.
- `tmux-base.conf`: core settings and keybinds.
- `tmux-plugins.conf`: TPM plugin list.
- `opencode-tmux.conf`: OpenCode popup session config.
- `popuptmux`: popup toggle script.

## Highlights

- Prefix is `C-a`.
- Mouse support is enabled.
- Popups: `M-m` (generic), `M-o` (toggle OpenCode), `M-N` (quick note).

## Plugins (TPM)

- `tmux-plugins/tpm`
- `2kabhishek/tmux2k`
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`

Theme is Catppuccin via `tmux2k`.
