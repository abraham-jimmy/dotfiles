---
description: Evaluate and integrate a changed NOVA feature contract
agent: nova-project-planner
---

# NOVA Feature Spec Update

$ARGUMENTS: proposed change, feature path, or both

Load `nova-workflow-governance`, `nova-feature-planning`, `nova-inbox-management`, `nova-task-exception-resolution`, and `nova-git-handoff`.

Use the authoritative first-person voice, startup mark, and checkpoint presentation. Do not refer to yourself as NOVA in conversation.

## Git Preflight

This is the first substantive check. Resolve the repository and inspect complete status before reading the feature contract. Continue only from a clean tree, verified user-inbox intake, or the documented active-task planning exception. To classify the planning exception, inspect only the minimum recorded active-task metadata and changed paths. For any other dirty state, list every path in a `NOVA // PREFLIGHT`, mark the command `[BLOCKED]`, tell the user to commit, stash, or otherwise clean it, and wait. When the user says it is clean, rerun status first and continue only after verification.

## Context Brief

Before proposing edits, report the feature outcome/state, active task, completed work, proposed change, current work at risk, reusable work, acceptance impact, and likely product/dependency impact. Offer explanation when intent is unclear.

Accept only `Draft`, `Approved`, `In Progress`, `Validating`, `Blocked`, or `Deferred`. `Completed` and `Cancelled` are terminal; record changed direction through a new feature or Product Change Request instead of reopening them. A resolved `Blocked` or `Deferred` feature returns to `Approved` before execution or `In Progress` after execution began.

## Timing

Recommend `Apply now`, `Before next task`, `Later`, `Separate feature`, or `Reject`, with arguments. The user decides. If the change may invalidate active work, pause and ask before continuing.

## Integration

- Classify and route every new and due inbox entry; only approved durable deferrals may remain
- Never edit the product spec
- Create a Product Change Request for product acceptance, priority, feasibility, shared constraints, feature ordering, or dependency effects
- If any proposed feature edit depends on that product change, record the feature as `Blocked` with the request and unblock condition, then stop those dependent edits while the request is `Proposed` or `Approved`; apply only independent edits meanwhile. After terminal product handling, reconcile feature state and either integrate the applied decision or discard rejected/withdrawn assumptions.
- Update feature acceptance only after explicit approval
- Preserve completed history; mark impacted/superseded work and create remediation/new tasks
- Recalculate task dependencies and review profiles
- Remove routed inbox input only after its destination is durable

Normal use starts clean or from verified user-inbox intake; route intake and include its cleanup in the approved documentation commit. During a recorded active task, allow the controlled planning exception only when nothing is staged and all non-planning changes belong to that task.

Small approved changes may join the task commit. For a material replan, show only the planning diff and message in a `NOVA // GIT HANDOFF`, then ask whether to commit named `.ai-nova/` planning artifacts separately. Never stage implementation code through this command.

For normal clean-tree use, always show the final documentation diff, propose a scoped message, and ask before staging. Review the staged diff, commit after approval, and report hash/message so the next NOVA command starts clean.
