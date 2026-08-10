---
name: nova-task-exception-resolution
description: Resolves NOVA task limitations, failed checks, wrong assumptions, and mid-task scope or product changes. Use only when a task cannot complete as planned or current work may be invalidated.
---

# NOVA Task Exception Resolution

Restore context before asking for a decision:

- Task goal and product/feature reason
- Requirement and exact failed check
- Expected and observed behavior
- Evidence, attempts, and likely cause
- Current, completed, and dependent work at risk
- Feature and product impact
- Reasonable options and recommendation

## Classify

- Local repair: contract remains correct; fix now
- Task clarification: wording/check is inaccurate; approve amendment
- Follow-up: current outcome remains valid; create later work
- Required split: required work becomes a dependency/remediation task
- Feature limitation: revise feature acceptance through feature update
- Product impact: create Product Change Request and use product steward
- External block: record unblock condition and affected dependencies

Prefer continuing in the same session until coherent. Commit a safe subset only when checks pass for retained behavior and no half-enabled or unsafe state remains. Otherwise hard-block. If required to preserve non-coherent work and unlock governance, offer an explicitly approved `nova/wip-FNNN-TNN` branch and WIP commit. Record the starting baseline, branch, task ID, reason, unblock condition, and `WIP marker: This commit` in task evidence before committing. `/nova-feature-task-execute` may later resume only that `In Progress` task from a clean tree at the marked branch tip.

Never roll back, stash, branch, rewrite scope, or mark completion without approval.
