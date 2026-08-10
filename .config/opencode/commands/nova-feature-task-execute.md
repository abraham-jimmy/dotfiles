---
description: Execute one dependency-ready NOVA feature task
agent: nova-task-worker
---

# NOVA Feature Task Execute

$ARGUMENTS: optional task file, feature folder, or task ID

Load `nova-workflow-governance`, `nova-task-execution`, `nova-inbox-management`, `nova-verification`, and `nova-git-handoff`.

## Hard Preflight

Before reading or resolving a task:

1. Resolve the repository and required Git invocation
2. Inspect complete `git status --short`
3. If the only change is unstaged `.ai-nova/INBOX.md`, verify that only user text above the protected divider differs from `HEAD`; process it, complete its approved documentation commit, and repeat preflight
4. If the requested task is already `In Progress`, allow resume only from a clean tree at its recorded WIP branch tip when its task file contains `WIP marker: This commit`
5. For any other staged, unstaged, or untracked path, list all paths and hard stop without inspecting the task
6. Tell the user the tree must be clean or match one of those exact exceptions before rerunning; do not unstage, stash, discard, branch, commit, or continue automatically

Then process all new and due inbox entries. If routing changes documentation, finish its approved Git handoff and repeat the complete clean-tree preflight before resolving a task. If an idea may invalidate current work, explain why and ask whether to pause; the user decides.

## Resolution

Use the feature spec's authoritative task table. Select the requested task or the first `Ready` task whose dependencies are `Completed`, `Superseded`, or `Accepted Exception`. A recorded clean WIP resume may select only its existing `In Progress` task. Do not select blocked, deferred, impacted, or dependency-incomplete work. Ask when multiple features/tasks are plausible.

Before starting or resuming, require the corresponding product dashboard row to be `Selected` and refuse while any unresolved Product Change Request names the feature in `Blocks`. Otherwise stop for product/feature state reconciliation.

## Execution

- Read the selected task and relevant feature/product context
- If the feature is `Approved`, set it to `In Progress`; if already `In Progress`, keep it there for subsequent tasks; reject other source states
- Set the task-table row to `In Progress`
- Before the first source mutation, record task ID, starting `HEAD`, and branch in the task execution metadata
- Implement only that task
- Ask before consequential product, scope, architecture, design, UX, or risk decisions
- Check the inbox before destructive/irreversible operations and before completion
- Run specified verification
- Apply task review profiles

For an independent profile, delegate read-only review to `nova-task-reviewer` with only the task, relevant contract, diff, and verification. Serious findings require a fix or user-approved `Accepted Exception`. UI and design always require fresh human confirmation.

If checks fail, limitations appear, or direction is wrong, load `nova-task-exception-resolution`, restore context, explain options, and resolve before other work. Prefer a coherent safe state. For an approved WIP fallback, create and record `nova/wip-FNNN-TNN`, its unblock condition, and `WIP marker: This commit` before creating the WIP commit; do not mark the task complete. A fresh task session can resume only from that clean marked branch tip.

## Completion And Commit

Update task evidence, clear any WIP marker/unblock condition, and set the task-table row `Completed` only when the current contract is truthfully satisfied. Recalculate the task graph and mark newly dependency-satisfied `Planned` rows `Ready`. Do not rename files.

Review the full task diff and then, before staging anything, tell the user:

```text
Task is considered done.
Suggested commit: <message>
Would you like me to stage these changes and create this commit?
```

Wait for explicit confirmation. If declined, leave everything unstaged. If approved, stage all task changes, review the staged diff, commit, verify success, and report hash/message. If more tasks remain, recommend the next fresh task session; otherwise recommend fresh feature validation.
