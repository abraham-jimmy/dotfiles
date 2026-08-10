---
description: Independently validate a completed NOVA feature specification
agent: nova-validator
---

# NOVA Feature Spec Validate

$ARGUMENTS: feature spec or feature folder

Load `nova-workflow-governance`, `nova-verification`, `nova-inbox-management`, `nova-product-governance`, and `nova-git-handoff`.

## Scope

Verification and completion metadata only. Do not implement, fix, add tests, change product source, or edit the product spec.

## Preconditions

- Resolve the repository and require a clean Git tree or verified user-inbox intake; if intake is present, route and commit it, then repeat clean preflight
- Resolve exactly one `In Progress` NOVA feature and reject illegal source states
- Classify and route every new and due inbox entry before deciding relevance; only approved durable deferrals may remain
- Require every authoritative task row to be `Completed`, `Superseded`, or `Accepted Exception` with evidence
- Reject orphaned, duplicated, missing, or unindexed task files except approved terminal `File: None` rows with recorded rationale

## Validation

Transition the feature to `Validating` for this validation attempt, then revalidate every current feature acceptance criterion in order, including checked items. Use `PASS`, `FAIL`, `MANUAL_VERIFY`, `UNVERIFIABLE`, or `Accepted Exception` exactly as defined by `nova-verification`. Keep `Validating` with recorded blockers when validation cannot complete; `/nova-feature-spec-update` returns it to `In Progress` after approved remediation.

Before replacing prior validation results, append their concise attempt/result/blocker summary to change history. Then record the latest attempt date, tested commit, result, and concise evidence for every acceptance ID in the canonical validation-results table. Accepted-exception evidence includes `Approved by user:`.

For manual UI or design checks, give exact steps and require fresh user confirmation. A prior checkmark, report, or screenshot is not fresh confirmation. Record concise evidence for every result.

## Completion Gate

Set the stable feature spec to `Status: Completed` only when task state and acceptance are handled truthfully and no blocking request remains. Never rename the feature folder or task files.

Create `product-changes/PHR-FNNN.md` from the Product Handoff Request template for the mandatory handoff. Include feature status, validation evidence, limitations, exceptions, and dependency observations. Create a separate Product Change Request only when the product contract or dependency graph is proposed to change. Do not edit the product spec.

## Report And Commit

Report every condition, task-state check, totals, blockers, feature path, and created handoff/change requests. Show the metadata diff, propose a message, and ask before staging or committing. End by requiring `/nova-product-spec-update <handoff>` in a fresh session before another feature spec may be created.
