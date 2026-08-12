---
name: nova-project-structure
description: Defines and audits NOVA's `.ai-nova/` project layout and legacy adoption. Use for NOVA setup, structural repair, migration summaries, or artifact-path questions.
---

# NOVA Project Structure

Read `~/.config/ai/workflows/nova/artifacts.md` and `naming.md`. Use canonical files from `~/.config/ai/workflows/nova/templates/` rather than recreating them from memory.

## Setup Rules

- Resolve the Git root before inspecting project artifacts.
- NOVA owns `.ai-nova/`; legacy `.ai/` is separate and untouched by default.
- Inspect complete Git status before reading setup artifacts. On a non-exempt dirty tree, list every changed path, pause, and resume only after the user says it is clean and status is reverified.
- Show every proposed create, move, rename, rewrite, or removal before applying it.
- Never modify product source code during setup.
- Never create `product-spec.md`; `/nova-product-spec-create` owns it.
- Validate links, IDs, names, tables, and workflow version after changes.

## Legacy Input

When approved, summarize `.ai/` documentation into `.ai-nova/PRODUCT-INPUT.md` without changing meaning. Preserve source paths, contradictions, uncertainty, captured ideas, and reported completion. Mark completion `Reported, unverified`.

After approved product creation, mark the input `Status: Consumed`, link `product-spec.md`, then offer removal. Never remove legacy `.ai/` automatically or recommend removal by default.
