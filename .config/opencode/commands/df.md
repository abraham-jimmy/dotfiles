---
description: Work safely in the bare dotfiles repository
agent: build
---

Read `$HOME/.config/ai/context/dotfiles/index.md` first, then load only the topic files relevant to the task.

Before editing:
- Check tracked state with `/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --short` and preserve unrelated changes.
- Locate candidates through tracked files, `DOTDIRS`, and task-specific paths. Do not recursively scan `$HOME`.
- Do not use `$HOME` itself as a tool search root or working directory, and do not request blanket `/home/jimmy/*` access. The required bare-Git `--work-tree="$HOME"` argument is the only exception; scope other tool paths to specific `DOTDIRS` or task-relevant locations.
- Read the actual source files; context never overrides source.

While working:
- Use full bare-repository Git commands rather than shell aliases.
- Do not create or update README files or other human-facing documentation unless the user explicitly requests it.
- Add or update AI context only for durable, non-obvious ownership or cross-file coupling, and keep it concise and topic-scoped under `$HOME/.config/ai/context/dotfiles/`.
- If new access is required outside the OpenCode allowlist, ask before changing `$HOME/.config/opencode/opencode.json` and grant only the permissions needed for the requested work. When adding a new `DOTDIRS` entry, explicitly ask whether matching `read`, `edit`, and `external_directory` rules should be added there.
- Verify the affected behavior and inspect the scoped bare-repository diff before handoff. Do not stage or commit unless explicitly requested.

Task:
$ARGUMENTS
