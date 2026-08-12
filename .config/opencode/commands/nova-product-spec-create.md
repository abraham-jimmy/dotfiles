---
description: Create and approve a NOVA product specification
agent: nova-product-steward
---

# NOVA Product Spec Create

$ARGUMENTS: optional product description or `.ai-nova/PRODUCT-INPUT.md`

Load `nova-workflow-governance`, `nova-product-governance`, `nova-inbox-management`, and `nova-git-handoff`.

Use the authoritative first-person voice, startup mark, and checkpoint presentation. Do not refer to yourself as NOVA in conversation.

## Git Preflight

This is the first substantive check. Resolve the Git root and inspect complete status before reading product artifacts. Require a clean tree or verified user-inbox intake. For any other dirty state, list every path in a `NOVA // PREFLIGHT`, mark the command `[BLOCKED]`, tell the user to commit, stash, or otherwise clean it, and wait. When the user says it is clean, rerun status first and continue only after verification.

## Preconditions

- If verified inbox intake is present, route it as discovery input and include its cleanup in the approved product commit
- Require a valid `.ai-nova/` setup and no existing product spec
- Read `PRODUCT-INPUT.md` when provided or present, but treat it as source material rather than truth
- Process all `User Input` and due deferred inbox entries as product-discovery input

## Discovery

Interview the user until product outcome, users, boundaries, constraints, decisions, acceptance, likely features, and dependencies are clear. Surface contradictions and assumptions. Be candid and recommend a coherent product shape; the user chooses.

## Product Spec

Create `.ai-nova/product-spec.md` with `Status: Active` only after showing the complete proposal and receiving approval. Include:

- Product status and outcome
- Users and important workflows
- Scope, constraints, exclusions, and accepted limitations
- Product-level decisions
- Feature dashboard: `ID | Feature | Status | Depends on | Spec | Blocker`
- Product acceptance criteria
- Decision/change history

Use stable `FNNN` IDs, explicit dependency edges, and intended feature-spec paths. Ask the user to select the first dependency-ready feature and mark only that product-dashboard row `Selected`; leave other eligible rows `Ready`. Do not create feature specs or task files.

## Product Input

When `PRODUCT-INPUT.md` exists, always mark it after approval as `Status: Consumed` and `Consumed by: .ai-nova/product-spec.md`. Then offer to keep it or remove it; keeping it preserves provenance, but the product spec must be self-contained either way. Do not create an input file when none existed.

## Completion

Validate schema and dependency acyclicity. Show the final diff in a `NOVA // GIT HANDOFF`, propose a message, and ask before staging or committing. End with `[NEXT]` and recommend selecting a dependency-ready feature with `/nova-feature-spec-create` in a fresh session.
