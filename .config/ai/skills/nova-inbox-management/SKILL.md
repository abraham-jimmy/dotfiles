---
name: nova-inbox-management
description: Processes NOVA's global `INBOX.md`, classifies ideas, recommends timing, and routes approved entries. Use when ideas may affect tasks, features, product scope, dependencies, or future work.
---

# NOVA Inbox Management

The only inbox is `.ai-nova/INBOX.md`.

## Ownership

- The user writes natural text only under `## User Input`.
- NOVA never rewrites raw user wording.
- Only NOVA edits below the protected divider.
- Remove user input only after an approved destination is durable.
- Deferred items require a reason and lifecycle review trigger.
- User capture is the only normal dirty-tree intake exception: nothing may be staged, `.ai-nova/INBOX.md` must be the only changed path, and only text above the protected divider may differ from `HEAD`. Any managed-region or other path change hard-stops.

## Processing

Process every new and currently due deferred entry:

1. Preserve intent and merge obvious duplicates
2. Classify task, feature, product, cross-feature, new-feature, or future scope
3. Assign `Now`, `Before next task`, `Later`, or `Needs clarification`
4. Explain current-work, rework, acceptance, and dependency impact
5. Ask focused questions for ambiguity
6. Present one routing plan and ask for approval
7. Route to task details, feature update, Product Change Request, product proposal, deferred, or rejected decision
8. Remove safely routed user input immediately

Materially rejected ideas go to the relevant product or feature decision history before removal. A trivial idea may be discarded without a durable record only after the user explicitly confirms rejection.

NOVA recommends interruption; the user decides. If the user continues, record the accepted risk and required review trigger without turning it into a hard blocker.

Check the inbox before planning, task materialization, risky task operations, task completion, validation, product updates, and next-action selection.

At each checkpoint, classify and route every new and currently due entry. An entry may remain only as an approved durable deferral with a reason and trigger; commands must not narrow processing to entries they assume are relevant before classification.
