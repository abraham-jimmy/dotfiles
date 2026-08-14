# Dotfiles AI Context

Use this index for dotfiles work. Load only the topic files needed for the current task.

## Core Rules

- The repository uses `$HOME/.dotfiles` as a bare Git directory and `$HOME` as its worktree.
- Use full bare-repository Git commands; do not assume aliases or a normal `.git` directory.
- Do not recursively scan `$HOME`. Start from tracked files, `DOTDIRS`, and paths relevant to the request.
- Treat source files as authoritative. Context records ownership and non-obvious coupling, not inventories.
- Preserve unrelated worktree changes. Do not stage or commit unless explicitly requested.

## Topics

- `repository.md`: Git model, tracked scope, and verification.
- `setup.md`: bootstrap and provisioning ownership.
- `shell.md`: shared shell configuration and `DOTDIRS`.
- `neovim.md`: stable/rewrite boundaries and tooling ownership.
- `desktop.md`: Hyprland, Waybar, and autostart coupling.
- `themes.md`: authored profiles and generated consumer files.
- `ai-tools.md`: shared and client-specific AI resource ownership.

## Documentation Policy

Do not create or update human-facing documentation, including README files, unless the user explicitly requests it. Agent-facing context is appropriate only for durable, non-obvious constraints, ownership, or cross-file coupling that would otherwise require repeated discovery. Keep it concise and topic-scoped here, and point to source files instead of copying implementation details or current inventories.
