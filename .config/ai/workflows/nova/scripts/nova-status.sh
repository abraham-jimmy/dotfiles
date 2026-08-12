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

if (( $# > 1 )); then
	printf '%s[ERROR]%s Usage: nova-status [project-root]\n' "$color_red" "$color_reset" >&2
	exit 2
fi

requested_root=${1:-.}
root=$(git -C "$requested_root" rev-parse --show-toplevel 2>/dev/null) || {
	printf 'NOVA // STATUS\n\n%s[ERROR]%s Not inside a Git repository: %s\n' "$color_red" "$color_reset" "$requested_root" >&2
	exit 2
}

nova="$root/.ai-nova"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

printf 'NOVA // STATUS\n'
printf 'Repository  %s\n\n' "$root"
report_warning=0

if git_state=$(GIT_OPTIONAL_LOCKS=0 git -C "$root" status --porcelain=v1 --untracked-files=all); then
	if [[ -z "$git_state" ]]; then
		printf 'Git         CLEAN\n'
	else
		printf 'Git         DIRTY\n%s\n' "$git_state"
		printf '%s[WARNING]%s Working tree changes require attention before mutating commands.\n' "$color_yellow" "$color_reset"
		report_warning=1
	fi
else
	printf '%s[ERROR]%s Unable to read Git status.\n' "$color_red" "$color_reset"
	exit 2
fi

if [[ -L "$nova" ]]; then
	printf '%s[FAIL]%s .ai-nova/ must not be a symlink.\n' "$color_red" "$color_reset"
	exit 1
elif [[ ! -d "$nova" ]]; then
	printf 'Structure   NOT INITIALIZED\n'
	[[ -d "$root/.ai" ]] && printf '%s[WARNING]%s Legacy .ai/ workflow detected.\n' "$color_yellow" "$color_reset"
	printf '\n%s[RESULT]%s Project setup is required.\n' "$color_red" "$color_reset"
	exit 1
fi

set +e
"$script_dir/nova-project-check.sh" "$root" >/dev/null
check_status=$?
set -e
case "$check_status" in
	0) printf 'Structure   VALID\n' ;;
	1) printf 'Structure   ISSUES DETECTED\n'; printf '%s[WARNING]%s Run /nova-project-setup for detailed diagnostics.\n' "$color_yellow" "$color_reset"; report_warning=1 ;;
	*) printf '%s[ERROR]%s Unable to run the structure check.\n' "$color_red" "$color_reset"; exit 2 ;;
esac

if [[ -f "$nova/product-spec.md" ]]; then
	product_status=$(awk '/^Status:/ { sub(/^Status:[[:space:]]*/, ""); sub(/\r$/, ""); print; exit }' "$nova/product-spec.md")
	printf 'Product     %s\n' "${product_status:-STATUS NOT RECORDED}"
else
	printf 'Product     NOT CREATED\n'
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
printf 'Inbox       new %s / deferred %s\n' "$inbox_new" "$inbox_deferred"

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
printf 'Features    %d total / %d active / %d blocked / %d completed\n' "$feature_total" "$feature_active" "$feature_blocked" "$feature_completed"

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
printf 'Requests    %d proposed / %d approved / %d applied / %d closed / %d handoff pending\n' "$pcr_proposed" "$pcr_approved" "$pcr_applied" "$pcr_rejected" "$phr_pending"

if (( report_warning )); then
	printf '\n%s[RESULT]%s Status collected with warnings.\n' "$color_yellow" "$color_reset"
else
	printf '\n%s[RESULT]%s Status collected.\n' "$color_green" "$color_reset"
fi
