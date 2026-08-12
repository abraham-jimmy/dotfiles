#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
nova_dir=$(cd -- "$script_dir/.." && pwd)
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT

git -C "$fixture" init -q
mkdir -p "$fixture/.ai-nova/product-changes" "$fixture/.ai-nova/features/F001-example"
touch "$fixture/.ai-nova/product-changes/.gitkeep" "$fixture/.ai-nova/features/.gitkeep"

cat > "$fixture/.ai-nova/README.md" <<'EOF'
# NOVA Project

Workflow: NOVA
Workflow version: 1

## Authority

- `product-spec.md`: product source
- `features/*/T00-spec.md`: feature source
- `INBOX.md`: capture
- `product-changes/`: requests
EOF

cat > "$fixture/.ai-nova/INBOX.md" <<'EOF'
# Example Inbox

## User Input

- Revisit the example behavior.

<!-- ========================================================== -->
<!-- NOVA-MANAGED AREA: ONLY NOVA MAY EDIT BELOW THIS LINE       -->
<!-- ========================================================== -->

## Deferred
EOF

cat > "$fixture/.ai-nova/product-spec.md" <<'EOF'
# Example Product

Status: Active

## Outcome

## Users And Workflows

## Scope

## Constraints

## Exclusions

## Accepted Limitations

## Product Decisions

## Feature Dashboard

| ID | Feature | Status | Depends on | Spec | Blocker |
| --- | --- | --- | --- | --- | --- |
| F001 | Example | Selected | None | .ai-nova/features/F001-example/T00-spec.md | |

## Product Acceptance

- [ ] Product outcome is verified.

## Decision And Change History
EOF

cat > "$fixture/.ai-nova/product-changes/PCR-001-example.md" <<'EOF'
# PCR-001: Example

Status: Proposed
Originating feature: F001
Originating task: None
Blocks: None
Unblock condition: None

## Trigger And Evidence

## Current Product Rule

## Proposed Product Update

## Dependency Edges

## Directly Affected Features

## Transitively Affected Features

## Completed Work At Risk

## Delivery Impact

## Options And Recommendation

## User Decision

Pending.

## Application Result

Not applied.
EOF

cat > "$fixture/.ai-nova/features/F001-example/T00-spec.md" <<'EOF'
# Example Feature

Status: Approved
Product feature: F001

## Why

## Shippable Outcome

## Context

## Decisions

## Constraints

## Exclusions

## Task Table

| ID | Task | Status | Depends on | Review | File |
| --- | --- | --- | --- | --- | --- |
| T01 | Example task | Planned | None | self | T01-example.md |

## Acceptance

- [ ] A01: Feature outcome is verified.

## Validation Results

Validation attempt: Not run
Tested commit: Not run

| Acceptance | Result | Evidence |
| --- | --- | --- |
| A01 | Not Run | Pending validation. |

## Change And Exception History
EOF

check_output=$("$nova_dir/scripts/nova-project-check.sh" "$fixture")
[[ "$check_output" == *'[RESULT] Valid - 0 failure(s) / 0 warning(s)'* ]]
[[ "$check_output" != *'[PASS]'* ]]
[[ "$check_output" != *$'\033['* ]]

verbose_output=$("$nova_dir/scripts/nova-project-check.sh" --verbose "$fixture")
[[ "$verbose_output" == *'[PASS] .ai-nova/ exists'* ]]
[[ "$verbose_output" == *'[RESULT] Valid - 0 failure(s) / 0 warning(s)'* ]]

verbose_after_root=$("$nova_dir/scripts/nova-project-check.sh" "$fixture" --verbose)
[[ "$verbose_after_root" == *'[PASS] .ai-nova/ exists'* ]]

status_output=$("$nova_dir/scripts/nova-status.sh" "$fixture")
[[ "$status_output" == *'NOVA // STATUS'* ]]
[[ "$status_output" == *'Product     Active'* ]]
[[ "$status_output" == *'Inbox       new present / deferred none'* ]]
[[ "$status_output" == *'Features    1 total / 1 active / 0 blocked / 0 completed'* ]]
[[ "$status_output" == *'Requests    1 proposed / 0 approved / 0 applied / 0 closed / 0 handoff pending'* ]]
[[ "$status_output" == *'[RESULT] Status collected with warnings.'* ]]
[[ "$status_output" != *$'\033['* ]]

"$nova_dir/scripts/nova-status.sh" "$fixture/.ai-nova" >/dev/null

expect_check_failure() {
	local output status
	set +e
	output=$("$nova_dir/scripts/nova-project-check.sh" "$fixture" 2>&1)
	status=$?
	set -e
	if (( status != 1 )) || [[ "$output" != *'[FAIL] '* ]]; then
		printf 'Expected validation exit 1 with a FAIL diagnostic: %s (got %d)\n' "$1" "$status" >&2
		exit 1
	fi
}

