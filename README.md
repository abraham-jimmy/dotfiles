# dotfiles

Personal config with a one-command bootstrap for new machines.

## New machine setup

Run this on a fresh system:

```bash
curl -fsSL https://raw.githubusercontent.com/abraham-jimmy/dotfiles/main/.dotfiles_setup/bootstrap.sh | bash
```

What this does:

- Detects distro (`arch`, `debian/ubuntu`, or `fedora` families).
- Installs bootstrap requirements (`curl`, `git`) if missing.
- Clones or updates this repo into `~/.dotfiles-src`.
- Runs `.dotfiles_setup/setup.sh` to install programs and apply modules.

## Tracked modules

These map to `DOTDIRS` in `.config/shell/dotfiles.sh`.

- `.config/bob`
- [Neovim](.config/nvim/README.md)
- `.config/nvim-new`
- [sesh](.config/sesh/README.md)
- [Shell](.config/shell/README.md)
- [television](.config/television/README.md)
- [tmux](.config/tmux/README.md)
- [Git](.config/git/README.md)
- [Bash](.config/bash/README.md)
- [Zsh](.config/zsh/README.md)
- `.config/themes`
- `.config/alacritty`
- [WezTerm](.config/wezterm/README.md)
- [OpenCode](.config/opencode/README.md)
- [Bootstrap/setup scripts](.dotfiles_setup/README.md)

## Daily workflow

Most helper commands are in `.config/git/git_aliases`.

```bash
dotfiles status -s
dotau
dotsync
```

Common direct commands:

```bash
dotfiles add <path>
dotfiles commit -m "message"
dotfiles push origin main
```
