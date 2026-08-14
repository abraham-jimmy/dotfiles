# Desktop

- `$HOME/.config/hypr/hyprland.lua` is the active Hyprland configuration. Legacy `.conf` files are migration references; related Hypr tools remain on Hyprlang where required.
- Hyprpaper is owned by its user service. Waybar starts from the Hyprland Lua configuration through UWSM.
- Waybar's workspace presentation depends on monitor-specific Hyprland workspace assignments and scripts under `$HOME/.config/waybar/modules`; review both sides when changing workspace behavior.
- `$HOME/.config/autostart` contains user XDG overrides that suppress X11-only applications in the Hyprland Wayland session.

Read the active Lua, Waybar JSON/CSS/scripts, and service definitions for current monitor names, workspace ranges, widgets, and commands.
