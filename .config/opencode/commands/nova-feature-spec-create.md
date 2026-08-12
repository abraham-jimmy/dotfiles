---
description: Create and approve the next NOVA feature specification
agent: nova-project-planner
---

# NOVA Feature Spec Create

$ARGUMENTS: optional feature ID, name, or requested outcome

Load `nova-workflow-governance`, `nova-feature-planning`, `nova-inbox-management`, and `nova-git-handoff`.

Use the authoritative first-person voice, startup mark, and checkpoint presentation. Do not refer to yourself as NOVA in conversation.

## Git Preflight

This is the first substantive check. Resolve the Git root and inspect complete status before reading feature or product artifacts. Require a clean tree or verified user-inbox intake. For any other dirty state, list every path in a `NOVA // PREFLIGHT`, mark the command `[BLOCKED]`, tell the user to commit, stash, or otherwise clean it, and wait. When the user says it is clean, rerun status first and continue only after verification.

## Preconditions

- If verified user-inbox intake is present, route and commit it, then repeat clean preflight
- Require valid `.ai-nova/` structure and an active product spec
- Require the previous validated feature's mandatory product handoff to be complete
- Process all new and due inbox entries before selecting scope
- Refuse creation while an unresolved Product Change Request names the feature in `Blocks`

## Selection

Read the product dashboard. Normally create the row already marked `Selected` by product creation or the mandatory handoff. If no row is selected, show dependency-ready options, obtain the user's choice, and require `/nova-product-spec-update` to record that selection before creating the feature. If the requested feature is absent from or conflicts with the product plan, create a Product Change Request and stop before product-level assumptions are implemented.

## Discovery

Inspect relevant repository context and interview the user until the feature is a self-contained shippable contract. Be critical about scope, dependencies, acceptance, and likely rework. The user decides.

## Output

Create `.ai-nova/features/FNNN-short-slug/T00-spec.md` only after approval and write it as `Status: Approved`. Include product feature ID, why, outcome, context, decisions, constraints, exclusions, task table, acceptance criteria, validation-results placeholders, and change/exception history.

The task table is authoritative:

```text
ID | Task | Status | Depends on | Review | File
```

Define high-level task outcomes, dependencies, stable target paths, and review profiles. Do not create detailed task files.

## Completion

Validate the feature contract and task graph. Present a `NOVA // GIT HANDOFF`, propose a planning message, and ask before staging or committing. End with `[NEXT]` and recommend `/nova-feature-spec-to-tasks <spec>` in a fresh session.
