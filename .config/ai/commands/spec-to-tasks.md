---
description: Expand a spec into per-task files
agent: plan
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
5. Create one task file per task in the same feature folder
6. Keep each task file actionable and easy to review

## Output Files

Create files in the same folder as the spec:

- `.ai/<feature-slug>/T01-<task-slug>.md`
- `.ai/<feature-slug>/T02-<task-slug>.md`
- `.ai/<feature-slug>/T03-<task-slug>.md`

Use short, descriptive slugs.

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

## Task File Format

Write each file like this:

```markdown
# T01: [Clear task title]

## Summary

[1-2 sentences describing what this task delivers.]

## Depends on

- None

Or:

- `T01` — [why]

## Do

- [Concrete implementation step]
- [Concrete implementation step]
- [Concrete implementation step]

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
- Verify steps are specific
- Context is included only when relevant
- The task files are saved beside `T00-spec.md`

## Scope

- Do not invent unrelated features

## Output

After writing:
1. Save task files to `.ai/<feature-slug>/`
2. Return the created file paths
3. Briefly summarize the task breakdown
