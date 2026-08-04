---
description: Expand a spec into per-task files
agent: build
---

# Spec To Tasks

Turn a spec into reviewable task files.

## Input

$ARGUMENTS: `.ai/<feature-slug>/T00-spec.md`

If no path is provided, ask for the spec file.

## Process

1. Read the spec
2. Read the `Task Index`
3. Use `Why`, `What`, `Context`, `Constraints`, and `Done` as shared context
4. Inspect the repository if needed to confirm file paths, conventions, dependencies, or sequencing
5. Before creating or updating each task file, check whether that task number already has a `-DONE.md` file in the same feature folder
6. Do not recreate, overwrite, or rename completed task files
7. Create one incomplete task file per incomplete task in the same feature folder
8. Keep each task file actionable and easy to review

## Output Files

Create files in the same folder as the spec:

- `.ai/<feature-slug>/T01-<task-slug>.md`
- `.ai/<feature-slug>/T02-<task-slug>.md`
- `.ai/<feature-slug>/T03-<task-slug>.md`
- `.ai/<feature-slug>/change-inbox.md`

Use short, descriptive slugs.
Incomplete task files must not include `DONE` in the filename.
Completed task files are marked by appending `-DONE` before `.md`, for example `T01-<task-slug>-DONE.md`.
Create `change-inbox.md` if it does not already exist. If it exists, leave its contents unchanged.

When creating `change-inbox.md`, use this content:

```markdown
# Change Inbox

## Raw

## Open

## Blocked

## Processed
```

## Rules

- One file per task
- Expand the spec into implementation work
- Do not rewrite the whole spec into each task file
- Copy only the spec details relevant to that task
- Include task dependencies in each task file
- Make implicit work explicit when needed for implementation
- Prefer concrete instructions over broad labels
- Keep each file easy for a human to scan
- Keep each task independently workable when possible
- If a task number already has a matching `TNN-*-DONE.md` file, treat that task as completed and report it instead of generating a replacement
- If any design decision is required, stop and ask the user to choose; do not make design decisions yourself.
- Put `## Completed State` at the top of each task file for quick scanning
- Keep `## Completed State` limited to completion status and a concise summary of what was done
- Do not put design-change history in `## Completed State`; if major design changes happen later, they belong in the relevant task details

## Task File Format

Write each file like this:

```markdown
# T01: [Clear task title]

## Completed State

Status: Not completed

What was done:
- Nothing yet

## Summary

[1-2 sentences describing what this task delivers.]

## Depends on

- None

Or:

- `T01` — [why]

## Do

- [ ] [Concrete implementation step]
- [ ] [Concrete implementation step]
- [ ] [Concrete implementation step]

## Files

- `path/to/file` — [why it matters]
- `path/to/test` — [why it matters]

## Relevant Context

- [Only spec detail needed for this task]
- [Only constraint or decision needed here]
- [Only repo pattern needed here]

## Verify

- `command`
- Manual: [specific check]
```

## Writing Style

- Be clear and direct
- Prefer reviewable detail over shorthand
- Keep each task readable in one pass
- Use bullets over dense paragraphs
- Use concrete file paths when known
- Do not pad with background or theory

## Review Check

Before finishing, verify:

- Every `Task Index` item has a matching task file
- File names and task numbers match
- Dependencies are explicit
- Steps are concrete
- `Do` steps are written as checkboxes
- Verify steps are specific
- Every incomplete task file has `## Completed State` immediately after the title with `Status: Not completed`
- No completed `TNN-*-DONE.md` task file was overwritten or regenerated
- Context is included only when relevant
- The task files are saved beside `T00-spec.md`
- `change-inbox.md` exists beside `T00-spec.md`

## Scope

- Do not invent unrelated features

## Output

After writing:
1. Save task files to `.ai/<feature-slug>/`
2. Return the created file paths
3. Briefly summarize the task breakdown
4. Mention `change-inbox.md`: dump rough notes under `Raw`, run `refine-ideas`, then run `ideas-to-tasks`
