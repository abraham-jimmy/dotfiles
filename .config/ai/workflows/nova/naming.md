# NOVA Naming

## Commands

Commands use the `nova-` prefix followed by an explicit domain and action:

```text
nova-product-spec-create
nova-feature-spec-to-tasks
nova-project-status
nova-workflow-update
```

Prefer clarity over brevity. Names must describe user intent rather than implementation mechanics.

## Project Files

- Root: `.ai-nova/`
- Global inbox: `INBOX.md`
- Optional discovery/migration input: `PRODUCT-INPUT.md`
- Product source of truth: `product-spec.md`
- Features: `features/FNNN-short-slug/`
- Feature source of truth: `T00-spec.md`
- Tasks: `TNN-short-slug.md`
- Product requests: `product-changes/PCR-NNN-short-slug.md`
- Product handoffs: `product-changes/PHR-FNNN.md`

Use lowercase ASCII slugs with hyphens. IDs are stable and never reused. Do not encode lifecycle state in paths or filenames.

## Workflow Changes

New command names must fit the existing domain vocabulary, avoid overlap, and remain understandable in autocomplete. Renames require a migration and documentation plan; legacy commands are not silently replaced.
