# AI

Shared AI resources that are intended to be reused across model-specific tools.

## Structure

- `skills/`: shared skill folders copied or authored once, then linked into tool-specific skill directories.
- `commands/`: reusable command specs or prompt files that are not tied to a single client.
- `context/`: shared context/reference documents for AI workflows.

## Notes

- `~/.config/ai` is the tracked source of truth for shared AI assets.
- Reusable commands currently shared across clients live in `commands/`; client-specific commands should stay with that client.
- `syncAiResources` in `~/.config/shell/aliases.sh` links shared `commands/*` and `skills/*` into client-specific directories such as OpenCode and Claude.
- Use `.ai/<feature-slug>/change-inbox.md` as the manual holding file for deferred ideas that can later be folded into task files with the `ideas-to-tasks` command.
- After a task verifies successfully, the `task` command marks and renames it complete, then suggests a scoped commit message without creating the commit automatically.
- After the final task, run `validate-spec <feature-folder>` in a new isolated session. It verifies the spec's `Done` conditions, tags checks needing fresh human confirmation as `[MANUAL_VERIFY]`, and renames the folder to `<feature-slug>-DONE/` when every task and condition passes. After completion, it can update an ancestor main spec using that spec's existing progress convention, but only after showing the exact update and receiving explicit user confirmation. Its final report always includes commit-message guidance and never creates the commit automatically.
