# Shell

- Cross-shell aliases, paths, and dotfiles helpers belong under `$HOME/.config/shell`.
- Bash- or Zsh-specific startup, prompt, history, and integration behavior belongs under the corresponding client directory.
- Implement behavior shared by Bash and Zsh once in the shared shell module rather than duplicating it in both startup files.
- `DOTDIRS` in `dotfiles.sh` owns broad module staging for `dotau`; keep it synchronized with managed module-directory changes.

Read shell source for the current aliases, functions, bindings, and startup behavior.
