local mainMod = "SUPER"
local terminal = "alacritty"
local browser = "google-chrome-stable"
local appLauncher = "rofi -show drun"

local monitors = {
    middle = "ASUSTek COMPUTER INC VG27B L2LMQS041890",
    right = "ASUSTek COMPUTER INC VG27B K7LMQS089435",
}

local colors = {
    sky = "rgb(91d7e3)",
    base = "rgb(24273a)",
    lavender = "rgb(b7bdf8)",
    mellowRed = "rgb(c66a73)",
}

hl.monitor({
    output = "desc:" .. monitors.middle,
    mode = "2560x1440@143.97",
    position = "1440x0",
    scale = 1,
})
hl.monitor({
    output = "desc:" .. monitors.right,
    mode = "2560x1440@143.97",
    position = "4000x0",
    scale = 1,
})
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.config({
    input = {
        sensitivity = -0.8,
        follow_mouse = 0,
        float_switch_override_focus = 2,
        kb_layout = "se",
        kb_options = "caps:escape",
    },
    cursor = {
        no_warps = true,
    },
    general = {
        gaps_in = 2,
        gaps_out = 2,
        border_size = 1,
        col = {
            active_border = colors.sky,
            inactive_border = colors.base,
        },
        layout = "dwindle",
        resize_on_border = true,
        extend_border_grab_area = 30,
        hover_icon_on_border = true,
        snap = {
            enabled = true,
        },
    },
    decoration = {
        active_opacity = 1,
        rounding = 2,
        blur = {
            size = 5,
            passes = 2,
            xray = true,
        },
        shadow = {
            enabled = false,
        },
    },
    misc = {
        font_family = "JetBrainsMono Nerd Font",
        splash_font_family = "JetBrainsMono Nerd Font",
        disable_hyprland_logo = true,
        col = {
            splash = colors.lavender,
        },
    },
    animations = {
        enabled = true,
    },
    binds = {
        allow_workspace_cycles = true,
        workspace_back_and_forth = true,
        workspace_center_on = 1,
        movefocus_cycles_fullscreen = true,
        window_direction_monitor_fallback = true,
    },
})

hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind" })

local workspaceMonitors = {
    [1] = monitors.middle,
    [2] = monitors.middle,
    [3] = monitors.middle,
    [4] = monitors.right,
    [5] = monitors.right,
    [6] = monitors.right,
    [7] = monitors.right,
    [8] = monitors.right,
    [9] = monitors.right,
    [10] = monitors.right,
}

for workspace, monitor in pairs(workspaceMonitors) do
    local persistent = workspace == 1 or workspace == 4 or workspace == 8
    hl.workspace_rule({
        workspace = tostring(workspace),
        monitor = "desc:" .. monitor,
        persistent = persistent,
        default = persistent,
    })
end

hl.workspace_rule({
    workspace = "special:special-obsidian",
    monitor = "desc:" .. monitors.right,
    gaps_out = 15,
})

local function windowRule(name, match, effects)
    effects.name = name
    effects.match = match
    hl.window_rule(effects)
end

windowRule("suppress-fullscreen-events", { class = ".*" }, {
    suppress_event = "fullscreen",
})

windowRule("fix-xwayland-drags", {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
}, {
    no_focus = true,
})

windowRule("fullscreen-games", { class = "^(steam_app_.*|gow\\.exe)$" }, {
    fullscreen = true,
    workspace = 2,
})

windowRule("float-utility-apps", {
    class = "^(org\\.pulseaudio\\.pavucontrol|dev\\.jimmy\\.opengl_game|blueman-manager|CachyOSHello|zenity|org\\.gnome\\.Calculator)$",
}, {
    float = true,
})

windowRule("float-empty-class-dialogs", {
    class = "^$",
    title = "^(Picture in picture|Save File|Open File)$",
}, {
    float = true,
})

windowRule("float-librewolf-pip", {
    class = "^LibreWolf$",
    title = "^Picture-in-Picture$",
}, {
    float = true,
})

windowRule("float-portals", {
    class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland).*$",
}, {
    float = true,
})

windowRule("float-polkit", {
    class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1).*$",
}, {
    float = true,
})

windowRule("float-steam-friends", {
    class = "^steam$",
    title = "^Friends List$",
}, {
    float = true,
})

windowRule("float-steam-updater", {
    class = "^$",
    title = "^Steam - Self Updater$",
}, {
    float = true,
})

windowRule("opacity-file-managers", { class = "^(thunar|nemo)$" }, { opacity = 0.92 })
windowRule("opacity-chat", { class = "^(discord|armcord|webcord)$" }, { opacity = 0.96 })
windowRule("opacity-messaging", { title = "^(QQ|Telegram)$" }, { opacity = 0.95 })
windowRule("opacity-music", { title = "^NetEase Cloud Music Gtk4$" }, { opacity = 0.95 })

windowRule("picture-in-picture", { title = "^Picture-in-Picture$" }, {
    float = true,
    size = "960 540",
    move = "monitor_w*0.25 monitor_h*0.25",
})

windowRule("floating-media", { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$" }, {
    float = true,
    size = "960 540",
    move = "monitor_w*0.25 monitor_h*0.25",
})

