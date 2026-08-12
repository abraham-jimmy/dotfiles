#!/usr/bin/env bash

set -euo pipefail

if [[ -t 1 && -t 2 && -z ${NO_COLOR:-} ]]; then
	color_red=$'\033[31m'
	color_green=$'\033[32m'
	color_yellow=$'\033[33m'
	color_reset=$'\033[0m'
else
	color_red=''
	color_green=''
	color_yellow=''
	color_reset=''
fi

if (( BASH_VERSINFO[0] < 4 )); then
	printf '%s[ERROR]%s nova-project-check.sh requires Bash 4 or newer\n' "$color_red" "$color_reset" >&2
	exit 2
fi

verbose=0
requested_root='.'
root_set=0
while (( $# )); do
	case $1 in
		--verbose) verbose=1 ;;
		-h|--help)
			printf 'Usage: nova-project-check.sh [--verbose] [project-root]\n'
			exit 0
			;;
		-*)
			printf '%s[ERROR]%s Unknown option: %s\n' "$color_red" "$color_reset" "$1" >&2
			exit 2
			;;
		*)
			if (( root_set )); then
				printf '%s[ERROR]%s Usage: nova-project-check.sh [--verbose] [project-root]\n' "$color_red" "$color_reset" >&2
				exit 2
			fi
			requested_root=$1
			root_set=1
			;;
	esac
	shift
done

root=$(git -C "$requested_root" rev-parse --show-toplevel 2>/dev/null) || {
	printf '%s[ERROR]%s Not inside a Git repository: %s\n' "$color_red" "$color_reset" "$requested_root" >&2
	exit 2
}

nova="$root/.ai-nova"
errors=0
warnings=0

pass() { (( verbose )) && printf '%s[PASS]%s %s\n' "$color_green" "$color_reset" "$1"; return 0; }
warn() { printf '%s[WARN]%s %s\n' "$color_yellow" "$color_reset" "$1"; warnings=$((warnings + 1)); }
fail() { printf '%s[FAIL]%s %s\n' "$color_red" "$color_reset" "$1"; errors=$((errors + 1)); }
print_result() {
	local color=$color_green state='Valid'
	if (( errors > 0 )); then color=$color_red; state='Invalid'
	elif (( warnings > 0 )); then color=$color_yellow; state='Valid with warnings'
	fi
	printf '\n%s[RESULT]%s %s - %d failure(s) / %d warning(s)\n' "$color" "$color_reset" "$state" "$errors" "$warnings"
}
value_of() { awk -v key="$2" 'index($0, key) == 1 { sub("^" key "[[:space:]]*", ""); sub(/\r$/, ""); print; exit }' "$1"; }
status_of() { value_of "$1" 'Status:'; }
has_line() { awk -v wanted="$2" '{ sub(/\r$/, "") } $0 == wanted { found=1 } END { exit !found }' "$1"; }
require_heading() {
	local count
	count=$(awk -v wanted="## $2" '{ sub(/\r$/, "") } $0 == wanted { count++ } END { print count+0 }' "$1")
	(( count == 1 )) || fail "${1#"$root"/} must contain exactly one ## $2 heading"
}
require_single_key() {
	local count
	count=$(awk -v key="$2" 'index($0, key) == 1 { count++ } END { print count+0 }' "$1")
	(( count == 1 )) || fail "${1#"$root"/} must contain exactly one $2 field"
}
has_unchecked() {
	awk -v wanted="## $2" '
		{ sub(/\r$/, "") }
		$0 == wanted { section=1; next }
		section && /^## / { exit }
		section && /^[-*+] \[ \] / { found=1 }
		END { exit !found }
	' "$1"
}
section_value() {
	awk -v wanted="## $2" '
		{ sub(/\r$/, "") }
		$0 == wanted { section=1; next }
		section && /^## / { exit }
		section && $0 !~ /^[[:space:]]*$/ { print; exit }
	' "$1"
}
section_matches() {
	awk -v wanted="## $2" -v pattern="$3" '
		{ sub(/\r$/, "") }
		$0 == wanted { section=1; next }
		section && /^## / { exit }
		section && $0 ~ pattern { found=1 }
		END { exit !found }
	' "$1"
}
section_has_line() {
	awk -v heading="## $2" -v wanted="$3" '
		{ sub(/\r$/, "") }
		$0 == heading { section=1; next }
		section && /^## / { exit }
		section && $0 == wanted { found++ }
		END { exit !(found == 1) }
	' "$1"
}
review_valid() {
	local item rest=$1 count=0
	while :; do
		item=${rest%%,*}
		item=${item#"${item%%[![:space:]]*}"}
		item=${item%"${item##*[![:space:]]}"}
		case "$item" in self|correctness|security|data|performance|manual-ui|design-decision) ;; *) return 1 ;; esac
		count=$((count + 1))
		[[ "$rest" == *,* ]] || break
		rest=${rest#*,}
	done
	(( count > 0 ))
}
has_checklist() {
	awk -v wanted="## $2" '
		{ sub(/\r$/, "") }
		$0 == wanted { section=1; next }
		section && /^## / { exit }
		section && /^[-*+] \[[ xX]\] / { found=1 }
		END { exit !found }
	' "$1"
}

