---
description: Refine a change inbox without creating tasks
agent: build
---

# Refine Ideas

Refine `change-inbox.md` into reviewed, deduplicated idea sections without creating or updating task files.

## Input

$ARGUMENTS: optional feature folder or inbox file

Recommended inbox file name:

- `.ai/<feature-slug>/change-inbox.md`

## Resolution

1. If an inbox file is provided, use it.
2. If a feature folder is provided, use `<feature-folder>/change-inbox.md`.
3. If no argument is provided, resolve the Git root with `git rev-parse --show-toplevel`.
4. Search only under `<git-root>/.ai/` for `*/change-inbox.md`.
5. If exactly one inbox is found, use it.
6. If multiple inboxes are found, ask the user which one to refine.
7. If no inbox is found, ask the user for the feature folder or inbox file path.

## First Check

Before editing, check whether refinement is needed.

Refinement is needed if any of these are true:

- `## Raw`, `## Open`, `## Blocked`, or `## Processed` is missing.
- There are notes under `## Raw`.
- There are unsectioned notes outside the standard sections.
- `## Open` contains duplicate or overlapping ideas.
- One idea contains multiple unrelated changes.
- An idea is too vague to become a task without cleanup.
- An idea appears already covered by an existing task.
- Checked items remain under `## Open`.
- An idea needs a user choice or conflicts with known task direction.

If refinement is not needed, report `No refinement needed` and stop.

## Process

1. Read `change-inbox.md`.
2. Do not create, update, or rewrite `T00-spec.md`.
3. Do not create, update, rename, or rewrite task files.
4. If needed, read sibling task files named `TNN-*.md` where `NN` is greater than `00` only to detect already-covered ideas.
5. Ensure `change-inbox.md` has `## Raw`, `## Open`, `## Blocked`, and `## Processed` sections.
6. Treat unchecked ideas under `## Raw`, unchecked ideas under `## Open`, and unsectioned notes as refinement candidates.
7. Ignore anything under `## Processed` unless the user explicitly asks to revisit it.
8. Move checked items found outside `## Processed` to `## Processed`.
9. Deduplicate similar ideas.
10. Merge overlapping notes into one clearer idea.
11. Split bundled notes into separate ideas when they describe independent changes.
12. Rewrite unclear notes into concise actionable ideas without choosing product behavior, visual direction, architecture, dependencies, or scope.
13. Move every refined actionable idea to `## Open` as an unchecked item.
14. Move every unclear, conflicting, choice-dependent, or blocked idea to `## Blocked` with the question or blocker.
15. Move every already-covered idea and duplicate raw note to `## Processed` with `Duplicate of: [refined idea]` or `Covered by: TNN-<task-slug>.md` when relevant.
16. Preserve the original intent; do not delete ideas unless the user explicitly asks.

## Decision Rules

- If refinement requires choosing product behavior, visual direction, architecture, dependencies, or scope, put the item under `## Blocked` with the choice needed.
- If an idea proposes a large scope change, new feature area, or major redesign, put it under `## Blocked` and suggest running the `spec` command to create a new feature folder with the bigger scope.
- Do not silently choose colors, fonts, layouts, copy tone, libraries, naming schemes, architecture, or scope tradeoffs.

## Review Check

Before finishing, verify:

- `T00-spec.md` was not created, updated, rewritten, or renamed.
- No task files were created, updated, renamed, or rewritten.
- `change-inbox.md` has `## Raw`, `## Open`, `## Blocked`, and `## Processed` sections.
- `## Open` contains only unprocessed actionable ideas.
- `## Blocked` contains ideas that need choices, conflict resolution, or a larger spec.
- Every refined idea was moved into exactly one of `## Open`, `## Blocked`, or `## Processed`.
- Checked items and ideas under `## Processed` were not processed again.

## Output

After writing:

1. Say whether refinement was needed.
2. Summarize what moved to `Open`, `Blocked`, or `Processed`.
3. List any decisions needed from the user.
4. If ready, suggest running `ideas-to-tasks` after reviewing `change-inbox.md`.
