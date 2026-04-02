# Fix High-Severity Dotfiles Issues

## Why

Several tracked dotfiles currently break or weaken the fresh-machine bootstrap path, tmux startup, and editor/tooling behavior. These are the highest-value fixes because they affect machine setup reliability, daily shell/tmux safety, and AI/editor workflows across the whole repo.

## What

Fix the most severe tracked dotfiles issues first: bootstrap first-install flow, missing tmux include, tmux restart false positives, OpenCode allowlist drift, Neovim LSP config drift, and fragile theme switching. The work is done when fresh-machine-critical paths are internally consistent, guarded where needed, and verified with dry-run, syntax, and manual checks.

## Context

**Relevant files:**
- `.dotfiles_setup/modules/dotfiles.sh` - bootstraps bare-repo checkout and repo-local git config
- `.dotfiles_setup/modules/tmux.sh` - installs/syncs TPM and decides whether tmux should restart
- `.dotfiles_setup/modules/shell.sh` - shared helper `git_clone_or_update` affects tmux plugin change detection
- `.config/tmux/tmux.conf` - main tmux entrypoint currently sources a missing file
- `.config/opencode/opencode.json` - trusted-path allowlist for tracked dotfiles access
- `.config/nvim/init.lua` - startup LSP enablement and editor env setup
- `.config/nvim/lua/plugins/lsp.lua` - authoritative LSP server configuration
- `.config/themes/theme-switch` - generated theme application and OpenCode theme update flow

**Patterns to follow:**
- Setup modules should short-circuit cleanly when state is already correct, as in `.dotfiles_setup/modules/neovim.sh`
- Setup changes should be dry-run safe and log through existing `plan`, `skip`, `info`, and `done_log` helpers
- Config fallbacks should prefer guarded behavior over hard failure, as already used in `.config/zsh/.zshrc`

**Key decisions already made:**
- `~/.dotfiles_setup/` is the setup source of truth
- Full bare-repo git commands are the canonical dotfiles workflow
- No README updates in this feature
- More severe issues should be fixed first

## Constraints

**Must:**
- Preserve existing setup module structure
- Keep changes scoped to tracked dotfiles only
- Use existing setup logging and dry-run behavior
- Keep fixes minimal and behavior-focused

**Must not:**
- Add new dependencies
- Modify unrelated config just for cleanup
- Refactor broad architecture beyond what each fix requires

**Out of scope:**
- Lower-severity portability cleanup like all hardcoded `$HOME` path replacements
- Shell alias safety redesign
- Stale README/doc cleanup
- Removing `.dotfiles_setup/a.out`

## Tasks

### T1: Bootstrap first-install path

**Do:** Fix `.dotfiles_setup/modules/dotfiles.sh` so initial bare clone, first checkout, and repo-local config all run on a fresh machine. Use a pre-clone state flag or equivalent so first-install logic is reachable exactly once.

**Files:** `.dotfiles_setup/modules/dotfiles.sh`

**Verify:** `bash -n .dotfiles_setup/modules/dotfiles.sh`
Manual: inspect logic to confirm first install runs checkout/config after clone and reruns short-circuit when already configured.

### T2: Tmux startup and restart correctness

**Do:** Fix tmux high-risk behavior in two parts:
- Guard or remove the missing `source-file ~/.config/tmux/tmux-plugins.conf` include in `.config/tmux/tmux.conf`
- Make tmux restart decisions depend on actual plugin changes rather than any successful `git_clone_or_update` call

**Files:** `.config/tmux/tmux.conf`, `.dotfiles_setup/modules/tmux.sh`, `.dotfiles_setup/modules/shell.sh`

**Verify:** `bash -n .dotfiles_setup/modules/tmux.sh && bash -n .dotfiles_setup/modules/shell.sh`
Manual: confirm tmux config no longer references a missing file unguarded, and setup only prompts or restarts when plugin state actually changes.

### T3: OpenCode allowlist matches tracked repo scope

**Do:** Update `.config/opencode/opencode.json` so tracked dotfiles paths needed by the repo are allowed consistently in `permission.read`, `permission.edit`, and `permission.external_directory`. Include at least `~/.config/nvim-new/**`, `~/.config/themes/**`, `~/.config/bob/**`, and `~/README.md`. Keep the change minimal even if duplication remains.

**Files:** `.config/opencode/opencode.json`

**Verify:** Manual: confirm all three permission sections contain the same tracked-path additions and no tracked module needed for dotfiles work is omitted.

### T4: Neovim LSP single source of truth

**Do:** Fix server-name drift between `.config/nvim/init.lua` and `.config/nvim/lua/plugins/lsp.lua`. Use canonical server names, define them in one place, and avoid duplicate or conflicting LSP enablement for Bash and Lua.

**Files:** `.config/nvim/init.lua`, `.config/nvim/lua/plugins/lsp.lua`

**Verify:** `nvim --headless "+qa"`
Manual: confirm configured server names are internally consistent, especially Lua and Bash.

### T5: Theme switch graceful OpenCode update

**Do:** Make `.config/themes/theme-switch` resilient when `~/.config/opencode/tui.json` is missing or invalid. Theme application should still update generated theme files and current theme state; OpenCode theme update should be guarded and non-fatal.

**Files:** `.config/themes/theme-switch`

**Verify:** `bash -n .config/themes/theme-switch`
Manual: review `apply_theme` path to confirm missing or invalid `tui.json` warns or skips without aborting the rest of the theme apply flow.

## Done

- [ ] `bash -n .dotfiles_setup/modules/dotfiles.sh`
- [ ] `bash -n .dotfiles_setup/modules/tmux.sh`
- [ ] `bash -n .dotfiles_setup/modules/shell.sh`
- [ ] `bash -n .config/themes/theme-switch`
- [ ] `nvim --headless "+qa"`
- [ ] Manual: fresh-install bootstrap logic is reachable after bare clone
- [ ] Manual: tmux config no longer hard-fails on a missing include
- [ ] Manual: tmux restart only happens for real plugin changes
- [ ] Manual: OpenCode allowlist covers the tracked dotfiles paths needed for repo work
- [ ] Manual: Neovim Bash and Lua LSP config is consistent with no duplicate or conflicting enablement
- [ ] No regressions in setup dry-run behavior
