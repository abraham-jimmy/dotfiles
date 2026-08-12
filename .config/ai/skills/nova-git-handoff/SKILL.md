---
name: nova-git-handoff
description: Applies NOVA Git cleanliness, scoped staging, approval, planning-commit, and product-steward handoff rules. Use before NOVA edits that stage or commit project changes.
---

# NOVA Git Handoff

## Normal Rule

Mutation-capable commands inspect complete Git status before phase-artifact inspection. Documentation agents use the validated `nova_git` tool instead of arbitrary shell commands. For a dirty state that matches no documented exception, list every changed path in a concise `[BLOCKED]` preflight, tell the user to commit, stash, or otherwise clean it, and wait without reading phase state or changing Git. When the user says it is clean, rerun status first and resume in the same session only when verified. Never clean, stash, discard, stage, or commit merely to pass preflight.

Before any governed commit, inspect status/diff, propose a concise message, and ask before staging. Review the staged diff before committing and report hash/message.

The intake exception permits one unstaged `.ai-nova/INBOX.md` whose managed region below the divider is byte-identical to `HEAD`; route its user text and include the resulting inbox cleanup in the approved documentation commit. No staged or other changed path is allowed.

## Active-Task Planning Exception

A material approved replan may commit only named `.ai-nova/` planning paths while task code remains unstaged when:

- The task recorded a clean baseline
- Nothing is staged
- Every non-planning change belongs to the active task
- The exact planning diff and message are approved

Small planning changes join the task commit.

## Product Steward Exception

During an active task, the steward may stage only the Product Change Request or Product Handoff Request, product spec, and safely routed inbox entry after exact approval. Task implementation remains unstaged. If isolation cannot be proven, offer the approved WIP-branch fallback.

Never reset, discard, unstage, amend, force-push, stash, or create a recovery branch without explicit approval. The user may clean a paused tree by their chosen method; NOVA verifies the result rather than assuming it.

An approved WIP fallback records the starting `HEAD`, task ID, `nova/wip-FNNN-TNN` branch, reason, and unblock condition, and writes `WIP marker: This commit` before creating the approved WIP commit. A later task session may resume only when the tree is clean at that branch tip, the requested row is `In Progress`, and the tip's task file contains that marker. No self-referential commit hash is stored.
