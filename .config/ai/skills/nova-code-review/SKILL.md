---
name: nova-code-review
description: Performs read-only NOVA correctness and risk-profile reviews against a task and feature contract. Use when a NOVA task requests correctness, security, data, performance, or concurrency review.
---

# NOVA Code Review

Read only the task, relevant feature constraints, task diff, verification results, and directly necessary code. Do not edit.

## Profiles

- `self`: task agent rechecks its work; no independent reviewer
- `correctness`: bugs, regressions, edge cases, and missing tests
- `security`: auth, permissions, secrets, untrusted input, networking, sensitive data
- `data`: schema, migration, persistence, deletion, compatibility
- `performance`: hot paths, resource use, concurrency, lifetime, volume
- `manual-ui`: human visual and interaction confirmation
- `design-decision`: user approval before implementation

Report findings first by severity with file/line references, evidence, impact, and a minimal recommendation. Serious findings block completion unless fixed or explicitly waived by the user with an accurate `Accepted Exception` record. Automated review never passes UI or design judgment.
