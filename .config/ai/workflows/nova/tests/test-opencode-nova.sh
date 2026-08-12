#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
nova_dir=$(cd -- "$script_dir/.." && pwd)
config_root=$(cd -- "$nova_dir/../../.." && pwd)
voice_activation='Apply the central voice and presentation contract.'
startup_activation='On the first user-facing response in a fresh NOVA session, render the authoritative startup mark exactly once.'

config_file=$(mktemp)
trap 'rm -f "$config_file"' EXIT
opencode debug config > "$config_file"
skills=$(opencode debug skill)

grep -Fqx -- '## Voice And Personality' "$nova_dir/WORKFLOW.md"
grep -Fqx -- '## Presentation' "$nova_dir/WORKFLOW.md"
logo_width=$(awk '
	/On the first conversational NOVA response/ { armed=1 }
	started && /^```$/ { exit }
	armed && /^```text$/ { started=1; next }
	started { if (length($0) > width) width=length($0) }
	END { print width+0 }
' "$nova_dir/WORKFLOW.md")
(( logo_width > 0 && logo_width <= 96 ))

for agent in \
	nova-product-steward \
	nova-workflow-steward \
	nova-task-reviewer \
	nova-readonly \
	nova-project-planner \
	nova-task-worker \
	nova-setup-steward \
	nova-validator; do
	jq -e --arg agent "$agent" '.agent | has($agent)' "$config_file" >/dev/null
	grep -Fq -- "$voice_activation" "$config_root/opencode/agents/$agent.md"
done

for agent in \
	nova-product-steward \
	nova-workflow-steward \
	nova-readonly \
	nova-project-planner \
	nova-task-worker \
	nova-setup-steward \
	nova-validator; do
	grep -Fqx -- "$startup_activation" "$config_root/opencode/agents/$agent.md"
done
! grep -Fq -- "$startup_activation" "$config_root/opencode/agents/nova-task-reviewer.md"

for skill in \
	nova-workflow-governance \
	nova-project-structure \
	nova-product-governance \
	nova-inbox-management \
	nova-feature-planning \
	nova-task-execution \
	nova-task-exception-resolution \
	nova-verification \
	nova-code-review \
	nova-git-handoff; do
	jq -e --arg skill "$skill" 'any(.[]; .name == $skill)' <<< "$skills" >/dev/null
done

assert_command_agent() {
	jq -e --arg command "$1" --arg agent "$2" '.command[$command].agent == $agent' "$config_file" >/dev/null
	grep -Fq -- "\`/$1\`" "$nova_dir/command-map.md"
	grep -Fq -- 'Use the authoritative first-person voice, startup mark, and checkpoint presentation.' "$config_root/opencode/commands/$1.md"
}

assert_command_agent nova-project-setup nova-setup-steward
assert_command_agent nova-product-spec-create nova-product-steward
assert_command_agent nova-product-spec-update nova-product-steward
assert_command_agent nova-feature-spec-create nova-project-planner
assert_command_agent nova-feature-spec-update nova-project-planner
assert_command_agent nova-feature-spec-to-tasks nova-project-planner
assert_command_agent nova-feature-task-execute nova-task-worker
assert_command_agent nova-feature-spec-validate nova-validator
assert_command_agent nova-inbox-process nova-project-planner
assert_command_agent nova-project-status nova-readonly
assert_command_agent nova-suggest-next-action nova-readonly
assert_command_agent nova-workflow-update nova-workflow-steward

assert_agent_tools() {
	opencode debug agent "$1" | jq -e "$2" >/dev/null
}

assert_agent_tools nova-product-steward '.tools.question == true and .tools.bash == false and .tools.nova_git == true and .tools.nova_project_check == true and .tools.nova_status == true and ([.permission[] | select(.permission == "nova_git_stage" and .action == "ask")] | length > 0) and ([.permission[] | select(.permission == "nova_git_commit" and .action == "ask")] | length > 0)'
assert_agent_tools nova-project-planner '.tools.question == true and .tools.bash == false and .tools.nova_git == true and .tools.nova_project_check == true and .tools.nova_status == true'
assert_agent_tools nova-readonly '.tools.question == true and .tools.bash == false and .tools.apply_patch == false and .tools.nova_git == true and .tools.nova_project_check == true and .tools.nova_status == true'
assert_agent_tools nova-setup-steward '.tools.question == true and .tools.bash == false and .tools.grep == false and .tools.glob == false and .tools.nova_git == true and .tools.nova_project_check == true and .tools.nova_status == true'
assert_agent_tools nova-validator '.tools.question == true and .tools.bash == true and .tools.nova_git == true and .tools.nova_project_check == true and .tools.nova_status == true'
assert_agent_tools nova-task-worker '.tools.question == true and .tools.bash == true and .tools.nova_git == true and .tools.nova_project_check == true and .tools.nova_status == true'
assert_agent_tools nova-workflow-steward '.tools.question == true and .tools.bash == true and .tools.nova_git == false and .tools.nova_project_check == false and .tools.nova_status == false and .tools.apply_patch == true'
assert_agent_tools nova-task-reviewer '.tools.question == false and .tools.bash == false and .tools.apply_patch == false and .tools.nova_git == false and .tools.nova_project_check == false and .tools.nova_status == false'

printf 'NOVA OpenCode discovery tests passed\n'
