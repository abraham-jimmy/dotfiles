-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- Window bar
config.window_decorations = "RESIZE"
-- config.show_tabs_in_tab_bar = false
config.use_fancy_tab_bar = false
-- config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
  left = 3,
  right = 1,
  top = 5,
  bottom = 0,
}

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

config.audible_bell = 'Disabled'

-- or, changing the font size and color scheme.
config.font_size = 12
config.font = wezterm.font_with_fallback {
  { family = "JetBrains Mono",         weight = 'Medium' },
  { family = "Symbols Nerd Font Mono", scale = 0.67 }
}

config.color_scheme = 'Catppuccin Mocha'

-- Finally, return the configuration to wezterm:
return config
