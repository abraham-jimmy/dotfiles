# Bash

Bash setup split across small sourced files.

## Files

- `.bashrc`: main shell startup.
- `.aliases`: compatibility wrapper that sources shared aliases.
- `.bashprompt.sh`: prompt config.
- `.colors`: shared color variables.
- `.git-prompt.sh`: Git prompt helper.

Shared aliases now live in `~/.config/shell/aliases.sh`, and dotfiles workflow helpers live in `~/.config/shell/dotfiles.sh`.

## Highlights

- History is shared and de-duplicated across sessions.
- tmux auto-attach is enabled for interactive SSH shells.
- Loads `zoxide`, `fzf`, and Git/dotfiles aliases.
