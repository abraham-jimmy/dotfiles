---
description: Execute a task file
agent: build
---

# Task

Execute one task file from a feature folder.

## Input

$ARGUMENTS: optional task file or feature folder

If a task file is provided, execute that task.
If a feature folder is provided, execute the next incomplete task in that folder.
If no argument is provided, resolve the Git root and search from there for the next incomplete task.

## Task Resolution

When a feature folder or no argument is provided:

1. If a feature folder was provided, search only inside that folder
2. If no argument was provided, resolve the Git root with `git rev-parse --show-toplevel`
3. Do not run any task-file glob before the Git root is resolved
4. Search for task files under `<git-root>/.ai/`
5. When using Glob with no argument provided, set `path` to `<git-root>/.ai` and set `pattern` to `*/T*.md`
6. When using Glob with a provided feature folder, set `path` to that feature folder and set `pattern` to `T*.md`
7. After globbing, keep only task files whose filenames match `T` followed by two digits and `-`
8. Exclude `T00-spec.md`
9. Exclude files ending in `-DONE.md`
10. Sort remaining task files by task number
11. Select the lowest-numbered remaining task
12. If no incomplete task exists, report that all tasks appear complete and suggest running `validate-spec` for the feature folder in a new isolated session
13. If no task files are found, ask the user for the feature folder instead of inspecting unrelated workspace structure

## Process

1. Resolve the task file path from `$ARGUMENTS`, or select the next incomplete task using `Task Resolution`
2. Check the task file name before reading the task body
3. If the file name ends with `-DONE.md`, read only the task's `## Completed State` section, report that the task appears completed, and ask the user whether to continue anyway
4. If the file name does not end with `-DONE.md`, read the task file and check `## Completed State`
5. If `## Completed State` says the task is completed, report that state and ask the user whether to continue anyway
6. If `## Completed State` is missing, report that and ask before continuing or adding it
7. Read sibling `T00-spec.md` for shared context
8. Review `Why`, `What`, `Constraints`, and `Done`
9. Implement exactly what the task describes
10. Run the task's `Verify` steps

## Rules

- Only this task
- Respect task dependencies
- Only use context from the spec if it is relevant
- Only touch files needed for this task
- No drive-by refactors or additions
- Follow constraints strictly
- Write tests if specified
- Do not add dependencies unless the spec allows it
- Do not make design choices silently
- If a choice is required, stop and ask the user which option to take
- If the current chosen design causes issues, stop and ask before changing it
- Keep `## Completed State` at the top of the task file for quick scanning
- Keep `## Completed State` limited to completion status and a concise summary of what was done
- If a user-approved major design change happens, update the relevant task details so the task contains the history of the change
- Do not put design-change history in `## Completed State`
- Mark each completed item in the task's `## Do` section as checked (`- [x]`)
- Do not mark the task complete while any required `## Do` item remains unchecked

## After Completion

Update the task file before reporting completion:

1. Set `## Completed State` to `Status: Completed`
2. Replace `What was done` with a concise checklist or bullets summarizing completed work
3. Mark every completed `## Do` checkbox as checked (`- [x]`)
4. If major design decisions changed with user approval, update the affected task sections with the new decision and the original-plan change
5. Record verification results in the relevant task details when useful
6. Rename the task file by appending `-DONE` before `.md`, for example `T01-task-DONE.md`

Do not mark the task complete or rename it if verification failed or blockers remain.

After verification succeeds and the task file is renamed:

1. Suggest committing the completed task before starting another task
2. Provide a concise commit message scoped to this task's changes
3. Do not create the commit unless the user explicitly asks

Report:
- What was implemented
- Files created or modified
- Verification result
- Any issues or blockers
- Final task file path
- Suggested commit message

Suggest next step:
- First: commit the completed task using the suggested message
- If more tasks remain after committing: implement the next unblocked task
- If the final task is complete: suggest running `validate-spec <feature-folder>` in a new isolated session
