local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 3,
	right = 1,
	top = 5,
	bottom = 0,
}

config.initial_cols = 120
config.initial_rows = 28

config.audible_bell = "Disabled"

config.font_size = 12
config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono", weight = "Medium" },
	{ family = "Symbols Nerd Font Mono", scale = 0.67 },
})

local theme_ok, theme = pcall(dofile, wezterm.home_dir .. "/.config/themes/generated/wezterm.lua")
if theme_ok and type(theme) == "table" then
	for key, value in pairs(theme) do
		config[key] = value
	end
else
	config.color_scheme = "Catppuccin Mocha"
end

config.hide_mouse_cursor_when_typing = false

return config