spec="$fixture/.ai-nova/features/F001-example/T00-spec.md"
product="$fixture/.ai-nova/product-spec.md"
request="$fixture/.ai-nova/product-changes/PCR-001-example.md"
cp "$spec" "$fixture/spec.backup"
cp "$product" "$fixture/product.backup"
cp "$request" "$fixture/request.backup"

perl -0pi -e 's/\| T01 \| Example task \| Planned \|/| T01 | Example task | Ready |/' "$spec"
expect_check_failure 'Ready task without a materialized file'
cp "$fixture/spec.backup" "$spec"

perl -0pi -e 's/\| T01 \| Example task \|/| T1 | Example task |/' "$spec"
expect_check_failure 'malformed task table ID'
cp "$fixture/spec.backup" "$spec"

perl -0pi -e 's/\| Planned \| None \| self \|/| Planned | None typo | self |/' "$spec"
expect_check_failure 'malformed whole-cell dependency list'
cp "$fixture/spec.backup" "$spec"

perl -0pi -e 's/\| Planned \| None \| self \|/| Planned | None | unknown-review |/' "$spec"
expect_check_failure 'unknown review profile'
cp "$fixture/spec.backup" "$spec"

perl -0pi -e 's/Status: Approved/Status: Completed/' "$spec"
expect_check_failure 'completed feature with unresolved acceptance and nonterminal tasks'
cp "$fixture/spec.backup" "$spec"

perl -0pi -e 's/Status: Active/Status: Completed/' "$product"
expect_check_failure 'completed product with selected work and unchecked acceptance'
cp "$fixture/product.backup" "$product"

perl -0pi -e 's/Status: Proposed/Status: Applied/' "$request"
expect_check_failure 'applied request with placeholder decision and result'
cp "$fixture/request.backup" "$request"

ln -s /etc/passwd "$fixture/.ai-nova/PRODUCT-INPUT.md"
expect_check_failure 'symlinked product input'
rm "$fixture/.ai-nova/PRODUCT-INPUT.md"

cp "$fixture/.ai-nova/INBOX.md" "$fixture/inbox.backup"
perl -0pi -e 's/## Deferred/## User Input\n\n## Deferred/' "$fixture/.ai-nova/INBOX.md"
expect_check_failure 'duplicate inbox ownership section'
cp "$fixture/inbox.backup" "$fixture/.ai-nova/INBOX.md"

perl -0pi -e 's/- Revisit the example behavior\./- Revisit the example behavior. <!-- note -->/' "$fixture/.ai-nova/INBOX.md"
status_output=$("$nova_dir/scripts/nova-status.sh" "$fixture")
[[ "$status_output" == *'Inbox       new present / deferred none'* ]]
cp "$fixture/inbox.backup" "$fixture/.ai-nova/INBOX.md"

if "$nova_dir/scripts/nova-status.sh" "$fixture" extra >/dev/null 2>&1; then
	printf 'Expected extra status arguments to fail\n' >&2
	exit 1
fi

cat > "$fixture/.ai-nova/features/F001-example/T00-spec.md" <<'EOF'
# Example Feature

Status: Approved
Product feature: F001

## Why

## Shippable Outcome

## Context

## Decisions

## Constraints

## Exclusions

## Task Table

| ID | Task | Status | Depends on | Review | File |
| --- | --- | --- | --- | --- | --- |
| T01 | Example task | Planned | T02 | self | T01-example.md |
| T02 | Cycle task | Planned | T01 | self | T02-cycle.md |

## Acceptance

- [ ] A01: Feature outcome is verified.

## Validation Results

Validation attempt: Not run
Tested commit: Not run

| Acceptance | Result | Evidence |
| --- | --- | --- |
| A01 | Not Run | Pending validation. |

## Change And Exception History
EOF
cat > "$fixture/.ai-nova/features/F001-example/T01-example.md" <<'EOF'
# T01: Example Task

## Outcome

## Depends On

Dependencies: T02

## Do

## Files

## Relevant Context

## Verify

## Review Profile

Profiles: self

## Execution

Baseline: Not started
Branch: Not started
WIP marker: None
WIP unblock condition: None

## Outcome Evidence
EOF
cat > "$fixture/.ai-nova/features/F001-example/T02-cycle.md" <<'EOF'
# T02: Cycle Task

## Outcome

## Depends On

Dependencies: T01

## Do

## Files

## Relevant Context

## Verify

## Review Profile

Profiles: self

## Execution

Baseline: Not started
Branch: Not started
WIP marker: None
WIP unblock condition: None

## Outcome Evidence
EOF

expect_check_failure 'task dependency cycle'

printf 'NOVA script tests passed\n'
