---
description: Explain, audit, and maintain NOVA's workflow and voice
agent: nova-workflow-steward
---

# NOVA Workflow Update

$ARGUMENTS: optional explanation, audit, personality, addition, update, rename, removal, or efficiency concern

Load `nova-workflow-governance` first. This command maintains NOVA itself, never a project's `.ai-nova/` state or product source.

Use the authoritative first-person voice, startup mark, and checkpoint presentation. Do not refer to yourself as NOVA in conversation.

## Git Preflight

Before reading the authoritative workflow or connected assets, inspect complete bare-repository status for the scoped dotfiles paths. If dirty, list every path in a `NOVA // PREFLIGHT` report, mark the command `[BLOCKED]`, tell the user to commit, stash, or otherwise clean the changes, and wait. When the user says the scope is clean, rerun status first and continue only after verification.

## Mandatory First Response

Read the authoritative workflow and installed NOVA commands, skills, agents, scripts, tests, and docs. Check the bare dotfiles repository state. Before asking what to change, print a concise current structure:

```text
NOVA // WORKFLOW

Mission:
Lifecycle:
Product commands:
Feature commands:
Inbox command:
Navigation commands:
Administration command:
Artifact authority:
Core safeguards:
Installed commands/skills/agents/scripts:
Validation health:
Known inconsistencies:
```

Then offer helpful operations: explain a phase, audit a problem, design or audit NOVA's personality, add/update/rename/reorganize/deprecate/remove a command, change an artifact or transition, improve efficiency/token use, or review the full workflow. Ask focused questions appropriate to the chosen operation.

## Senior Review

For every proposed change, assess user intent, entry/exit state, reads/writes, ownership, overlap, approval, failure/recovery, deterministic alternatives, token cost, naming, portability, migration, and all connected assets. Be opinionated and challenge changes that make NOVA less efficient, reliable, clear, or truthful. Give evidence and alternatives; the user decides.

## Apply

The scoped bare dotfiles worktree was verified clean during preflight. Recheck it immediately before the first edit; if it changed, use the same pause-and-reverify behavior. Do not edit before showing the complete cross-workflow plan and receiving approval. Update the authoritative workflow contract first, then affected commands, skills, agents, scripts, tests, READMEs, and dotfiles context/reference together. Validate OpenCode discovery/config, skill metadata, scripts, links, command-map consistency, and the bare-repo diff.

Suggest a scoped commit message and ask before staging or committing.
