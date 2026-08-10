---
name: nova-feature-planning
description: Creates and updates NOVA feature contracts, task tables, dependencies, and review profiles. Use for feature specs, feature replanning, or expanding approved feature work into task files.
---

# NOVA Feature Planning

Read the product spec, due inbox entries, and relevant repository context. Do not edit the product spec.

Use the canonical feature and task schemas under `~/.config/ai/workflows/nova/templates/`.

## Feature Contract

`T00-spec.md` contains:

- Status and product feature ID
- Why and shippable outcome
- Relevant context and established patterns
- Decisions, constraints, and exclusions
- Task table: `ID | Task | Status | Depends on | Review | File`
- End-to-end acceptance criteria
- Validation attempt metadata and per-acceptance result/evidence table
- Change and exception history

## Planning Rules

- Ask enough questions to make the artifact self-contained for a fresh session.
- Obtain explicit approval before setting the feature `Approved`.
- Use stable `FNNN` and `TNN` IDs and paths.
- Task rows define outcome, dependency, and review profile at a natural commit boundary.
- Detailed task files derive from approved rows and do not invent requirements.
- Materialization marks dependency-satisfied rows `Ready`; completion and replanning recalculate newly ready rows.
- Completed history is immutable; changed direction creates impacted, superseded, or remediation rows.
- Product-impacting changes create a Product Change Request and wait for product handling when required.
- Material replans may receive an approved planning-only commit; small changes may join the active task commit.
