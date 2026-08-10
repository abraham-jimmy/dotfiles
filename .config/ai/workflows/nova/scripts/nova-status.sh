#!/usr/bin/env bash

set -euo pipefail

if (( $# > 1 )); then
	printf 'Usage: nova-status [project-root]\n' >&2
	exit 2
fi

requested_root=${1:-.}
root=$(git -C "$requested_root" rev-parse --show-toplevel 2>/dev/null) || {
	printf 'NOVA Status\nERROR Not inside a Git repository: %s\n' "$requested_root" >&2
	exit 2
}

nova="$root/.ai-nova"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

printf 'NOVA Status\n'
printf 'Repository: %s\n' "$root"

if git_state=$(GIT_OPTIONAL_LOCKS=0 git -C "$root" status --porcelain=v1 --untracked-files=all); then
	if [[ -z "$git_state" ]]; then
		printf 'Git: Clean\n'
	else
		printf 'Git: Dirty\n%s\n' "$git_state"
	fi
else
	printf 'Git: ERROR unable to read status\n'
	exit 2
fi

if [[ -L "$nova" ]]; then
	printf 'Structure: Invalid; .ai-nova/ must not be a symlink\n'
	exit 1
elif [[ ! -d "$nova" ]]; then
	printf 'Structure: Not initialized\n'
	[[ -d "$root/.ai" ]] && printf 'Legacy workflow: .ai/ detected\n'
	exit 1
fi

set +e
"$script_dir/nova-project-check.sh" "$root" >/dev/null
check_status=$?
set -e
case "$check_status" in
	0) printf 'Structure: Valid\n' ;;
	1) printf 'Structure: Issues detected; run /nova-project-setup\n' ;;
	*) printf 'Structure: ERROR unable to run NOVA structure check\n'; exit 2 ;;
esac

if [[ -f "$nova/product-spec.md" ]]; then
	product_status=$(awk '/^Status:/ { sub(/^Status:[[:space:]]*/, ""); sub(/\r$/, ""); print; exit }' "$nova/product-spec.md")
	printf 'Product: %s\n' "${product_status:-Status not recorded}"
else
	printf 'Product: Not created\n'
fi

inbox_new='none'
inbox_deferred='none'
if [[ -f "$nova/INBOX.md" ]]; then
	read -r inbox_new inbox_deferred < <(awk '
		function content(line) { return line !~ /^[[:space:]]*$/ && line !~ /^#/ }
		function without_comments(line, start, finish) {
			if (comment) {
				finish=index(line, "-->")
				if (!finish) return ""
				line=substr(line, finish+3); comment=0
			}
			while ((start=index(line, "<!--"))) {
				finish=index(substr(line, start+4), "-->")
				if (!finish) { line=substr(line, 1, start-1); comment=1; break }
				line=substr(line, 1, start-1) substr(line, start+3+finish+3)
			}
			return line
		}
		/^## User Input\r?$/ { section="user"; next }
		/^<!-- NOVA-MANAGED AREA:/ { section=""; next }
		/^## Deferred\r?$/ { section="deferred"; next }
		/^## / && section == "deferred" { section="" }
		{ visible=without_comments($0) }
		section == "user" && content(visible) { user=1 }
		section == "deferred" && content(visible) { deferred=1 }
		END { print (user ? "present" : "none"), (deferred ? "present" : "none") }
	' "$nova/INBOX.md")
fi
printf 'Inbox: new input %s, deferred entries %s\n' "$inbox_new" "$inbox_deferred"

feature_total=0
feature_completed=0
feature_active=0
feature_blocked=0
shopt -s nullglob
for spec in "$nova/features"/F*/T00-spec.md; do
	feature_total=$((feature_total + 1))
	status=$(awk '/^Status:/ { sub(/^Status:[[:space:]]*/, ""); sub(/\r$/, ""); print; exit }' "$spec")
	case "$status" in
		Completed) feature_completed=$((feature_completed + 1)) ;;
		Approved|"In Progress"|Validating) feature_active=$((feature_active + 1)) ;;
		Blocked) feature_blocked=$((feature_blocked + 1)) ;;
	esac
done
shopt -u nullglob
printf 'Features: %d total, %d active, %d blocked, %d completed\n' "$feature_total" "$feature_active" "$feature_blocked" "$feature_completed"

pcr_proposed=0
pcr_approved=0
pcr_applied=0
pcr_rejected=0
phr_pending=0
if [[ -d "$nova/product-changes" ]]; then
	shopt -s nullglob
	for request in "$nova/product-changes"/*.md; do
		name=${request##*/}
		status=$(awk '/^Status:/ { sub(/^Status:[[:space:]]*/, ""); sub(/\r$/, ""); print; exit }' "$request")
		case "$name:$status" in
			PCR-*:Proposed) pcr_proposed=$((pcr_proposed + 1)) ;;
			PCR-*:Approved) pcr_approved=$((pcr_approved + 1)) ;;
			PCR-*:Applied) pcr_applied=$((pcr_applied + 1)) ;;
			PCR-*:Rejected|PCR-*:Withdrawn) pcr_rejected=$((pcr_rejected + 1)) ;;
			PHR-*:Pending) phr_pending=$((phr_pending + 1)) ;;
		esac
	done
	shopt -u nullglob
fi
printf 'Product requests: %d proposed, %d approved, %d applied, %d closed; %d handoff pending\n' "$pcr_proposed" "$pcr_approved" "$pcr_applied" "$pcr_rejected" "$phr_pending"
