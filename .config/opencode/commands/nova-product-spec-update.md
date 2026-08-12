---
description: Apply an approved NOVA product update and dependency propagation
agent: nova-product-steward
---

# NOVA Product Spec Update

$ARGUMENTS: optional Product Change Request, validated feature path, or update description

Load `nova-workflow-governance`, `nova-product-governance`, `nova-inbox-management`, and `nova-git-handoff`.

Use the authoritative first-person voice, startup mark, and checkpoint presentation. Do not refer to yourself as NOVA in conversation.

## Git Preflight

This is the first substantive check. Resolve the repository and inspect complete status before reading product or request artifacts. Continue only from a clean tree, verified user-inbox intake, or the documented product-steward exception. To classify the steward exception, inspect only the minimum recorded active-task metadata and changed paths. For any other dirty state, list every path in a `NOVA // PREFLIGHT`, mark the command `[BLOCKED]`, tell the user to commit, stash, or otherwise clean it, and wait. When the user says it is clean, rerun status first and continue only after verification.

## Scope

This is the only command that may edit an existing `.ai-nova/product-spec.md`. It handles product decisions, mandatory post-validation progress, roadmap changes, limitations, and dependency propagation.

## Process

1. Read the product spec and supplied Product Change Request/Product Handoff Request/feature evidence; classify and route every new and due inbox entry before deciding relevance
2. Confirm the update follows the product schema
3. Calculate direct and transitive feature effects, readiness, blockers, acceptance changes, and completed work at risk
4. Distinguish facts, assumptions, and recommendations
5. Show one complete proposed product diff and ask what to do
6. Apply only after explicit approval
7. Mark change requests `Applied`, `Rejected`, or `Withdrawn`, mark handoffs `Applied`, and remove safely routed inbox entries

Every product edit requires approval. Normal use starts clean or from verified user-inbox intake; route intake and include its cleanup in the approved product commit. If invoked during a dirty active task, allow the controlled steward exception only when nothing is staged, all non-product changes belong to that recorded task, and only the product spec, Product Change Request or Product Handoff Request, and routed inbox entry are staged after approval. Otherwise use the standard dirty-tree pause. If active work must be preserved through a WIP fallback, route that decision through task exception resolution and require explicit approval.

## Mandatory Feature Handoff

For a validated feature, consume its Product Handoff Request and record completion, evidence, limitations, dependency effects, and newly ready features. If dependency-ready work remains, ask the user to select the next feature and mark it `Selected`. If no planned work remains, revalidate product acceptance, obtain any required manual confirmation, and ask whether to mark the product `Completed`; a completed product has no `Selected` row. Another feature spec must not be created before this handoff completes.

## Completion

Validate schema and dependency cycles, present a `NOVA // GIT HANDOFF`, propose a product-scoped message, ask before staging, review the staged diff, commit, and report hash/message as `[RESULT]`. Present dependency-ready feature options and recommend `/nova-feature-spec-create` in a fresh session as `[NEXT]`.
