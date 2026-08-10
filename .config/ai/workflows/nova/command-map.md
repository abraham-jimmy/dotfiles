# NOVA Command Map

## Project Structure

- `/nova-project-setup`: initialize, audit, reconcile, upgrade, or adopt legacy documentation into `PRODUCT-INPUT.md`.

## Product

- `/nova-product-spec-create`: create the first approved product spec.
- `/nova-product-spec-update`: exclusively apply approved product changes, progress, and dependency propagation.

## Feature

- `/nova-feature-spec-create`: define the next user-selected dependency-ready feature.
- `/nova-feature-spec-update`: evaluate and integrate a changed feature contract.
- `/nova-feature-spec-to-tasks`: materialize approved task-table rows in a fresh session.
- `/nova-feature-task-execute`: execute one dependency-ready task.
- `/nova-feature-spec-validate`: independently validate feature acceptance.

## Intake

- `/nova-inbox-process`: process every new and currently due deferred idea.

## Navigation

- `/nova-project-status`: report documentation, Git, lifecycle, inbox, request, and structural state without modifying anything.
- `/nova-suggest-next-action`: explain one recommended next command without modifying anything.

## Administration

- `/nova-workflow-update`: maintain NOVA's own authoritative workflow, voice, and command system.

## Required Handoffs

```text
product-spec-create
  -> feature-spec-create
  -> feature-spec-to-tasks
  -> feature-task-execute (repeat)
  -> feature-spec-validate
  -> product-spec-update
  -> feature-spec-create (repeat)
```

Inbox processing may interrupt at defined checkpoints. Product-impacting work routes through a Product Change Request and the product steward.
