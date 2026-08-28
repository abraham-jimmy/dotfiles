# Shell

- Cross-shell aliases, paths, and dotfiles helpers belong under `$HOME/.config/shell`.
- Bash- or Zsh-specific startup, prompt, history, and integration behavior belongs under the corresponding client directory.
- Implement behavior shared by Bash and Zsh once in the shared shell module rather than duplicating it in both startup files.
- `DOTDIRS` in `dotfiles.sh` owns broad module staging for `dotau`; private root startup files are intentionally outside its staging scope.
- Bootstrap uses `.dotfiles_setup/internal/ensure_shell_startup.sh` to put guarded source blocks at the top of private `.zshrc`, `.bashrc`, and `.bash_profile` files. It leaves `.zshenv` absent by default so `ZDOTDIR` cannot bypass the root Zsh shim.
- Shared startup loads `platform.sh`, which auto-detects `wsl` or `linux`, honors `DOTFILES_PLATFORM`, and conditionally sources the matching small file under `platform/`.

Read shell source for the current aliases, functions, bindings, and startup behavior.
