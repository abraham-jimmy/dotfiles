---
description: Validate a completed feature spec
agent: build
---

# Validate Spec

Validate the end-to-end `## Done` conditions for a completed feature without implementing or fixing anything, then optionally record the completion in a higher-level spec with the user's approval.

## Input

$ARGUMENTS: optional `.ai/<feature-slug>/T00-spec.md` or feature folder

If a spec path is provided, validate that spec.
If a feature folder is provided, validate its `T00-spec.md`.
If no argument is provided, resolve the Git root, search only under `<git-root>/.ai/` for unfinished feature folders containing `T00-spec.md`, and ask the user to choose if there is not exactly one candidate.

## Scope

- Verification only
- Do not implement missing behavior
- Do not fix failures
- Do not add or update tests to make a condition pass
- Do not install dependencies or change configuration
- Do not modify product source files
- The only allowed content edits are checkbox states in the spec's `## Done` section and a user-approved progress update in a higher-level spec
- The only allowed rename is the final feature-folder rename described below

## Process

1. Resolve the feature folder and its `T00-spec.md`
2. Refuse to continue if the folder name already ends in `-DONE`; report that it is already marked complete
3. Read the spec's `Task Index` and `Done` sections
4. For every task number in `Task Index`, confirm exactly one matching `TNN-*-DONE.md` file exists in the feature folder
5. Read each completed task's `## Completed State` and confirm it says `Status: Completed`
6. If any indexed task is missing, incomplete, duplicated, or lacks its `-DONE.md` suffix, report it and do not rename the feature folder
7. Extract every checklist item from the spec's `## Done` section
8. Revalidate every item in order, including items already checked; never trust an existing `[x]` as evidence
9. Run an explicitly named command when the condition specifies one
10. For behavioral, test-coverage, configuration, or deployment conditions, inspect the relevant implementation and use available verification tools when that can prove the condition
11. Tag a condition as `MANUAL_VERIFY` when it explicitly requires manual verification or requires human observation or judgment that available tools cannot replace
12. For each `MANUAL_VERIFY` condition, provide exact verification steps and ask the user to perform them and report the result
13. Change `MANUAL_VERIFY` to `PASS` only after the user explicitly confirms the complete condition during this validation; change it to `FAIL` if the user reports that any part failed
14. Classify every condition as `PASS`, `FAIL`, `MANUAL_VERIFY`, or `UNVERIFIABLE`
15. Record concise evidence and an explicit explanation for every result
16. Set a condition to `[x]` only when it is `PASS`
17. Leave a failed, pending-manual, or unverifiable condition unchecked; if it was previously checked, change it back to `[ ]`
18. Do not substitute a related check for the condition actually written in the spec

## Higher-Level Spec Progress

Only after the completion gate passes and the feature folder is renamed:

1. Search ancestor directories, stopping at the Git root, for a higher-level main spec that explicitly references or tracks this feature, its spec, or its feature folder
2. Do not treat an unrelated ancestor Markdown file as a main spec
3. If more than one plausible main spec exists, ask the user which one applies; do not choose silently
4. Inspect how the selected main spec already records progress, such as existing checkboxes, numbered steps, status fields, or completed-work entries
5. Show the user the selected main spec and the exact proposed progress update, then ask for explicit confirmation before editing it
6. After confirmation, use the main spec's existing progress convention: for example, check its existing feature checkbox or add a concise completed step where completed steps are already recorded
7. Do not invent a new progress format or section; if the existing handling is unclear, ask the user what update to make
8. If the user declines or has not confirmed, do not modify the higher-level spec
9. Do not alter requirements, scope, design decisions, or unrelated progress while recording completion

Absence of a higher-level main spec, or the user's decision not to update one, does not undo the completed feature validation or folder rename.

## Result Rules

Use these classifications consistently:

- `PASS`: direct evidence proves the complete condition
- `FAIL`: direct evidence shows that any part of the condition is not fulfilled
- `MANUAL_VERIFY`: final validation requires fresh human observation, judgment, or interaction and is awaiting explicit user confirmation
- `UNVERIFIABLE`: available tools, access, environment, or evidence cannot prove the complete condition

Format the manual status as the visible tag `[MANUAL_VERIFY]` in the report.

When a condition contains multiple requirements, all of them must be proven for `PASS`. If it requires pending human confirmation, use `MANUAL_VERIFY`; if evidence or access is unavailable for a non-manual condition, use `UNVERIFIABLE`; if any part is disproven, use `FAIL`.

For `FAIL`, state exactly what was expected, what was observed, and which part is not fulfilled.
For `MANUAL_VERIFY`, give exact steps, expected results, and the specific confirmation needed from the user. A pre-existing `[x]`, prior task report, screenshot, or assumption is not fresh manual confirmation.
For `UNVERIFIABLE`, state exactly why it cannot be verified and what evidence or access would be needed.
Never describe `MANUAL_VERIFY` or `UNVERIFIABLE` as passed, assumed, likely, or complete.

## Completion Gate

Rename the feature folder from `.ai/<feature-slug>/` to `.ai/<feature-slug>-DONE/` only when all of these are true:

- Every `Task Index` entry has exactly one matching `TNN-*-DONE.md` file
- Every matching task says `Status: Completed`
- Every `## Done` checklist item was revalidated as `PASS`
- Every `## Done` checkbox is `[x]`
- No check is `FAIL`, `MANUAL_VERIFY`, or `UNVERIFIABLE`
- The destination folder does not already exist

Do not rename the folder when any completion-gate condition is unmet. Do not append `.md` to the directory name.

## Report

Report each done condition separately with:

- Status: `PASS`, `FAIL`, `[MANUAL_VERIFY]`, or `UNVERIFIABLE`
- Condition
- Evidence gathered
- Explanation, especially for failures, pending manual verification, or unverifiable conditions

Then report:

- Task completion check
- Total passed, failed, pending-manual, and unverifiable conditions
- Whether spec checkboxes changed
- Whether the feature folder was renamed
- Final feature folder path
- Whether a higher-level main spec was found, confirmed by the user, and updated
- Every blocker preventing completion
- Suggested commit message covering the validation metadata changes

Do not offer to fix blockers in this session. If validation is incomplete, tell the user to address the reported blockers in a separate session and rerun `validate-spec` afterward.

End every report with `Suggested commit message:`. If validation produced no committable changes, use `Suggested commit message: None (validation made no changes).` Do not create the commit unless the user explicitly asks.
