---
description: Initialize, audit, reconcile, or upgrade a NOVA project structure
agent: nova-setup-steward
---

# NOVA Project Setup

$ARGUMENTS: optional setup intent; launch OpenCode in the repository being initialized

Load `nova-workflow-governance`, `nova-project-structure`, and `nova-git-handoff`.

## First Response

Resolve the Git root, inspect Git status and documentation structure, then report before asking what to do:

```text
NOVA Project Setup
Repository:
Git state:
NOVA structure:
Legacy .ai workflow:
NOVA workflow version:
Structure checks:
```

Use the `nova_project_check` tool for deterministic structure checks. Explain its failures rather than claiming setup is valid from directory presence alone.

Offer context-aware choices: explain the standard, initialize, audit only, reconcile, review moves/renames, summarize legacy documentation, or upgrade. Do not write before the user chooses and approves the exact plan.

## Standard

Create only as approved:

```text
.ai-nova/
  README.md
  INBOX.md
  product-changes/.gitkeep
  features/.gitkeep
```

Use the canonical project README and inbox templates under `~/.config/ai/workflows/nova/templates/`.

Do not create `product-spec.md`; `/nova-product-spec-create` owns it.

`INBOX.md` must contain `## User Input`, guidance that the user may add natural text or bullets, and this divider before `## Deferred`:

```text
<!-- ========================================================== -->
<!-- NOVA-MANAGED AREA: ONLY NOVA MAY EDIT BELOW THIS LINE       -->
<!-- ========================================================== -->
```

## Legacy `.ai/`

Never modify it by default. Ask whether to initialize fresh, audit only, or summarize its documentation into `.ai-nova/PRODUCT-INPUT.md`.

For an approved summary:

- Read legacy documentation only, not product source
- Preserve intent, source paths, constraints, decisions, dependencies, ideas, contradictions, and missing context
- Mark completion claims `Reported, unverified`
- Do not resolve ambiguity or redesign the product
- Show the summary before writing
- Leave `.ai/` untouched

After writing, recommend a fresh `/nova-product-spec-create .ai-nova/PRODUCT-INPUT.md` session. Keeping `.ai/` is recommended; archive/removal may be offered only as an explicit, non-default action.

## Safety

Require a completely clean Git tree before any mutation. Show every create, move, rename, rewrite, or removal. Validate the result, propose a commit message, and ask before staging or committing.
