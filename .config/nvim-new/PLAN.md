# Neovim Configuration Cleanup Plan

## Preserve

- Keep both `mini.files` and `nvim-tree`; they serve different workflows.
- Keep `ascii.nvim` and the randomized dashboard header.
- Keep Catppuccin and Kanagawa for the external theme switcher.
- Keep `mini.indentscope` and trailing-space markers.
- Keep `<leader>ll` for manually running configured linters.

## Plugin Structure

- Use one file per plugin under `lua/plugins/`.
- Put each plugin's `vim.pack.add(...)` declaration at the top of its file.
- Keep an ordered plugin loader for explicit dependency ordering.
- Split custom CodeDiff dotfiles integration from CodeDiff plugin setup.

## Key Hints

- Replace `mini.clue` and `util/clue_panel.lua` with `which-key.nvim`.
- Let WhichKey read actual global and buffer-local mappings from their `desc` fields.
- Keep only explicit leader-group labels that cannot be inferred.
- Use `<leader>?` to show mappings for the current buffer.
- Remove MiniClue and custom clue-panel hooks from LSP, explorers, and CodeDiff.

## Linting

- Preserve automatic linting and `<leader>ll`.
- Keep ShellCheck for `sh`, Ruff for Python, and Zsh syntax linting for `zsh`.
- Replace the broken Zsh `/dev/stdin` invocation with filename-based linting.
- Verify that each configured linter publishes diagnostics.

## Cleanup And Fixes

- Remove the inactive `nvim-colorizer.lua` package.
- Remove the stale `nvim` lock entry that duplicates Catppuccin.
- Remove the empty `lang/tmux.lua` module.
- Remove `> > >` tab markers without removing trailing-space markers.
- Fix root detection for new files and path boundaries.
- Prioritize Python project markers over an outer Git root.
- Make the inline-diagnostics toggle actually disable inline diagnostics.
- Avoid synchronous tmux updates on repeated navigation events.
- Remove contradictory `formatoptions` configuration.
- Do not remove other plugins as part of this cleanup.

## Verification

- Run headless startup and Lua syntax checks.
- Run `:checkhealth which-key`.
- Test WhichKey with normal, LSP, `mini.files`, `nvim-tree`, and CodeDiff mappings.
- Test ShellCheck, Ruff, and Zsh diagnostics through `<leader>ll`.
- Test both explorers, the dashboard, theme switching, CodeDiff, and indent display.
- Compare startup timing with the current baseline of approximately 154 ms.
- Inspect the scoped bare-repository diff and run `diff --check`.
- Do not stage or commit without explicit approval.