printf 'NOVA // STRUCTURE CHECK\n'
printf 'Repository  %s\n\n' "$root"

if [[ -L "$nova" ]]; then
	fail '.ai-nova/ must not be a symlink'
	print_result
	exit 1
elif [[ ! -d "$nova" ]]; then
	fail '.ai-nova/ is missing'
	[[ -d "$root/.ai" ]] && warn 'legacy .ai/ exists'
	print_result
	exit 1
fi

pass '.ai-nova/ exists'

for path in README.md INBOX.md; do
	if [[ -L "$nova/$path" ]]; then fail ".ai-nova/$path must not be a symlink"
	elif [[ -f "$nova/$path" ]]; then pass ".ai-nova/$path exists"
	else fail ".ai-nova/$path is missing"
	fi
done

for path in product-changes features; do
	if [[ -L "$nova/$path" ]]; then fail ".ai-nova/$path/ must not be a symlink"
	elif [[ -d "$nova/$path" ]]; then pass ".ai-nova/$path/ exists"
	else fail ".ai-nova/$path/ is missing"
	fi
	if [[ -f "$nova/$path/.gitkeep" ]]; then pass ".ai-nova/$path/.gitkeep exists"; else warn ".ai-nova/$path/.gitkeep is missing"; fi
done

if [[ -f "$nova/README.md" && ! -L "$nova/README.md" ]]; then
	if has_line "$nova/README.md" 'Workflow: NOVA'; then pass 'README.md identifies NOVA'; else fail 'README.md lacks Workflow: NOVA'; fi
	require_single_key "$nova/README.md" 'Workflow version:'
	workflow_version=$(value_of "$nova/README.md" 'Workflow version:')
	case "$workflow_version" in
		1) pass 'README.md uses supported workflow version 1' ;;
		''|*[!0-9]*) fail 'README.md lacks a valid workflow version' ;;
		*) fail "unsupported NOVA workflow version: $workflow_version" ;;
	esac
	require_heading "$nova/README.md" Authority
	for reference in "\`product-spec.md\`" "\`features/*/T00-spec.md\`" "\`INBOX.md\`" "\`product-changes/\`"; do
		grep -Fq -- "$reference" "$nova/README.md" || fail "README.md authority lacks $reference"
	done
fi

if [[ -f "$nova/INBOX.md" && ! -L "$nova/INBOX.md" ]]; then
	if awk '
		{ sub(/\r$/, "") }
		$0 == "## User Input" { user++; user_line=NR }
		/^<!-- NOVA-MANAGED AREA: ONLY NOVA MAY EDIT BELOW THIS LINE +-->$/ { divider++; divider_line=NR }
		$0 == "## Deferred" { deferred++; deferred_line=NR }
		END { exit !(user == 1 && divider == 1 && deferred == 1 && user_line < divider_line && divider_line < deferred_line) }
	' "$nova/INBOX.md"; then
		pass 'INBOX.md has one ordered ownership boundary'
	else
		fail 'INBOX.md must contain one ordered User Input, NOVA divider, and Deferred section'
	fi
fi

if [[ -L "$nova/PRODUCT-INPUT.md" ]]; then
	fail '.ai-nova/PRODUCT-INPUT.md must not be a symlink'
elif [[ -f "$nova/PRODUCT-INPUT.md" ]]; then
	require_single_key "$nova/PRODUCT-INPUT.md" 'Status:'
	require_single_key "$nova/PRODUCT-INPUT.md" 'Source:'
	require_single_key "$nova/PRODUCT-INPUT.md" 'Consumed by:'
	input_status=$(status_of "$nova/PRODUCT-INPUT.md")
	case "$input_status" in Unconsumed|Consumed) ;; *) fail "invalid PRODUCT-INPUT.md status: ${input_status:-missing}" ;; esac
	for heading in 'Existing Product Intent' 'Existing Features' 'Existing Decisions' 'Existing Constraints' 'Existing Dependencies' 'Reported Completed Work' 'Incomplete Work' 'Captured Ideas' 'Contradictions And Ambiguity' 'Missing Product Context' 'Source Inventory'; do require_heading "$nova/PRODUCT-INPUT.md" "$heading"; done
	if [[ "$input_status" == "Consumed" ]]; then
		[[ $(value_of "$nova/PRODUCT-INPUT.md" 'Consumed by:') == '.ai-nova/product-spec.md' ]] || fail 'Consumed PRODUCT-INPUT.md must link .ai-nova/product-spec.md'
	elif [[ $(value_of "$nova/PRODUCT-INPUT.md" 'Consumed by:') != 'Not consumed' ]]; then
		fail 'Unconsumed PRODUCT-INPUT.md must use Consumed by: Not consumed'
	fi
fi

