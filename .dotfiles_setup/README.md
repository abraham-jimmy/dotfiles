# dotfiles setup scripts

Bootstrap and provisioning scripts for new machine setup.

## Files and purpose

- `bootstrap.sh`: one-command remote entrypoint for a fresh machine.
- `setup.sh`: main orchestrator that loads modules and runs setup functions.
- `modules/distro.sh`: detects and normalizes Linux distro family.
- `modules/installer.sh`: package manager helpers used by setup modules.
- `modules/programs.sh`: installs the base set of required programs.
- `modules/dotfiles.sh`: clones/checks out the bare dotfiles repo and applies core dotfiles Git settings.
- `modules/ssh.sh`: SSH-related setup for using SSH remotes/auth.
- `modules/tmux.sh`: tmux-specific setup tasks.

## Workflow

1. `bootstrap.sh` detects distro and installs `curl`/`git` if needed.
2. Repo source is cloned or updated at `~/.dotfiles-src`.
3. `setup.sh` runs program installers and setup modules.
