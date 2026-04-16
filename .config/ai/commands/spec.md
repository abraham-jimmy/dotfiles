---
description: Generate implementation spec
agent: build
---

# Spec

Generate a specification for AI-assisted implementation.

## Feature

$ARGUMENTS

## Instructions

Ask only if blocked.

Create a feature folder:

- `.ai/<feature-slug>/`

Create the spec here:

- `.ai/<feature-slug>/T00-spec.md`

The spec is the source of truth for shared intent, scope, constraints, and final validation.

Do not write full task instructions in the spec.
Do include a compact task index so the work is easy to scan and review.

Write this file:

```markdown
```mark
```markdown
# Feature Name

## Why

[1-2 sentences: Problem solved. Why now.]

## What

[Concrete deliverable. How you'll know it's done.]

## Context

**Relevant files:**
- `path/to/file.ts` — [what it does]
- `path/to/other.ts` — [why it matters]

**Patterns to follow:**
- [Existing convention to match, with example file]

**Key decisions already made:**
- [Tech choices, libraries, approaches locked in]

## Constraints

**Must:**
- [Required patterns/conventions]

**Must not:**
- [No new dependencies unless specified]
- [Don't modify unrelated code]
- [Don't refactor existing code]

**Out of scope:**
- [Adjacent features explicitly not included]

## Task Index

- `T01` — [Task title]. [1-line summary.]
- `T02` — [Task title]. [1-line summary.]
- `T03` — [Task title]. [1-line summary.]

## Done

[End-to-end verification after all tasks]

- [ ] `build/test command passes`
- [ ] Manual: [what to verify in UI/API]
- [ ] No regressions in [related area]
```

## Guidelines

**Spec structure:**
- Keep the spec high signal
- Put shared context here, not in every task file
- Keep task entries short but specific enough to guide task creation
- The task index should be enough to understand sequencing and intent at a glance

**Task index rules:**
- One line per task
- Include task number, title, and a short summary
- Order tasks by implementation sequence
- Split at natural commit boundaries
- Group changes that must ship together

**When writing the spec:**
- Prefer concrete file paths over abstractions
- Capture decisions so later task files do not need to re-decide them
- Do not duplicate step-by-step implementation details that belong in task files

**Writing good verify steps:**
- Prefer commands over manual checks
- Manual checks should be specific: "Click X, see Y" not "verify it works"
- Include the unhappy path when relevant

**Context section tips:**
- List only files the agent will actually touch or need to reference
- "Patterns to follow" with a concrete example file beats abstract description
- Capture decisions so the agent doesn't re-litigate them

**When to skip sections:**
- Trivial features (< 3 files): keep the spec brief
- Bug fixes: Why + What + small task index may suffice
- Spikes/exploration: just Why + What + time box

## Scaling

**Small (1-3 files):** Brief spec, 1-2 task index entries
**Medium (4-10 files):** Full spec, 2-4 task index entries
**Large (10+ files):** Consider splitting into multiple feature folders

## Output

After writing:
1. Spec saved to `.ai/<feature-slug>/T00-spec.md`
2. Review for completeness
3. Confirm the task index is clear enough for per-task expansion
4. Next step: run the task generation command against `T00-spec.md`
