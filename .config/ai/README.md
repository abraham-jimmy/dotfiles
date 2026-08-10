# AI

Shared AI resources that are intended to be reused across model-specific tools.

## Structure

- `skills/`: shared skill folders copied or authored once, then linked into tool-specific skill directories.
- `commands/`: reusable command specs or prompt files that are not tied to a single client.
- `context/`: shared context/reference documents for AI workflows.
- `workflows/`: authoritative workflow contracts and deterministic helpers shared by client-specific entrypoints.

## Notes

- `~/.config/ai` is the tracked source of truth for shared AI assets.
- Reusable commands currently shared across clients live in `commands/`; client-specific commands should stay with that client.
- `syncAiResources` in `~/.config/shell/aliases.sh` links shared `commands/*` and `skills/*` into client-specific directories such as OpenCode and Claude.
- NOVA's authoritative contract lives in `workflows/nova/`; portable policy lives in `skills/nova-*`, while OpenCode-specific `/nova-*` commands and agents live under `~/.config/opencode`.
- NOVA projects use an isolated `.ai-nova/` root with stable paths, one global `INBOX.md`, product governance, one feature-delivery loop, and a mandatory product handoff after feature validation.
- `nova-status` is a deterministic shell helper that reports NOVA documentation state without a model call.
- NOVA's deterministic shell helpers require Bash 4 or newer.
- The legacy `.ai/` command workflow remains available and is never mixed with `.ai-nova/` artifacts.
- Use `.ai/<feature-slug>/change-inbox.md` as the manual holding file for deferred ideas that can later be folded into task files with the `ideas-to-tasks` command.
- Before doing task work, the `task` command requires a completely clean Git tree and hard-stops on any staged, unstaged, or untracked path. After successful verification, it marks and renames the task complete, proposes a scoped commit message, and asks for explicit approval before staging all task changes and creating the commit.
- After the final task, run `validate-spec <feature-folder>` in a new isolated session. It verifies the spec's `Done` conditions, tags checks needing fresh human confirmation as `[MANUAL_VERIFY]`, and renames the folder to `<feature-slug>-DONE/` when every task and condition passes. After completion, it can update an ancestor main spec using that spec's existing progress convention, but only after showing the exact update and receiving explicit user confirmation. Its final report always includes commit-message guidance and never creates the commit automatically.