shopt -s nullglob
existing_features=("$nova/features"/F*)
existing_requests=("$nova/product-changes"/*.md)
shopt -u nullglob
if [[ ! -f "$nova/product-spec.md" ]] && (( ${#existing_features[@]} > 0 || ${#existing_requests[@]} > 0 )); then
	fail 'product-spec.md is required when feature or product-request artifacts exist'
fi
unset existing_features existing_requests

declare -A product_rows=() product_deps=() product_specs=()
if [[ -L "$nova/product-spec.md" ]]; then
	fail '.ai-nova/product-spec.md must not be a symlink'
elif [[ -f "$nova/product-spec.md" ]]; then
	require_single_key "$nova/product-spec.md" 'Status:'
	product_status=$(status_of "$nova/product-spec.md")
	case "$product_status" in
		Active|Completed|Blocked|Deferred|Cancelled) pass "product status is $product_status" ;;
		*) fail "invalid product status: ${product_status:-missing}" ;;
	esac
	for heading in Outcome 'Users And Workflows' Scope Constraints Exclusions 'Accepted Limitations' 'Product Decisions' 'Feature Dashboard' 'Product Acceptance' 'Decision And Change History'; do
		require_heading "$nova/product-spec.md" "$heading"
	done
	has_checklist "$nova/product-spec.md" 'Product Acceptance' || fail 'product-spec.md has no product acceptance conditions'
	section_has_line "$nova/product-spec.md" 'Feature Dashboard' '| ID | Feature | Status | Depends on | Spec | Blocker |' || fail 'product-spec.md has an invalid local feature dashboard header'
	section_has_line "$nova/product-spec.md" 'Feature Dashboard' '| --- | --- | --- | --- | --- | --- |' || fail 'product-spec.md has an invalid feature dashboard separator'
	while IFS=$'\t' read -r record id dashboard_status dependency spec_path; do
		if [[ "$record" == "ERROR" ]]; then fail "malformed product dashboard row at line $id"; continue; fi
		[[ -n "$id" ]] || continue
		if [[ -n ${product_rows[$id]+x} ]]; then
			fail "duplicate product feature row $id"
			continue
		fi
		product_rows[$id]=$dashboard_status
		product_deps[$id]=$dependency
		product_specs[$id]=$spec_path
		case "$dashboard_status" in Proposed|Ready|Selected|Blocked|Completed|Deferred|Cancelled) ;; *) fail "invalid product feature status $dashboard_status for $id" ;; esac
		if [[ ! "$spec_path" =~ ^\.ai-nova/features/(F[0-9]{3})-[a-z0-9]+(-[a-z0-9]+)*/T00-spec\.md$ ]]; then
			fail "invalid feature spec path for $id: $spec_path"
		elif [[ "${BASH_REMATCH[1]}" != "$id" ]]; then
			fail "product feature $id points to a different feature ID: $spec_path"
		elif [[ "$dashboard_status" == "Completed" && ! -f "$root/$spec_path" ]]; then
			fail "completed product feature $id lacks $spec_path"
		fi
		if [[ ! "$dependency" =~ ^(None|F[0-9]{3}(,\ F[0-9]{3})*)$ ]]; then fail "invalid product dependency list for $id: $dependency"; fi
	done < <(awk '
		{ sub(/\r$/, "") }
		$0 == "## Feature Dashboard" { section=1; next }
		section && /^## / { exit }
		!section || /^[[:space:]]*$/ || $0 == "| ID | Feature | Status | Depends on | Spec | Blocker |" || $0 ~ /^\| -+ \|/ { next }
		{
			count=split($0, cell, "|")
			if ($0 !~ /^\|/ || count != 8) { print "ERROR\t" NR; next }
			id=cell[2]; status=cell[4]; dependency=cell[5]; spec=cell[6]
			gsub(/^ +| +$/, "", id); gsub(/^ +| +$/, "", status); gsub(/^ +| +$/, "", dependency); gsub(/^ +| +$/, "", spec)
			if (id !~ /^F[0-9][0-9][0-9]$/) { print "ERROR\t" NR; next }
			print "ROW\t" id "\t" status "\t" dependency "\t" spec
		}
	' "$nova/product-spec.md")
	for id in "${!product_deps[@]}"; do
		rest=${product_deps[$id]}
		while [[ "$rest" =~ (F[0-9]{3}) ]]; do
			dependency=${BASH_REMATCH[1]}
			[[ -n ${product_rows[$dependency]+x} ]] || fail "$id references unknown product dependency $dependency"
			rest=${rest#*"$dependency"}
		done
		case ${product_rows[$id]} in
			Ready|Selected|Completed)
				rest=${product_deps[$id]}
				while [[ "$rest" =~ (F[0-9]{3}) ]]; do
					dependency=${BASH_REMATCH[1]}
					[[ ${product_rows[$dependency]:-missing} == "Completed" ]] || fail "$id is ${product_rows[$id]} with unsatisfied product dependency $dependency"
					rest=${rest#*"$dependency"}
				done
				;;
		esac
	done
	if (( ${#product_rows[@]} == 0 )); then
		fail 'product feature dashboard has no feature rows'
	elif [[ "$product_status" == "Active" ]]; then
		selected=0
		for id in "${!product_rows[@]}"; do
			if [[ ${product_rows[$id]} == "Selected" ]]; then selected=$((selected + 1)); fi
		done
		(( selected <= 1 )) || fail "active product may have at most one Selected feature, found $selected"
		(( selected == 0 )) && warn 'active product has no Selected feature; product update must select dependency-ready work'
	elif [[ "$product_status" == "Completed" ]]; then
		for id in "${!product_rows[@]}"; do
			case ${product_rows[$id]} in Completed|Cancelled) ;; *) fail "completed product has nonterminal feature $id (${product_rows[$id]})" ;; esac
		done
		has_unchecked "$nova/product-spec.md" 'Product Acceptance' && fail 'completed product has unchecked acceptance conditions'
	fi
	declare -A product_visit=()
	visit_product() {
		local node=$1 dependency rest
		case ${product_visit[$node]:-0} in 1) return 1 ;; 2) return 0 ;; esac
		product_visit[$node]=1
		rest=${product_deps[$node]}
		while [[ "$rest" =~ (F[0-9]{3}) ]]; do
			dependency=${BASH_REMATCH[1]}
			if [[ -n ${product_rows[$dependency]+x} ]] && ! visit_product "$dependency"; then return 1; fi
			rest=${rest#*"$dependency"}
		done
		product_visit[$node]=2
	}
	for id in "${!product_rows[@]}"; do
		if ! visit_product "$id"; then fail "product dependency cycle involving $id"; break; fi
	done
	unset -f visit_product
	unset product_visit
fi

declare -A completed_features=()
if [[ -d "$nova/features" && ! -L "$nova/features" ]]; then
	shopt -s nullglob
	for feature in "$nova/features"/*; do
		[[ -d "$feature" ]] || continue
		name=${feature##*/}
		if [[ -L "$feature" ]]; then fail "features/$name must not be a symlink"; continue; fi
		if [[ ! "$name" =~ ^F[0-9]{3}-[a-z0-9]+(-[a-z0-9]+)*$ ]]; then fail "invalid feature directory name: $name"; continue; fi
		spec="$feature/T00-spec.md"
		if [[ ! -f "$spec" ]]; then
			fail "features/$name/T00-spec.md is missing"
			continue
		fi
		if [[ -L "$spec" ]]; then fail "features/$name/T00-spec.md must not be a symlink"; continue; fi
		require_single_key "$spec" 'Status:'
		require_single_key "$spec" 'Product feature:'
		feature_status=$(status_of "$spec")
		case "$feature_status" in
			Draft|Approved|"In Progress"|Validating|Completed|Blocked|Deferred|Cancelled) ;;
			*) fail "invalid feature status in $name: ${feature_status:-missing}" ;;
		esac
		feature_id=${name%%-*}
		[[ "$feature_status" == "Completed" ]] && completed_features[$feature_id]=1
		product_feature=$(value_of "$spec" 'Product feature:')
		[[ "$product_feature" == "$feature_id" ]] || fail "$name has mismatched Product feature: ${product_feature:-missing}"
		if (( ${#product_rows[@]} > 0 )); then
			[[ -n ${product_rows[$feature_id]+x} ]] || fail "$name is not indexed by product-spec.md"
			[[ ${product_specs[$feature_id]:-} == ".ai-nova/features/$name/T00-spec.md" ]] || fail "$name does not match its product dashboard spec path"
			if [[ ${product_rows[$feature_id]} == "Completed" && "$feature_status" != "Completed" ]]; then
				fail "$feature_id is Completed in the product dashboard but feature status is $feature_status"
			fi
			case "$feature_status" in
				Approved|"In Progress"|Validating) [[ ${product_rows[$feature_id]} == "Selected" ]] || fail "$feature_id is $feature_status while its product row is ${product_rows[$feature_id]}, not Selected" ;;
				Completed) case ${product_rows[$feature_id]} in Selected|Completed) ;; *) fail "$feature_id is Completed while its product row is ${product_rows[$feature_id]}" ;; esac ;;
			esac
		fi
		for heading in Why 'Shippable Outcome' Context Decisions Constraints Exclusions 'Task Table' Acceptance 'Validation Results' 'Change And Exception History'; do
			require_heading "$spec" "$heading"
		done
		has_checklist "$spec" Acceptance || fail "$name has no feature acceptance conditions"
		section_has_line "$spec" 'Validation Results' '| Acceptance | Result | Evidence |' || fail "$name has an invalid local validation results header"
		section_has_line "$spec" 'Validation Results' '| --- | --- | --- |' || fail "$name has an invalid validation results separator"
		require_single_key "$spec" 'Validation attempt:'
		require_single_key "$spec" 'Tested commit:'
		declare -A acceptance_ids=() validation_ids=()
		while IFS=$'\t' read -r record acceptance_id; do
			if [[ "$record" == "ERROR" ]]; then fail "malformed acceptance item in $name at line $acceptance_id"; continue; fi
			[[ -z ${acceptance_ids[$acceptance_id]+x} ]] || fail "duplicate acceptance ID $acceptance_id in $name"
			acceptance_ids[$acceptance_id]=1
		done < <(awk '
			{ sub(/\r$/, "") }
			$0 == "## Acceptance" { section=1; next }
			section && /^## / { exit }
			section && /^- \[[ xX]\] / {
				if (match($0, /^- \[[ xX]\] A(0[1-9]|[1-9][0-9]):/)) print "ROW\t" substr($0, 7, 3)
				else print "ERROR\t" NR
			}
			section && /^[*+] \[[ xX]\] / { print "ERROR\t" NR }
		' "$spec")
		while IFS=$'\t' read -r record acceptance_id result evidence; do
			if [[ "$record" == "ERROR" ]]; then fail "malformed validation result in $name at line $acceptance_id"; continue; fi
			[[ -z ${validation_ids[$acceptance_id]+x} ]] || fail "duplicate validation result for $acceptance_id in $name"
			validation_ids[$acceptance_id]=$result
			case "$result" in "Not Run"|PASS|FAIL|MANUAL_VERIFY|UNVERIFIABLE|"Accepted Exception") ;; *) fail "invalid validation result for $acceptance_id in $name: $result" ;; esac
			if [[ "$result" != "Not Run" && ( -z "$evidence" || "$evidence" == "Pending validation." ) ]]; then fail "$name lacks validation evidence for $acceptance_id"; fi
			if [[ "$result" == "Accepted Exception" && ! "$evidence" =~ Approved\ by\ user:\ .+ ]]; then fail "$name lacks explicit user approval evidence for acceptance exception $acceptance_id"; fi
		done < <(awk '
			{ sub(/\r$/, "") }
			$0 == "## Validation Results" { section=1; next }
			section && /^## / { exit }
			!section || /^[[:space:]]*$/ || /^Validation attempt:/ || /^Tested commit:/ || $0 == "| Acceptance | Result | Evidence |" || $0 ~ /^\| -+ \|/ { next }
			{
				count=split($0, cell, "|")
				if ($0 !~ /^\|/ || count != 5) { print "ERROR\t" NR; next }
				id=cell[2]; result=cell[3]; evidence=cell[4]; gsub(/^ +| +$/, "", id); gsub(/^ +| +$/, "", result); gsub(/^ +| +$/, "", evidence)
				if (id !~ /^A(0[1-9]|[1-9][0-9])$/) { print "ERROR\t" NR; next }
				print "ROW\t" id "\t" result "\t" evidence
			}
		' "$spec")
		for acceptance_id in "${!acceptance_ids[@]}"; do [[ -n ${validation_ids[$acceptance_id]+x} ]] || fail "$name lacks a validation row for $acceptance_id"; done
		for acceptance_id in "${!validation_ids[@]}"; do [[ -n ${acceptance_ids[$acceptance_id]+x} ]] || fail "$name has validation for unknown $acceptance_id"; done
		validation_attempt=$(value_of "$spec" 'Validation attempt:')
		tested_commit=$(value_of "$spec" 'Tested commit:')
		validation_started=0
		for acceptance_id in "${!validation_ids[@]}"; do [[ ${validation_ids[$acceptance_id]} != "Not Run" ]] && validation_started=1; done
		if (( validation_started )); then
			[[ "$validation_attempt" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || fail "$name has invalid validation attempt date: $validation_attempt"
			if [[ -z "$tested_commit" || "$tested_commit" == "Not run" ]] || ! git -C "$root" cat-file -e "$tested_commit^{commit}" 2>/dev/null; then fail "$name has an invalid tested commit: $tested_commit"; fi
		elif [[ "$validation_attempt" != "Not run" || "$tested_commit" != "Not run" ]]; then
			fail "$name has validation metadata without validation results"
		fi
		if [[ "$feature_status" == "Completed" ]]; then
			has_unchecked "$spec" Acceptance && fail "$name is Completed with unchecked acceptance conditions"
			for acceptance_id in "${!validation_ids[@]}"; do
				case ${validation_ids[$acceptance_id]} in PASS|"Accepted Exception") ;; *) fail "$name is Completed with unresolved validation result ${validation_ids[$acceptance_id]} for $acceptance_id" ;; esac
			done
		fi
		section_has_line "$spec" 'Task Table' '| ID | Task | Status | Depends on | Review | File |' || fail "$name has an invalid local task table header"
		section_has_line "$spec" 'Task Table' '| --- | --- | --- | --- | --- | --- |' || fail "$name has an invalid task table separator"

		declare -A rows=() files=() deps=() row_files=() reviews=()
		while IFS=$'\t' read -r record id task_status dependency review file; do
			if [[ "$record" == "ERROR" ]]; then fail "malformed task table row in $name at line $id"; continue; fi
			[[ -n "$id" ]] || continue
			if [[ -n ${rows[$id]+x} ]]; then
				fail "duplicate task row $id in $name"
				continue
			fi
			rows[$id]=$task_status
			deps[$id]=$dependency
			row_files[$id]=$file
			reviews[$id]=$review
			case "$task_status" in
				Planned|Ready|"In Progress"|Completed|Blocked|"Needs Change"|Impacted|Superseded|Deferred|"Accepted Exception") ;;
				*) fail "invalid task status $task_status for $id in $name" ;;
			esac
			[[ "$dependency" =~ ^(None|T(0[1-9]|[1-9][0-9])(,\ T(0[1-9]|[1-9][0-9]))*)$ ]] || fail "invalid task dependency list for $id in $name: $dependency"
			review_valid "$review" || fail "invalid review profile list for $id in $name: $review"
			if [[ "$file" == "None" ]]; then
				case "$task_status" in Superseded|"Accepted Exception") ;; *) fail "$id uses File: None without a terminal status in $name" ;; esac
			elif [[ ! "$file" =~ ^T(0[1-9]|[1-9][0-9])-[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then
				fail "invalid task filename for $id in $name: $file"
			else
				[[ "${file:0:3}" == "$id" ]] || fail "$id points to mismatched task file $file in $name"
				[[ -z ${files[$file]+x} ]] || fail "duplicate task file $file in $name"
				files[$file]=$id
				if [[ ! -f "$feature/$file" && "$task_status" != "Planned" ]]; then
					fail "missing task file $file in $name"
				fi
			fi
		done < <(awk '
			{ sub(/\r$/, "") }
			$0 == "## Task Table" { section=1; next }
			section && /^## / { exit }
			!section || /^[[:space:]]*$/ || $0 == "| ID | Task | Status | Depends on | Review | File |" || $0 ~ /^\| -+ \|/ { next }
			{
				count=split($0, cell, "|")
				if ($0 !~ /^\|/ || count != 8) { print "ERROR\t" NR; next }
				id=cell[2]; status=cell[4]; dependency=cell[5]; review=cell[6]; file=cell[7]
				gsub(/^ +| +$/, "", id); gsub(/^ +| +$/, "", status); gsub(/^ +| +$/, "", dependency); gsub(/^ +| +$/, "", review); gsub(/^ +| +$/, "", file)
				if (id !~ /^T(0[1-9]|[1-9][0-9])$/) { print "ERROR\t" NR; next }
				print "ROW\t" id "\t" status "\t" dependency "\t" review "\t" file
			}
		' "$spec")

		for id in "${!deps[@]}"; do
			rest=${deps[$id]}
			dependencies_satisfied=1
			while [[ "$rest" =~ (T[0-9]{2}) ]]; do
				dependency=${BASH_REMATCH[1]}
				[[ -n ${rows[$dependency]+x} ]] || fail "$id references unknown dependency $dependency in $name"
				case ${rows[$dependency]:-missing} in Completed|Superseded|"Accepted Exception") ;; *) dependencies_satisfied=0 ;; esac
				rest=${rest#*"$dependency"}
			done
			case ${rows[$id]} in
			Ready|"In Progress"|Completed)
				rest=${deps[$id]}
				while [[ "$rest" =~ (T[0-9]{2}) ]]; do
					dependency=${BASH_REMATCH[1]}
					case ${rows[$dependency]:-missing} in Completed|Superseded|"Accepted Exception") ;; *) fail "$id is ${rows[$id]} with unsatisfied dependency $dependency in $name" ;; esac
					rest=${rest#*"$dependency"}
					done
				;;
			esac
			if [[ ${rows[$id]} == "Planned" && ${row_files[$id]} != "None" && -f "$feature/${row_files[$id]}" && $dependencies_satisfied == 1 ]]; then
				fail "$id remains Planned despite being materialized and dependency-satisfied in $name"
			fi
		done
		(( ${#rows[@]} > 0 )) || fail "$name has no task rows"
		if [[ "$feature_status" == "Validating" || "$feature_status" == "Completed" ]]; then
			for id in "${!rows[@]}"; do
				case ${rows[$id]} in Completed|Superseded|"Accepted Exception") ;; *) fail "$name is $feature_status with nonterminal task $id (${rows[$id]})" ;; esac
			done
		fi
		for id in "${!rows[@]}"; do
			case ${rows[$id]} in
				Superseded) section_matches "$spec" 'Change And Exception History' "^- ${id}: .+" || fail "$id is Superseded without a substantive history entry in $name" ;;
				"Accepted Exception") section_matches "$spec" 'Change And Exception History' "^- ${id}: .+Approved by user: .+" || fail "$id is Accepted Exception without rationale and explicit user approval in $name" ;;
			esac
		done

		declare -A visit=()
		visit_task() {
			local node=$1 dependency rest
			case ${visit[$node]:-0} in
				1) return 1 ;;
				2) return 0 ;;
			esac
			visit[$node]=1
			rest=${deps[$node]}
			while [[ "$rest" =~ (T[0-9]{2}) ]]; do
				dependency=${BASH_REMATCH[1]}
				if [[ -n ${rows[$dependency]+x} ]] && ! visit_task "$dependency"; then
					return 1
				fi
				rest=${rest#*"$dependency"}
			done
			visit[$node]=2
			return 0
		}
		for id in "${!rows[@]}"; do
			if ! visit_task "$id"; then
				fail "task dependency cycle involving $id in $name"
				break
			fi
		done
		unset -f visit_task

		for task in "$feature"/T*.md; do
			task_name=${task##*/}
			[[ "$task_name" == "T00-spec.md" ]] && continue
			if [[ -L "$task" ]]; then fail "task file must not be a symlink: $task_name"; continue; fi
			if [[ ! -f "$task" ]]; then fail "task artifact must be a regular file: $task_name"; continue; fi
			if [[ ! "$task_name" =~ ^T(0[1-9]|[1-9][0-9])-[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then fail "invalid task filename: $task_name"; continue; fi
			[[ -n ${files[$task_name]+x} ]] || fail "orphaned task file $task_name in $name"
			task_id=${task_name:0:3}
			IFS= read -r task_title < "$task" || true
			[[ "$task_title" == "# $task_id:"* ]] || fail "$task_name has a mismatched task title"
			for heading in Outcome 'Depends On' 'Do' Files 'Relevant Context' Verify 'Review Profile' Execution 'Outcome Evidence'; do require_heading "$task" "$heading"; done
			require_single_key "$task" 'Dependencies:'
			require_single_key "$task" 'Profiles:'
			[[ $(value_of "$task" 'Dependencies:') == "${deps[$task_id]:-missing}" ]] || fail "$task_name dependencies do not match its task row"
			[[ $(value_of "$task" 'Profiles:') == "${reviews[$task_id]:-missing}" ]] || fail "$task_name review profiles do not match its task row"
			for key in 'Baseline:' 'Branch:' 'WIP marker:' 'WIP unblock condition:'; do require_single_key "$task" "$key"; done
			baseline=$(value_of "$task" 'Baseline:')
			branch=$(value_of "$task" 'Branch:')
			wip_marker=$(value_of "$task" 'WIP marker:')
			wip_unblock=$(value_of "$task" 'WIP unblock condition:')
			case "$wip_marker" in None|"This commit") ;; *) fail "$task_name has invalid WIP marker: $wip_marker" ;; esac
			if [[ "$wip_marker" == "This commit" ]]; then
				[[ "$branch" == "nova/wip-$feature_id-$task_id" ]] || fail "$task_name WIP marker is on an invalid branch: $branch"
				[[ -n "$wip_unblock" && "$wip_unblock" != "None" ]] || fail "$task_name WIP marker lacks an unblock condition"
			fi
			case ${rows[$task_id]:-missing} in
				"In Progress"|Completed)
					[[ -n "$baseline" && "$baseline" != "Not started" ]] || fail "$task_name lacks an execution baseline"
					if [[ -n "$baseline" && "$baseline" != "Not started" ]] && ! git -C "$root" cat-file -e "$baseline^{commit}" 2>/dev/null; then fail "$task_name has an invalid execution baseline: $baseline"; fi
					[[ -n "$branch" && "$branch" != "Not started" ]] || fail "$task_name lacks an execution branch"
					;;
			esac
			if [[ ${rows[$task_id]:-missing} == "Completed" ]]; then
				has_checklist "$task" 'Do' || fail "$task_name has no implementation checklist"
				has_unchecked "$task" 'Do' && fail "$task_name is Completed with unchecked implementation steps"
				outcome=$(section_value "$task" 'Outcome Evidence')
				[[ -n "$outcome" && "$outcome" != "Not performed." ]] || fail "$task_name is Completed without outcome evidence"
				[[ -n $(section_value "$task" Verify) ]] || fail "$task_name has no verification instructions"
				[[ "$wip_marker" == "None" && "$wip_unblock" == "None" ]] || fail "$task_name is Completed with uncleared WIP metadata"
			fi
		done
		unset rows files deps row_files reviews visit acceptance_ids validation_ids
	done
	shopt -u nullglob
fi

declare -A phr_seen=()
if [[ -d "$nova/product-changes" && ! -L "$nova/product-changes" ]]; then
	shopt -s nullglob
	for request in "$nova/product-changes"/*.md; do
		request_name=${request##*/}
		if [[ -L "$request" ]]; then fail "product request must not be a symlink: $request_name"; continue; fi
		if [[ ! -f "$request" ]]; then fail "product request artifact must be a regular file: $request_name"; continue; fi
		require_single_key "$request" 'Status:'
		if [[ "$request_name" =~ ^PCR-[0-9]{3}-[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then
			request_status=$(status_of "$request")
			case "$request_status" in Proposed|Approved|Applied|Rejected|Withdrawn) ;; *) fail "invalid PCR status in $request_name: ${request_status:-missing}" ;; esac
			for key in 'Originating feature:' 'Originating task:' 'Blocks:' 'Unblock condition:'; do require_single_key "$request" "$key"; done
			origin_feature=$(value_of "$request" 'Originating feature:')
			origin_task=$(value_of "$request" 'Originating task:')
			[[ "$origin_feature" =~ ^F[0-9]{3}$ && -n ${product_rows[$origin_feature]+x} ]] || fail "$request_name has unknown Originating feature: ${origin_feature:-missing}"
			[[ "$origin_task" =~ ^(None|T(0[1-9]|[1-9][0-9]))$ ]] || fail "$request_name has invalid Originating task: ${origin_task:-missing}"
			if [[ "$origin_task" != "None" && -n ${product_specs[$origin_feature]:-} && -f "$root/${product_specs[$origin_feature]}" ]]; then
				section_matches "$root/${product_specs[$origin_feature]}" 'Task Table' "^\\| ${origin_task} \\|" || fail "$request_name references unknown originating task $origin_task"
			fi
			blocks=$(value_of "$request" 'Blocks:')
			[[ "$blocks" =~ ^(None|F[0-9]{3}(,\ F[0-9]{3})*)$ ]] || fail "invalid Blocks field in $request_name: ${blocks:-missing}"
			unblock=$(value_of "$request" 'Unblock condition:')
			if [[ "$blocks" == "None" ]]; then
				[[ "$unblock" == "None" ]] || fail "$request_name must use Unblock condition: None when Blocks is None"
			else
				[[ -n "$unblock" && "$unblock" != "None" && "$unblock" != *'exact applied product decision'* ]] || fail "$request_name blocks features without a substantive unblock condition"
				declare -A request_blocks=()
				rest=$blocks
				while [[ "$rest" =~ (F[0-9]{3}) ]]; do
					blocked_id=${BASH_REMATCH[1]}
					[[ -z ${request_blocks[$blocked_id]+x} ]] || fail "$request_name repeats blocked feature $blocked_id"
					request_blocks[$blocked_id]=1
					[[ -n ${product_rows[$blocked_id]+x} ]] || fail "$request_name blocks unknown feature $blocked_id"
					rest=${rest#*"$blocked_id"}
				done
				unset request_blocks
			fi
			for heading in 'Trigger And Evidence' 'Current Product Rule' 'Proposed Product Update' 'Dependency Edges' 'Directly Affected Features' 'Transitively Affected Features' 'Completed Work At Risk' 'Delivery Impact' 'Options And Recommendation' 'User Decision' 'Application Result'; do require_heading "$request" "$heading"; done
			decision=$(section_value "$request" 'User Decision')
			application=$(section_value "$request" 'Application Result')
			if [[ "$request_status" == "Proposed" ]]; then
				[[ "$decision" == "Pending." && "$application" == "Not applied." ]] || fail "$request_name Proposed placeholders do not match the request schema"
			else
				[[ -n "$decision" && "$decision" != "Pending." ]] || fail "$request_name has status $request_status without a recorded user decision"
				case "$request_status" in
					Approved) [[ "$application" == "Not applied." ]] || fail "$request_name is Approved with an invalid application result" ;;
					Applied) [[ -n "$application" && "$application" != "Not applied." ]] || fail "$request_name is Applied without an application result" ;;
					Rejected|Withdrawn) [[ -n "$application" ]] || fail "$request_name is $request_status without an application result" ;;
				esac
			fi
		elif [[ "$request_name" =~ ^PHR-F[0-9]{3}\.md$ ]]; then
			request_status=$(status_of "$request")
			case "$request_status" in Pending|Applied) ;; *) fail "invalid PHR status in $request_name: ${request_status:-missing}" ;; esac
			for key in 'Feature:' 'Feature spec:'; do require_single_key "$request" "$key"; done
			request_feature=${request_name#PHR-}; request_feature=${request_feature%.md}
			[[ -z ${phr_seen[$request_feature]+x} ]] || fail "duplicate Product Handoff Request for $request_feature"
			phr_seen[$request_feature]=$request_status
			[[ $(value_of "$request" 'Feature:') == "$request_feature" ]] || fail "$request_name has mismatched Feature metadata"
			request_spec=$(value_of "$request" 'Feature spec:'); request_spec=${request_spec#\`}; request_spec=${request_spec%\`}
			[[ "$request_spec" =~ ^\.ai-nova/features/${request_feature}-[a-z0-9]+(-[a-z0-9]+)*/T00-spec\.md$ ]] || fail "$request_name has invalid Feature spec metadata"
			[[ -f "$root/$request_spec" ]] || fail "$request_name points to missing feature spec $request_spec"
			if [[ -f "$root/$request_spec" && $(status_of "$root/$request_spec") != "Completed" ]]; then fail "$request_name requires a Completed feature spec"; fi
			for heading in 'Validated Outcome' 'Validation Evidence' 'Limitations And Accepted Exceptions' 'Dependency Observations' 'Product Readiness Implications' 'Product Steward Result'; do require_heading "$request" "$heading"; done
			for heading in 'Validated Outcome' 'Validation Evidence' 'Limitations And Accepted Exceptions' 'Dependency Observations' 'Product Readiness Implications'; do
				[[ -n $(section_value "$request" "$heading") ]] || fail "$request_name lacks substantive content or explicit None under ## $heading"
			done
			steward_result=$(section_value "$request" 'Product Steward Result')
			if [[ "$request_status" == "Pending" ]]; then
				[[ "$steward_result" == "Not applied." ]] || fail "$request_name Pending placeholder does not match the handoff schema"
				[[ ${product_rows[$request_feature]:-missing} != "Completed" ]] || fail "$request_name is Pending after dashboard completion"
			else
				[[ -n "$steward_result" && "$steward_result" != "Not applied." ]] || fail "$request_name is Applied without a product steward result"
				[[ ${product_rows[$request_feature]:-missing} == "Completed" ]] || fail "$request_name is Applied while the product dashboard is ${product_rows[$request_feature]:-missing}"
			fi
		else
			fail "invalid product request filename: $request_name"
		fi
	done
	shopt -u nullglob
fi

for feature_id in "${!completed_features[@]}"; do
	[[ -n ${phr_seen[$feature_id]+x} ]] || fail "completed feature $feature_id lacks its mandatory Product Handoff Request"
done

[[ -d "$root/.ai" ]] && warn 'legacy .ai/ coexists; NOVA will leave it untouched'

print_result
(( errors == 0 ))
