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
