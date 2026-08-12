# OpenCode

OpenCode CLI/TUI personal preferences.

## Files

- `opencode.json`: main runtime config and permission allowlists.
- `tui.json`: terminal UI config.
- `commands/df.md`: OpenCode-specific dotfiles helper command.
- `commands/`: shared legacy command links plus OpenCode-specific NOVA commands.
- `agents/`: specialized NOVA product, review, and workflow stewards.
- `plugins/nova-tools.ts`: repository-selectable, agent-scoped Git, status, and structure tools with literal paths and explicit stage/commit approvals.
- `skills/`: existing shared skill links; `opencode.json` also discovers `~/.config/ai/skills` directly.
- `docs/dotfiles/`: dotfiles-specific context and reference docs.

## Highlights

- Theme: `catppuccin` in `tui.json`.
- Message navigation keybinds for page and line scrolling.
- Dotfiles context lives under `docs/dotfiles/` and is loaded by `/df`.
- Shared commands and skills live under `~/.config/ai` and are linked into OpenCode.
- NOVA uses `/nova-*` commands, `.ai-nova/` project artifacts, shared `nova-*` skills, and the authoritative contract at `~/.config/ai/workflows/nova/`.
- NOVA agents present one first-person quiet mission-control identity, a once-per-session startup mark, and restrained checkpoint reports without weakening truthful or severity-sensitive reporting.
- `/nova-workflow-update` exclusively maintains NOVA itself; `/nova-product-spec-update` exclusively governs existing product specs.
- `opencode.json` keeps persistent read/edit/external-directory allowlists for trusted dotfiles paths.
- NOVA staging and commits resolve through dedicated `ask` permissions even when the calling agent can use `nova_git`.
- Vetted read-only `nova_status` and `nova_project_check` tools run without per-use approval in the active worktree. External repositories still use OpenCode's external-directory safeguard, and native `⚙ tool [...]` lines remain client-owned UI.
- `.dotfiles_setup/modules/shell.sh` installs OpenCode with the official installer, defaulting to `OPENCODE_VERSION=latest` unless pinned.
