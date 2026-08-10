---
name: nova-product-governance
description: Defines NOVA product specs, dependency propagation, Product Change Requests, and exclusive product stewardship. Use when creating, reviewing, or updating NOVA product-level intent or progress.
---

# NOVA Product Governance

Product intent, roadmap, dependencies, and product decisions live in `.ai-nova/product-spec.md`.

Use the canonical product and request schemas under `~/.config/ai/workflows/nova/templates/`.

## Required Product Sections

- Status and product outcome
- Product constraints and accepted limitations
- Feature dashboard: `ID | Feature | Status | Depends on | Spec | Blocker`
- Product acceptance criteria
- Decision and change history

## Update Rules

- Existing product specs may be edited only by the product steward.
- Show the complete proposed update and ask before editing.
- Recalculate direct and transitive dependencies, readiness, roadmap effects, acceptance, and completed work at risk.
- Every product edit follows the existing schema; do not invent ad hoc sections.
- A validated feature requires a mandatory product handoff before another feature is created.
- Product-impacting feature work creates a Product Change Request first.
- Routine validated-feature progress uses a Product Handoff Request, not a Product Change Request.

## Product Change Request

Record origin, evidence, current rule, proposed rule, dependency edges, affected features, delivery impact, options, recommendation, approval, application result, `Blocks` feature IDs, and an exact unblock condition. `Blocks` means a complete execution stop for each named feature. The unresolved request gates work while the product row and existing feature spec are reconciled by their separate owners in approved commits; temporary mismatch is allowed. After terminal handling, reconcile both states before work resumes; only `Applied` decisions enter the contract.

Request states are `Proposed`, `Approved`, `Applied`, `Rejected`, or `Withdrawn`. Handoff states are `Pending` or `Applied`.

Other NOVA commands may read product documentation and create requests but never edit the product spec directly.
