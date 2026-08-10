# NOVA Artifacts

## Standard Layout

```text
.ai-nova/
  README.md
  INBOX.md
  PRODUCT-INPUT.md        # optional
  product-spec.md         # created by product-spec-create
  product-changes/
    .gitkeep
    PCR-001-short-name.md
    PHR-F001.md
  features/
    .gitkeep
    F001-short-name/
      T00-spec.md
      T01-task-name.md
```

Canonical file templates live under `~/.config/ai/workflows/nova/templates/`. Commands preserve their schemas and omit only sections that are explicitly inapplicable.

## Inbox Template

```markdown
# Product Name Inbox

## User Input

<!-- Add plain text or bullets. NOVA removes an entry only after safe routing. -->

<!-- ========================================================== -->
<!-- NOVA-MANAGED AREA: ONLY NOVA MAY EDIT BELOW THIS LINE       -->
<!-- ========================================================== -->

## Deferred
```

The user writes only under `User Input`. NOVA does not rewrite raw wording and removes an item only after its destination is durable. Every deferred item has a reason and lifecycle review trigger.

## Product Dashboard

```text
ID | Feature | Status | Depends on | Spec | Blocker
```

Dependencies are `None` or canonical IDs separated by comma-space. Authoritative table cells do not contain Markdown pipe characters, including escaped pipes.

## Feature Task Table

```text
ID | Task | Status | Depends on | Review | File
```

Dependencies and multiple review profiles use comma-space separators. Task IDs are `T01` through `T99`; `T00` is reserved for the feature spec.

## Product Change Request

Records origin, evidence, current rule, proposed update, dependency edges, direct and transitive effects, completed work at risk, delivery impact, options, recommendation, approval, and application result.

`Blocks` is `None` or a comma-separated feature-ID list. A blocking request records an exact unblock condition.

States: `Proposed -> Approved -> Applied`, with terminal alternatives `Rejected` and `Withdrawn`.

## Feature Validation Results

Acceptance items use stable `ANN` IDs. The validation table records the latest attempt date, tested commit, and one `PASS`, `FAIL`, `MANUAL_VERIFY`, `UNVERIFIABLE`, or `Accepted Exception` result with evidence per acceptance ID. Before replacing a prior attempt, append its concise result/blocker summary to change history. `Not Run` is valid only before the first attempt. Exception evidence includes `Approved by user:`.

## Task Execution Metadata

Task files use `Dependencies:` and `Profiles:` metadata matching the authoritative task row. They record the starting commit and branch before mutation. Approved WIP recovery records `WIP marker: This commit` and an unblock condition in the approved WIP commit; resume requires a clean tree at that marked branch tip. A `Superseded` or `Accepted Exception` row has a substantive `- TNN:` entry with explicit user approval in feature change/exception history, including when `File` is `None`.

## Product Handoff Request

Records a validated feature's evidence, limitations, accepted exceptions, dependency observations, and readiness implications. Each section contains substantive content or explicit `None`; blank template sections do not satisfy the handoff. It is routine progress, not a Product Change Request.

## Product Input

`PRODUCT-INPUT.md` is optional source material. Legacy completion is `Reported, unverified`. After approved product creation it is marked `Status: Consumed`, links `product-spec.md`, and may be removed after the user is asked.
