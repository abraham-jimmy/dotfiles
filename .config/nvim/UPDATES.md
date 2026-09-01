# Neovim Updates

This file contains only unfinished Neovim updates. Every `##` heading is one update, and every
requirement is a checkbox. Once all checkboxes under an update are marked, confirm with the user
that the update is complete before deleting that entire section. Never delete a completed update
without that confirmation.

## Definition Preview

- [ ] Confirm `gD` shows the expected definition snippet, offers a choice for multiple targets,
      and leaves `gd` as the direct jump.

## Web and .NET Tooling Validation

- [ ] Confirm each TypeScript buffer attaches exactly one `vtsls` client and uses the
      repository-pinned TypeScript SDK.
- [ ] Confirm hover, definition, rename, and cross-package navigation work after required generated
      outputs are built.
- [ ] Confirm compiler transforms do not cause editor-only type errors; record any required
      repository workaround if they do.
- [ ] Confirm ESLint diagnostics match each package's local lint command, including the legacy
      ESLint 6.8 fallback.
- [ ] Confirm the TSLint-only repository receives TSLint diagnostics only on save or manual lint and
      receives no ESLint diagnostics.
- [ ] Confirm Prettier matches repository output for TypeScript, JSON, YAML, Markdown, HTML, and CSS,
      respects ignore files, and completes within the format-on-save timeout.
- [ ] Confirm Lit and Polymer templates receive useful diagnostics without false positives from the
      disabled template rules.
- [ ] Confirm Roslyn loads the intended nested solution, navigates across projects, reports project
      analyzers, and formats with the nearest EditorConfig settings.
- [ ] Confirm the merged formatter and linter tables contain no duplicate or misordered entries.
- [ ] Confirm missing `node_modules` causes quiet degradation without repeated errors.
- [ ] Confirm Lualine reports the attached TypeScript, ESLint, and Roslyn clients accurately.

## Repository-Local Prettier

- [ ] Require an upward `node_modules/.bin/prettier` instead of allowing Conform to fall back to a
      global `prettier` executable.
- [ ] Confirm formatting skips configured repositories whose local Prettier installation is absent.

## Toolchain Prerequisites

- [ ] Decide whether Node.js and npm version checks belong in setup or remain owned by an external
      version manager, then implement the selected preflight.
- [ ] Ensure `jq` is installed by setup or explicitly checked as an external prerequisite.
- [ ] Confirm the installed .NET SDK and targeting packs can build both `net8.0` and
      `netstandard2.1` projects.

## PowerShell Support

- [ ] Add the available PowerShell Treesitter parser for `.ps1` highlighting.
- [ ] Decide whether actual PowerShell editing warrants `pwsh` and PowerShell Editor Services.

## Markdown Viewer

- [ ] Select an in-editor renderer or browser-preview plugin.
- [ ] Add the selected viewer through `vim.pack` without replacing Marksman or Prettier.
- [ ] Verify Markdown rendering and navigation on representative files.

## AI Integration Trial

- [ ] Add CodeCompanion and its active `vim.pack` dependencies with one standard `opencode` CLI
      agent while retaining Sidekick as the temporary fallback.
- [ ] Add trial workflows for files, selections, diagnostics, terminal output, quickfix entries, Git
      diffs, and multiple files or buffers without duplicating OpenCode sessions.
- [ ] Resolve trial mapping ownership under `<leader>a` without overriding useful Sidekick, Blink,
      LSP, or terminal mappings.
- [ ] Gate `copilot.lua` and CodeCompanion's Copilot interactions behind `NVIM_COPILOT=1`.
- [ ] Register and display Copilot-only mappings only while Copilot is loaded.
- [ ] Configure Copilot ghost text, a dedicated accept key, Blink-menu hiding, and attachment
      exclusions for special, unlisted, secret, and explicitly excluded buffers.
- [ ] Extend Lualine with CodeCompanion activity and verified attached, ready, busy, and warning
      states from `copilot.lua`.
- [ ] Validate CodeCompanion health, OpenCode context sending, file reloads, and Lualine state with
      Copilot disabled.
- [ ] Validate Copilot health, authentication, attachment filtering, Blink interaction, chat, inline
      edits, and Lualine state on the enabled work machine.
- [ ] Decide after the trial whether to remove Sidekick or retain only a non-overlapping role.

## Blink Snippet Completion

- [ ] Decide whether Blink should offer snippet candidates in addition to LSP snippet insertion and
      snippet navigation.
- [ ] If approved, add and verify a single snippet source without changing current `<Tab>` and
      `<S-Tab>` behavior.

## Optional XML Language Server

- [ ] Decide whether `.csproj`, XML, and pipeline editing warrants adding LemMinX; if approved,
      replace this decision with implementation and validation checkboxes.

## Optional Custom-Element Completion

- [ ] Decide whether standalone HTML needs `custom-elements-languageserver`; if approved, replace
      this decision with implementation and duplicate-diagnostic validation checkboxes.

## Optional SonarLint Connected Mode

- [ ] Decide whether connected SonarLint adds enough value beyond repository ESLint and Roslyn
      analyzers; if approved, replace this decision with scoped, secret-safe implementation and
      validation checkboxes before adding it.

## Deferred AI Scope

- [ ] After the AI trial, decide whether OpenCode remote attachment, ACP chat, persistent history,
      MCP, memory, background workflows, extra providers, or one Next Edit Suggestions
      implementation should become planned updates.
