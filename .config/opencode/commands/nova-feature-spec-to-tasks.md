---
description: Expand an approved NOVA feature task table into task files
agent: nova-project-planner
---

# NOVA Feature Spec To Tasks

$ARGUMENTS: `.ai-nova/features/FNNN-slug/T00-spec.md` or feature folder

Load `nova-workflow-governance`, `nova-feature-planning`, `nova-inbox-management`, and `nova-git-handoff`.

Use the authoritative first-person voice, startup mark, and checkpoint presentation. Do not refer to yourself as NOVA in conversation.

## Git Preflight

This is the first substantive check. Resolve the repository and inspect complete status before reading feature artifacts. Require a clean tree or verified user-inbox intake. For any other dirty state, list every path in a `NOVA // PREFLIGHT`, mark the command `[BLOCKED]`, tell the user to commit, stash, or otherwise clean it, and wait. When the user says it is clean, rerun status first and continue only after verification.

## Preconditions

- If verified user-inbox intake is present, route and commit it, then repeat clean preflight
- Resolve exactly one `Approved` feature spec, or an `In Progress` feature containing approved missing `Planned` remediation rows
- Process every new and currently due inbox entry before materializing tasks
- Refuse when an unresolved Product Change Request names the feature in `Blocks`
- Require the corresponding product dashboard row to be `Selected`; otherwise stop for product/feature state reconciliation

## Process

Read the approved task table and relevant repository patterns. Create exactly one stable task file for each approved missing `Planned` task row that names a file; preserve every existing task file. `Ready` always means already materialized. A terminal row may use `File: None` only when feature history contains a `- TNN:` rationale explaining why it was superseded or excepted before materialization. Never invent new requirements or silently alter outcomes/dependencies. If the approved spec is insufficient, stop and recommend `/nova-feature-spec-update`.

Task files contain:

- Title and outcome summary
- Dependencies
- Concrete `Do` checklist
- Relevant files and context
- Verification steps
- Assigned review profile
- `Dependencies:` and `Profiles:` metadata exactly matching the authoritative row
- Execution metadata initialized with no baseline or WIP marker
- Outcome/evidence section initialized as not performed

Lifecycle status remains authoritative in `T00-spec.md`; do not duplicate a task status field or rename completed files. After materialization, mark every dependency-satisfied `Planned` row `Ready` and leave dependency-blocked rows `Planned`. Update file links in the task table only when needed and approved.

## Completion

Verify every non-`None` table file matches exactly once, dependencies are explicit, and checks are actionable. Show the planning diff in a `NOVA // GIT HANDOFF`, propose a message, and ask before staging or committing. End with `[NEXT]` and recommend the first dependency-ready `/nova-feature-task-execute <task>` in a fresh session.
