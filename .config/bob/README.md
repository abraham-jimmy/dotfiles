# Bob

Bob config for the Neovim runtime managed by `.dotfiles_setup`.

## Files

- `config.json`: disables Bob PATH prompts so setup can manage shell paths itself.

## Workflow

- `.dotfiles_setup/modules/neovim.sh` installs or updates Bob on setup runs.
- `NVIM_VERSION` controls the selected Neovim target.
- Default target is `nightly`; `stable` and exact versions like `v0.10.4` are also supported.
