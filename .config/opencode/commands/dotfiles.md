---
description: Load dotfiles context and start task
agent: build
---

Read @/home/jimmy/.config/opencode/dotfiles-context.md first.
If needed, read @/home/jimmy/.config/opencode/dotfiles-reference.md.

While working in this dotfiles repo:
- Check bare-repo tracked state before edits using `/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status -s`.
- Use full bare-repo git commands by default instead of relying on shell aliases.
- Treat `~/.dotfiles_setup/` as the setup source of truth whenever bootstrap or machine setup behavior is involved.
- If you add, rename, or reorganize a tracked config directory, update `DOTDIRS` in `~/.config/shell/dotfiles.sh` in the same change.
- If you change module structure, workflow, file ownership, or notable behavior, update the relevant README files automatically unless the user explicitly says not to.
- Keep `~/.config/opencode/dotfiles-context.md` and `~/.config/opencode/dotfiles-reference.md` in sync when module layout or workflow guidance changes.

Then help with this task:
$ARGUMENTS
