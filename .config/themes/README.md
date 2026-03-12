# Themes

Shared theme source of truth for terminal, editor, and TUI profiles.

## Layout

- `theme-switch`: apply, validate, preview, and inspect the active theme.
- `current`: active theme id.
- `profiles/<theme>/`: per-theme source files.
- `generated/`: stable generated files for app configs to consume.

Each profile contains:

- `manifest.sh`: theme metadata used by `theme-switch`.
- `nvim.lua`: Lazy plugin/colorscheme payload for `~/.config/nvim`.
- `nvim-new.lua`: theme payload for `~/.config/nvim-new`.
- `tmux.conf`: tmux statusline color variables.
- `wezterm.lua`: WezTerm color scheme payload.
- `alacritty.toml`: Alacritty color import snippet.

Generated outputs:

- `generated/nvim.lua`
- `generated/nvim-new.lua`
- `generated/tmux.conf`
- `generated/wezterm.lua`
- `generated/alacritty.toml`

## Supported Themes

- `kanagawa-dragon`
- `catppuccin`

## Usage

```bash
~/.config/themes/theme-switch list
~/.config/themes/theme-switch current
~/.config/themes/theme-switch validate kanagawa-dragon
~/.config/themes/theme-switch apply --dry-run catppuccin
~/.config/themes/theme-switch apply kanagawa-dragon
```

`theme-switch` updates `current`, refreshes the generated files, and updates the `theme` field in `~/.config/opencode/tui.json`.
