---
description: Process and route every pending NOVA inbox idea
agent: nova-project-planner
---

# NOVA Inbox Process

$ARGUMENTS: optional repository, explanation request, or specific new idea

Load `nova-workflow-governance`, `nova-inbox-management`, `nova-feature-planning`, `nova-product-governance`, and `nova-git-handoff`.

Use the authoritative first-person voice, startup mark, and checkpoint presentation. Do not refer to yourself as NOVA in conversation.

## Git Preflight

This is the first substantive check. Resolve the repository and inspect complete status before reading inbox entries. Continue only from a clean tree, verified user-only inbox intake, or the documented active-task planning exception. To classify an active-task exception, inspect only the minimum recorded task metadata and changed paths. For any other dirty state, list every path in a `NOVA // PREFLIGHT`, mark the command `[BLOCKED]`, tell the user to commit, stash, or otherwise clean it, and wait. When the user says it is clean, rerun status first and continue only after verification.

## Input

Use only `.ai-nova/INBOX.md`. The user writes under `## User Input`; NOVA alone edits below the protected divider.

If invoked during an active task, inspect its recorded clean baseline and Git state. Do not stage or commit implementation changes.

## Process Everything

1. Read every user entry and deferred entry due at this checkpoint
2. Preserve wording and merge only obvious duplicates
3. Classify each as task, feature, cross-feature, product, proposed feature, future, or unclear
4. Recommend `Now`, `Before next task`, `Later`, or `Needs clarification`
5. Explain rework, acceptance, current-task, completed-work, and dependency impact
6. Ask focused questions for ambiguity
7. Present one consolidated routing plan and ask for approval
8. Apply all independent approved routes
9. Create Product Change Requests for product effects; never edit the product spec
10. Give every deferred entry a reason and approved lifecycle review trigger
11. Remove each user entry immediately after verifying its destination is durable

You may strongly recommend interrupting work, but the user decides. If the user continues, record the accepted risk and review trigger as advisory rather than a hard blocker.

For feature changes, use the `nova-feature-spec-update` contract. Preserve completed history and create new impacted/remediation tasks instead of rewriting outcomes.

## Git

Normal invocation requires a clean tree or the user-inbox intake exception: nothing staged, `.ai-nova/INBOX.md` as the only changed path, and only the user-owned region above the divider changed from `HEAD`. Changes below the divider or any other non-exempt dirty path use the standard pause-and-reverify behavior. During a recorded active task, small routed changes may join the task commit; material planning changes may use the controlled approved planning-only commit. Report every destination and any remaining deferred entry.

For normal clean-tree use, show all routed documentation changes in a `NOVA // GIT HANDOFF`, propose a scoped message, and ask before staging. Review the staged diff, commit after approval, and report hash/message as `[RESULT]`. During active-task use, leave no staged paths and state exactly which changes will join the task commit.
