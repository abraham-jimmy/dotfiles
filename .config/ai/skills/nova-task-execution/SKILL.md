---
name: nova-task-execution
description: Executes one NOVA feature task with clean-tree, dependency, verification, review, and commit gates. Use when implementing a task from `.ai-nova/features/`.
---

# NOVA Task Execution

## Preflight

- Resolve the repository and required Git invocation.
- Require `git status --short` to be empty before task resolution, except verified user-only inbox intake or a clean approved WIP resume.
- For inbox intake, require no staged paths, only `.ai-nova/INBOX.md` changed, and an unchanged managed region below the divider; process and commit routing, then repeat clean preflight.
- For WIP resume, require a clean tree at the recorded WIP branch tip, `WIP marker: This commit` in the task file, and the requested row already `In Progress`.
- Hard stop and list every path for any other state.
- Process due inbox entries before implementation.
- Select only a dependency-ready task from the authoritative feature task table.

## Execution

- Read the task, relevant feature contract, and only necessary product context.
- Before the first mutation, record the selected task ID, starting `HEAD`, and current branch in the task's execution metadata.
- Implement only the selected task.
- Ask before product, architecture, UX, scope, or other consequential choices.
- Run specified verification and relevant targeted checks.
- Apply assigned review profiles; UI and design confirmation remain human.
- On failed or impossible verification, load `nova-task-exception-resolution`.

## Completion

- Update task evidence and the feature task-table row.
- Do not rename files.
- Review the complete task diff and propose a scoped message.
- Before staging, say the task is considered done, show the message, and ask whether to stage and commit.
- After approval, stage all task changes, review the staged diff, commit, and report hash/message.
- A failed stage or commit hard-stops without destructive recovery.
- If an approved WIP fallback is required, create the recorded `nova/wip-FNNN-TNN` branch and WIP commit, then resume only through the clean-tree WIP preflight. The WIP commit is never represented as task completion.