windowRule("pin-danmufloat", { title = "^danmufloat$" }, { pin = true })
windowRule("round-floating-tools", { title = "^(danmufloat|termfloat)$" }, { rounding = 5 })
windowRule("animate-terminals", { class = "^(kitty|Alacritty|ghostty|wezterm)$" }, { animation = "slide right" })

hl.workspace_rule({ workspace = "w[t1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "w[tg1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

windowRule("smart-gaps-tiled", { float = false, workspace = "w[t1]" }, {
    border_size = 0,
    rounding = 0,
})
windowRule("smart-gaps-grouped", { float = false, workspace = "w[tg1]" }, {
    border_size = 0,
    rounding = 0,
})
windowRule("smart-gaps-fullscreen", { float = false, workspace = "f[1]" }, {
    border_size = 0,
    rounding = 0,
})

windowRule("highlight-special-obsidian", {
    workspace = "special:special-obsidian",
    float = false,
}, {
    border_size = 3,
    border_color = colors.mellowRed .. " " .. colors.mellowRed,
})

windowRule("ferdium-workspace", { class = "^Ferdium$" }, { workspace = "4 silent" })
windowRule("spotify-workspace", { class = "^Spotify$" }, { workspace = "special:special-obsidian silent" })
windowRule("steam-workspace", { class = "^steam$" }, { workspace = "6 silent" })
windowRule("thunderbird-workspace", { class = "^thunderbird$" }, { workspace = "7 silent" })
windowRule("obsidian-workspace", { class = "^(obsidian|md[.]obsidian[.]Obsidian)$" }, {
    workspace = "special:special-obsidian silent",
})

local function bind(keys, description, dispatcher, options)
    options = options or {}
    options.description = description
    hl.bind(keys, dispatcher, options)
end

bind(mainMod .. " + RETURN", "Open terminal", hl.dsp.exec_cmd(terminal))
bind(mainMod .. " + CTRL + RETURN", "Open terminal", hl.dsp.exec_cmd(terminal))
bind(mainMod .. " + B", "Open browser", hl.dsp.exec_cmd(browser))
bind(mainMod .. " + SPACE", "Open application launcher", hl.dsp.exec_cmd(appLauncher))
bind(mainMod .. " + Q", "Close active window", hl.dsp.window.close())
bind(mainMod .. " + V", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + M", "Toggle fullscreen", hl.dsp.window.fullscreen({ action = "toggle" }))
bind(mainMod .. " + Y", "Pin active window", hl.dsp.window.pin({ action = "toggle" }))
bind(mainMod .. " + S", "Rotate dwindle split", hl.dsp.layout("rotatesplit"))
bind(mainMod .. " + Tab", "Focus next grouped window", hl.dsp.group.next())
bind(mainMod .. " + CTRL + L", "Lock screen", hl.dsp.exec_cmd("hyprlock"))
bind(mainMod .. " + SHIFT + S", "Capture selected area", hl.dsp.exec_cmd("/home/jimmy/.config/hypr/scripts/screenshot_area.sh"))
bind(mainMod .. " + Print", "Capture current output", hl.dsp.exec_cmd("/home/jimmy/.config/hypr/scripts/screenshot.sh"))
bind(mainMod .. " + CTRL + P", "Reload Waybar", hl.dsp.exec_cmd("killall -SIGUSR2 waybar"))

local directions = {
    left = "left",
    right = "right",
    up = "up",
    down = "down",
    h = "left",
    l = "right",
    k = "up",
    j = "down",
}

for key, direction in pairs(directions) do
    bind(mainMod .. " + " .. key, "Move focus " .. direction, hl.dsp.focus({ direction = direction }))
    bind(mainMod .. " + SHIFT + " .. key, "Move window " .. direction, hl.dsp.window.move({ direction = direction }))
end

local resizeDeltas = {
    right = { 15, 0 },
    left = { -15, 0 },
    up = { 0, -15 },
    down = { 0, 15 },
    l = { 15, 0 },
    h = { -15, 0 },
    k = { 0, -15 },
    j = { 0, 15 },
}

for key, delta in pairs(resizeDeltas) do
    bind(mainMod .. " + CTRL + SHIFT + " .. key, "Resize window", hl.dsp.window.resize({
        x = delta[1],
        y = delta[2],
        relative = true,
    }))
end

bind(mainMod .. " + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

for workspace = 1, 10 do
    local key = workspace % 10
    bind(mainMod .. " + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = workspace }))
    bind(mainMod .. " + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({
        workspace = workspace,
        follow = false,
    }))
end

bind(mainMod .. " + PERIOD", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + COMMA", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
bind(mainMod .. " + mouse_down", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + mouse_up", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
bind(mainMod .. " + slash", "Previously used workspace", hl.dsp.focus({ workspace = "previous" }))
bind(mainMod .. " + minus", "Move window to special workspace", hl.dsp.window.move({ workspace = "special", follow = true }))
bind(mainMod .. " + plus", "Toggle special workspace", hl.dsp.workspace.toggle_special("special"))
bind(mainMod .. " + F1", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
bind(mainMod .. " + ALT + SHIFT + F1", "Move window to scratchpad", hl.dsp.window.move({
    workspace = "special:scratchpad",
    follow = false,
}))
bind(mainMod .. " + O", "Toggle Obsidian workspace", hl.dsp.workspace.toggle_special("special-obsidian"))

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
end)
