# NOVA State Transitions

## Product

`Active -> Completed`

Product changes may add explicit `Blocked`, `Deferred`, or `Cancelled` states after approval. `Blocked` and `Deferred` return to `Active` after approved resolution; `Completed` and `Cancelled` are terminal.

Product dashboard rows use `Proposed -> Ready -> Selected -> Completed`, with `Blocked`, `Deferred`, and `Cancelled` side states. The dashboard is a product-level readiness snapshot updated only by the product steward; the feature spec owns operational execution status.

Dashboard `Blocked` and `Deferred` rows return to `Proposed` or `Ready` after approved resolution and dependency recalculation. `Completed` and `Cancelled` rows are terminal.

## Feature

`Draft -> Approved -> In Progress -> Validating -> Completed`

Allowed side states: `Blocked`, `Deferred`, `Cancelled`. `Blocked` and `Deferred` return to `Approved` when execution has not started or `In Progress` when it has, after the user approves the resolution or resume condition. `Completed` and `Cancelled` are terminal; changed direction creates a new feature or product change without reopening history. A completed feature remains at a stable path.

Failed or incomplete validation remains `Validating`; an approved feature update may return `Validating -> In Progress` for remediation.

## Task

`Planned -> Ready -> In Progress -> Completed`

Allowed side states: `Blocked`, `Needs Change`, `Impacted`, `Superseded`, `Deferred`, `Accepted Exception`.

Materialization changes dependency-satisfied `Planned` rows to `Ready`. Task completion and replanning recalculate readiness. `Blocked`, `Needs Change`, and `Impacted` return to `Ready` after an approved resolution. `Superseded` and `Accepted Exception` are terminal only with recorded rationale; `Deferred` is nonterminal and prevents feature completion.

`Completed`, `Superseded`, and `Accepted Exception` satisfy task dependency edges.

Feature validation accepts only `Completed`, `Superseded`, and `Accepted Exception` task rows. A pre-materialization terminal row may use `File: None` when its rationale is recorded in feature history.

Completed task history is immutable. Changed requirements create new task rows or mark prior outcomes impacted/superseded.

## Inbox

`User Input -> Evaluated -> Routed`

Routing destinations are task clarification, feature update, Product Change Request, proposed feature, deferred with trigger, or rejected with rationale when material.

Material rejections are recorded in the relevant product/feature decision history. Trivial rejected input may be removed without another artifact only after explicit user confirmation.

Timing classifications are `Now`, `Before next task`, `Later`, and `Needs clarification`. NOVA recommends interruption; the user decides. Declining a pause remains advisory and records accepted rework risk.

## Validation

Conditions are `PASS`, `FAIL`, `MANUAL_VERIFY`, `UNVERIFIABLE`, or `Accepted Exception`. Accepted exceptions are never displayed as passes and require user approval plus accurate contract handling.

## Product Handoff

A validated feature cannot lead to the next feature spec until the mandatory product update records completion, dependencies, limitations, and readiness.

## Product Requests

Product Change Requests use `Proposed -> Approved -> Applied`, or `Rejected`/`Withdrawn`. Product Handoff Requests use `Pending -> Applied`.

An unresolved Product Change Request is blocking exactly when its `Blocks` field names the affected feature. Naming a feature is a complete execution stop for that feature while the request is `Proposed` or `Approved`; independent work on features not named in `Blocks` may proceed. The request itself is the durable gate while product and feature owners reconcile their separate statuses in approved commits, so temporary cross-owner status mismatch is valid. After `Applied`, `Rejected`, or `Withdrawn`, both statuses are reconciled before work resumes: applied decisions update the contract, while rejected/withdrawn decisions discard dependent assumptions and retain the current product rule.
