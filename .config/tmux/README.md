# tmux

tmux setup with base config, plugins, and popup helpers.

## Files

- `tmux.conf`: entrypoint.
- `tmux-base.conf`: core settings and keybinds.
- `tmux-status.conf`: status line configuration.
- `tmux-theme.conf`: theme overrides.
- `opencode-tmux.conf`: OpenCode popup session config.
- `popuptmux`: popup toggle script.
- `status-git.sh`: Git status helper for the tmux status line.

## Highlights

- Prefix is `C-a`.
- Mouse support is enabled.
- Popups: `C-t` (`tv sesh`), `M-m` (generic), `M-o` (toggle OpenCode), `M-N` (quick note).
- `detach-on-destroy off` keeps tmux running when closing sessions through `sesh`.

## Plugins (TPM)

- `tmux-plugins/tpm`
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`
