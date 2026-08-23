# Neovim AI Integration Plan

## Goal

Trial CodeCompanion as the main Neovim AI interaction layer while preserving the
current OpenCode workflow and adding GitHub Copilot only on machines where it is
explicitly enabled.

The first implementation should remain small, reversible, and avoid running
duplicate OpenCode or Copilot integrations.

## Target Roles

| Component | Responsibility |
| --- | --- |
| CodeCompanion | OpenCode CLI context sharing; Copilot chat and prompted inline edits at work |
| `copilot.lua` | Work-only, as-you-type Copilot suggestions |
| Sidekick | Temporary OpenCode fallback during the trial |
| Lualine | LSP, CodeCompanion/OpenCode, and Copilot connection or activity state |
| Blink | Normal LSP, path, buffer, and snippet completion |

OpenCode will run normally through `opencode`. The OpenCode web server, remote
attachment, and phone access are outside this trial.

## Machine Switch

Use one explicit machine-local environment switch:

```sh
NVIM_COPILOT=1
```

The variable should be set only on the work machine and should not be committed
with credentials or other machine secrets.

When the switch is enabled:

- Load and configure `copilot.lua`.
- Allow CodeCompanion Copilot chat and inline interactions.
- Show Copilot state in Lualine only when the client is attached.

When the switch is absent:

- Do not start or authenticate Copilot.
- Do not show Copilot as disconnected or produce authentication warnings.
- Keep CodeCompanion's standard OpenCode CLI workflow available.

## Phase 1: CodeCompanion Trial

- Add CodeCompanion and its required dependency through `vim.pack`.
- Configure one CLI agent that runs standard `opencode`.
- Keep automatic buffer reloads after agent file changes.
- Use fzf-lua for existing picker-compatible interactions.
- Keep Sidekick installed as a fallback during evaluation.
- Avoid launching OpenCode from both plugins for the same task.
- Do not add chat history, MCP, memory, web hosting, or extra AI providers yet.

Initial CodeCompanion workflows should cover:

- Toggle or focus the OpenCode CLI.
- Send the current file or visual selection without changing focus.
- Open the richer prompt input for multi-context requests.
- Send current diagnostics and optionally auto-submit the request.
- Send terminal output, quickfix entries, or the Git diff when relevant.
- Select multiple files or buffers before prompting OpenCode.

## Phase 2: Work-Only Copilot

- Add `zbirenbaum/copilot.lua`, not a second competing Copilot completion plugin.
- Load it only when `NVIM_COPILOT=1`.
- Authenticate independently on the work machine.
- Enable ghost-text suggestions with a dedicated accept key.
- Keep Blink's current `<Tab>` and `<S-Tab>` behavior unchanged initially.
- Hide Copilot suggestions while the Blink completion menu is visible.
- Prevent attachment to unlisted, special, secret, or explicitly excluded buffers.
- Use CodeCompanion's Copilot adapter for work-only chat and prompted inline edits.

Copilot Next Edit Suggestions are deferred. If added later, enable them in only
one implementation: Sidekick or `copilot.lua`, never both.

## Proposed Keymap Shape

Final mappings should stay under the existing `<leader>a` AI group and replace
old Sidekick mappings only after the trial succeeds.

| Mapping | Intended action |
| --- | --- |
| `<C-.>` | Toggle the active CodeCompanion CLI or interaction |
| `<leader>aa` | Open CodeCompanion actions |
| `<leader>ao` | Toggle or focus OpenCode CLI |
| `<leader>ap` | Open the rich CLI prompt input |
| `<leader>at` | Send current file or visual selection |
| `<leader>ad` | Send current diagnostics |
| `<leader>ac` | Toggle Copilot chat when the work switch is enabled |
| `<leader>ai` | Run a Copilot inline prompt when the work switch is enabled |

The implementation should check existing mappings before finalizing this table
and avoid overriding useful Blink, LSP, terminal, or Sidekick behavior during
the trial.

## Statusline

Extend the current Lualine AI component rather than adding another statusline
plugin.

- Show `AI opencode` while CodeCompanion's OpenCode CLI is running.
- Show `AI copilot` only when Copilot is attached to the current buffer.
- Use a busy or warning state while a Copilot request is active.
- Keep LSP state separate from AI state.
- Remove Sidekick-specific status handling only when Sidekick is removed.

## Evaluation

Use the trial for normal dotfile and personal-project work before removing
Sidekick.

The CodeCompanion OpenCode workflow is acceptable when it can reliably:

- Reuse its OpenCode terminal during one Neovim session.
- Send files, selections, diagnostics, quickfix entries, and terminal output.
- Reload files changed by OpenCode without losing local edits.
- Keep prompts and keymaps faster or clearer than the current Sidekick flow.
- Report an accurate active agent in Lualine.
- Start cleanly when OpenCode is unavailable on another machine.

The work-only Copilot workflow is acceptable when it can reliably:

- Remain completely inactive at home.
- Authenticate and attach only on the work machine.
- Avoid conflicts with Blink completion and snippet navigation.
- Provide useful inline suggestions without excessive visual noise.
- Support CodeCompanion chat and explicit accept-or-reject inline edits.

## Decision After Trial

Remove Sidekick if CodeCompanion covers the OpenCode CLI workflow and tmux
persistence is not missed.

Keep Sidekick in a reduced role only if its persistent CLI sessions or richer
Copilot Next Edit Suggestions provide clear value. If retained, CodeCompanion
should own chat and prompted edits while Sidekick owns only the non-overlapping
feature.

## Verification

- Run Neovim without `NVIM_APPNAME` on both switch states.
- Run `:checkhealth codecompanion` and `:checkhealth copilot` where applicable.
- Verify OpenCode context sending and file reload behavior.
- Verify Copilot authentication, attachment exclusions, and Blink interaction.
- Verify Lualine states with no AI, OpenCode active, Copilot ready, and Copilot busy.
- Inspect startup messages and the scoped bare-repository diff before handoff.

## Deferred Work

- OpenCode web or remote server attachment.
- CodeCompanion ACP for OpenCode-native chat.
- Persistent CodeCompanion chat history.
- MCP, memory, background workflows, and additional providers.
- Fidget or richer LSP progress messages.
- Copilot Next Edit Suggestions.
