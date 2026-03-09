# OpenCode

OpenCode CLI/TUI personal preferences.

## Files

- `opencode.json`: main runtime config and permission allowlists.
- `tui.json`: terminal UI config.
- `commands/df.md`: dotfiles helper command.
- `docs/dotfiles/`: dotfiles-specific context and reference docs.

## Highlights

- Theme: `catppuccin` in `tui.json`.
- Message navigation keybinds for page and line scrolling.
- Dotfiles context lives under `docs/dotfiles/` and is loaded by `/df`.
- `opencode.json` keeps persistent read/edit/external-directory allowlists for trusted dotfiles paths.
