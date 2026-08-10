---
description: Report NOVA project, product, feature, task, inbox, and structural status
agent: nova-readonly
---

# NOVA Project Status

$ARGUMENTS: optional repository path or requested status detail

Load `nova-workflow-governance` and `nova-project-structure`.

## Read-Only Boundary

Do not edit, stage, commit, process inbox entries, or read product source/diffs. Read only NOVA documentation, use `nova_project_check` for structure, and use `nova_git` only for status metadata unless the user explicitly changes the request.

Resolve the project root from supplied context and read NOVA documentation directly. The separate `nova-status` shell helper is available to the user outside this read-only agent. Report:

- Git state and changed path names without diff contents
- NOVA structure/version health
- Product status, roadmap phase, and dependency readiness
- Active, upcoming, completed, blocked, deferred, impacted, and superseded features
- Active feature progress and authoritative task counts
- Current or next dependency-ready task
- Pending decisions, manual checks, accepted exceptions, and blockers
- Product Change Requests and dependency effects
- New inbox count, deferred due now, and deferred later
- Validation state
- Documentation integrity issues: missing/orphaned/duplicate artifacts, invalid states, broken links, or dependency cycles

Status is informational. It may recommend `/nova-inbox-process`, `/nova-project-setup`, or another command, but must not transition into that command or modify anything.
