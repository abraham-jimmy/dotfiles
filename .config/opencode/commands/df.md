---
description: Start with dotfiles context
agent: plan
---

Read @/home/jimmy/.config/opencode/docs/dotfiles/context.md first.
If needed, read @/home/jimmy/.config/opencode/docs/dotfiles/reference.md.

While working in this dotfiles repo:
- Check bare-repo tracked state before edits using `/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status -s`.
- Use full bare-repo git commands by default instead of relying on shell aliases.
- Treat `~/.dotfiles_setup/` as the setup source of truth whenever bootstrap or machine setup behavior is involved.
- If you add, rename, or reorganize a tracked config directory, update `DOTDIRS` in `~/.config/shell/dotfiles.sh` in the same change.
- If you change module structure, workflow, file ownership, or notable behavior, update the relevant README files automatically unless the user explicitly says not to.
- Keep `~/.config/opencode/docs/dotfiles/context.md` and `~/.config/opencode/docs/dotfiles/reference.md` in sync when module layout or workflow guidance changes.
- If a task needs access to a new trusted folder or file outside the current OpenCode allowlist, ask for confirmation before updating `~/.config/opencode/opencode.json`, then add that path to `permission.read`, `permission.edit`, and `permission.external_directory`.

Then help with this task:
$ARGUMENTS
