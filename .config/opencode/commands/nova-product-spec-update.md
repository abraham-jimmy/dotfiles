---
description: Apply an approved NOVA product update and dependency propagation
agent: nova-product-steward
---

# NOVA Product Spec Update

$ARGUMENTS: optional Product Change Request, validated feature path, or update description

Load `nova-workflow-governance`, `nova-product-governance`, `nova-inbox-management`, and `nova-git-handoff`.

## Scope

This is the only command that may edit an existing `.ai-nova/product-spec.md`. It handles product decisions, mandatory post-validation progress, roadmap changes, limitations, and dependency propagation.

## Process

1. Resolve the repository and inspect Git state
2. Read the product spec and supplied Product Change Request/Product Handoff Request/feature evidence; classify and route every new and due inbox entry before deciding relevance
3. Confirm the update follows the product schema
4. Calculate direct and transitive feature effects, readiness, blockers, acceptance changes, and completed work at risk
5. Distinguish facts, assumptions, and recommendations
6. Show one complete proposed product diff and ask what to do
7. Apply only after explicit approval
8. Mark change requests `Applied`, `Rejected`, or `Withdrawn`, mark handoffs `Applied`, and remove safely routed inbox entries

Every product edit requires approval. Normal use starts clean or from verified user-inbox intake; route intake and include its cleanup in the approved product commit. If invoked during a dirty active task, allow the controlled steward exception only when nothing is staged, all non-product changes belong to that recorded task, and only the product spec, Product Change Request or Product Handoff Request, and routed inbox entry are staged after approval. Otherwise hard stop or offer the approved WIP-branch fallback.

## Mandatory Feature Handoff

For a validated feature, consume its Product Handoff Request and record completion, evidence, limitations, dependency effects, and newly ready features. If dependency-ready work remains, ask the user to select the next feature and mark it `Selected`. If no planned work remains, revalidate product acceptance, obtain any required manual confirmation, and ask whether to mark the product `Completed`; a completed product has no `Selected` row. Another feature spec must not be created before this handoff completes.

## Completion

Validate schema and dependency cycles, propose a product-scoped message, ask before staging, review the staged diff, commit, and report hash/message. Present dependency-ready feature options and recommend `/nova-feature-spec-create` in a fresh session.
