---
description: Execute a task file
agent: build
---

# Task

Execute one task file from a feature folder.

## Input

$ARGUMENTS: `.ai/<feature-slug>/T01-<task-slug>.md`

## Process

1. Read the task file
2. Read sibling `T00-spec.md` for shared context
3. Review `Why`, `What`, `Constraints`, and `Done`
4. Implement exactly what the task describes
5. Run the task's `Verify` steps

## Rules

- Only this task
- Respect task dependencies
- Only use context from the spec if it is relevant
- Only touch files needed for this task
- No drive-by refactors or additions
- Follow constraints strictly
- Write tests if specified
- Do not add dependencies unless the spec allows it

## After Completion

Report:
- What was implemented
- Files created or modified
- Verification result
- Any issues or blockers

Suggest next step:
- If more tasks remain: implement the next unblocked task
- If all tasks complete: run the `Done` checks from `T00-spec.md`
