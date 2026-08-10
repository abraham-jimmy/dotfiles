---
description: Explain the next legal NOVA action from documentation state
agent: nova-readonly
---

# NOVA Suggest Next Action

$ARGUMENTS: optional repository path or scope

Load `nova-workflow-governance`, `nova-project-structure`, and `nova-inbox-management`.

## Read-Only Boundary

Read Git status metadata with `nova_git` and read NOVA documentation only. Never read product source or implementation diffs unless explicitly requested. Never edit or invoke the next phase.

Determine:

- Whether NOVA setup and product state are valid
- Whether the Git tree permits the proposed phase
- Whether new/due inbox entries should be processed first
- Whether product or feature decisions/requests are pending
- Whether a task is dependency-ready
- Whether validation or mandatory product handoff is due
- Whether documentation state is inconsistent

Return exactly one primary recommendation when possible:

```text
NOVA Next Action
Project:
Current phase:
Git state:
Blocking or advisory concerns:
Recommended command:
Why:
Fresh context: Yes/No
```

When choices exist, show dependency-ready options and a recommendation, then let the user choose. Do not silently resolve ambiguity. If no legal next action exists, explain the minimum state correction required.
