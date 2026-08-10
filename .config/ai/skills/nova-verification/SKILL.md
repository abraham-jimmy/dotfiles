---
name: nova-verification
description: Classifies NOVA verification evidence and validates completed feature contracts. Use for task checks, manual confirmation, accepted exceptions, or final feature validation.
---

# NOVA Verification

Use these classifications:

- `PASS`: direct evidence proves the complete condition
- `FAIL`: evidence disproves any required part
- `MANUAL_VERIFY`: fresh human observation or judgment is required
- `UNVERIFIABLE`: access, tools, environment, or evidence is insufficient
- `Accepted Exception`: the user knowingly waives a finding or updates the contract; never display it as a pass

Revalidate existing checks; do not trust prior checkmarks. Compound conditions pass only when every part is proven. Run named commands and inspect targeted implementation when needed.

Feature acceptance uses stable `ANN` IDs. The validation table records the latest attempt date, tested commit, and one classification plus concise evidence per ID in `T00-spec.md`; append a concise prior-attempt summary to change history before replacing it. `Not Run` is a pre-validation placeholder only. A completed feature contains only `PASS` or explicitly approved `Accepted Exception` results, real evidence, a resolvable tested commit, and no unchecked acceptance item. Exception evidence includes `Approved by user:`.

For manual verification, provide exact steps, expected results, and requested confirmation. UI and design conditions always require human confirmation.

Feature completion requires every authoritative task to be `Completed`, `Superseded`, or `Accepted Exception`, all current acceptance criteria handled truthfully, no unresolved blocking Product Change Request, and recorded evidence. A terminal row without a task file is valid only when `File` is `None` and feature history records why it was superseded or excepted before materialization. Stable paths remain unchanged.
