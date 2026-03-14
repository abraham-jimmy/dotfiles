# dotfiles setup scripts

Bootstrap and provisioning scripts for new machine setup.

## Files and purpose

- `bootstrap.sh`: one-command remote entrypoint for a fresh machine.
- `setup.sh`: main orchestrator that loads modules and runs setup functions.
- `modules/distro.sh`: detects and normalizes Linux distro family.
- `modules/installer.sh`: package manager helpers used by setup modules.
- `modules/programs.sh`: installs the base distro-managed programs.
- `modules/neovim.sh`: installs Bob and selects the configured Neovim version.
- `modules/neovim_tools.sh`: installs Neovim-facing external tools for LSP, formatting, linting, and diagnostics.
- `modules/dotfiles.sh`: clones/checks out the bare dotfiles repo and applies core dotfiles Git settings.
- `modules/ssh.sh`: SSH-related setup for using SSH remotes/auth.
- `modules/tmux.sh`: tmux-specific setup tasks.

## Workflow

1. `bootstrap.sh` detects distro and installs `curl`/`git` if needed.
2. Repo source is cloned or updated at `~/.dotfiles-src`.
3. `setup.sh` runs program installers and setup modules.

## Output

- Setup output is grouped by module and task so reruns are easier to scan.
- `--dry-run` prints `PLAN` lines for commands and file writes instead of success-style messages.
- Colored `INFO`, `WARN`, `ERROR`, `PLAN`, `SKIP`, and `DONE` labels are shown automatically on a TTY.
- A final summary prints a horizontal table with `SUMMARY` inside the table plus module, task, plan, run, skip, and warning counts, using one calm color for labels and another for numeric values.
- When any errors or failed tasks occur, setup prints a separate issues table after the main summary, then shows warning and failure details underneath.
- Warnings are printed in yellow after the summary and grouped as a tree by module and task.
- Successful install commands now stay quiet; setup only replays captured command output when a command fails.
- Each task now runs in isolation: if one task fails, setup logs the failing task, module, exit code, and best-known reason, then continues to later tasks.
- Set `NO_COLOR=1` to force plain output.

## Install behavior

- Base distro packages come from `modules/programs.sh`.
- OpenCode is installed with the official `https://opencode.ai/install` script.
- Neovim is managed with Bob instead of the distro package list; Bob itself is only installed if missing.
- Bob install is verified before Neovim commands continue, so a successful installer that leaves no usable `bob` now fails clearly inside the Neovim task.
- Neovim external tools are managed in `modules/neovim_tools.sh`, preferring user-local `npm` installs and upstream release binaries in `~/.local/bin` / `~/.local/opt/neovim-tools`.
- Rerunning setup now self-heals broken managed Neovim tool links or non-executable targets and validates expected archive layouts before linking binaries into `~/.local/bin`.
- Some tools still remain manual prerequisites when there is no clean source-first installer in the setup flow yet (for example `clangd`, `clang-format`, `jq`, `shellcheck`, `nixd`, `nixfmt`).
- `clangd` / `clang-format` are intentionally left manual for now because they are system LLVM tools; suggested installs are `sudo pacman -S clang jq shellcheck` on Arch-family systems, distro `apt install clangd clang-format jq shellcheck` on Debian/Ubuntu, or `apt.llvm.org` if you specifically want newer LLVM packages there.
- Dotfiles repo checkout/config, zsh framework pulls, and tmux server restarts now skip cleanly when nothing needs to change, without blocking later setup tasks.
- When tmux plugins changed and a tmux server is running, setup asks before calling `tmux kill-server`, defaulting to yes on empty input (override with `RESTART_TMUX_ON_PLUGIN_CHANGE=yes|no`).

## Version knobs

- `OPENCODE_VERSION=latest` is the default; set an exact release to pin it.
- `NVIM_VERSION=nightly` is the default; `stable` and exact releases like `v0.10.4` are also supported.
- Set `INSTALL_OPENCODE=false` or `INSTALL_NEOVIM=false` to skip either managed install.
- Set `INSTALL_NEOVIM_TOOLS=false` to skip the external Neovim toolchain, or `INSTALL_NIX_TOOLS=false` to skip `nixd` / `nixfmt`.
- Tool versions like `CODELLDB_VERSION`, `HYPRLS_VERSION`, `LUA_LANGUAGE_SERVER_VERSION`, `MARKSMAN_VERSION`, `RUFF_VERSION`, `SHFMT_VERSION`, `STYLUA_VERSION`, and `YAMLFMT_VERSION` can be overridden if you want to pin upstream binaries.
