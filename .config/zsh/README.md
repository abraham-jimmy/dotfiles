# Zsh

Zsh setup based on Oh My Zsh with local prompt/plugins.

## Files

- `.zshrc`: primary shell config.
- `.p10k.zsh`: Powerlevel10k prompt configuration.

## Highlights

- Uses Oh My Zsh (`plugins=(git fzf extract)`) with `ZSH_THEME` disabled.
- Sources shared color helpers from `.config/bash`, shared shell and dotfiles helpers from `.config/shell`, and Git helpers from `.config/git`.
- History is append-only with duplicate reduction.
- Uses vi keybindings (`bindkey -v`).
- Auto-attaches tmux on interactive SSH sessions.
- Loads `zoxide`, `fzf`, Powerlevel10k, and local zsh plugins.
