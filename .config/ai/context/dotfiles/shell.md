# Shell

- Cross-shell aliases, paths, and dotfiles helpers belong under `$HOME/.config/shell`.
- Bash- or Zsh-specific startup, prompt, history, and integration behavior belongs under the corresponding client directory.
- Implement behavior shared by Bash and Zsh once in the shared shell module rather than duplicating it in both startup files.
- `DOTDIRS` and `DOTFILES_ROOT_FILES` in `dotfiles.sh` own broad module and root-stub staging for `dotau`; keep them synchronized with managed path changes.
- Shared startup loads `platform.sh`, which auto-detects `wsl` or `linux`, honors `DOTFILES_PLATFORM`, and conditionally sources the matching small file under `platform/`.

Read shell source for the current aliases, functions, bindings, and startup behavior.
