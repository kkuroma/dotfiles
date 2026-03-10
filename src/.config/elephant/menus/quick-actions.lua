Name = "quick-actions"
NamePretty = "Quick Actions"
Cache = false

local scripts = os.getenv("HOME") .. "/.config/elephant/scripts/"

function GetEntries()
    -- Check hypridle status
    local hypridle_running = false
    local h = io.popen("pgrep -x hypridle 2>/dev/null")
    if h then
        local pid = h:read("*l")
        hypridle_running = (pid ~= nil and pid ~= "")
        h:close()
    end

    local timeout_text = hypridle_running and "Timeout (Active)" or "Timeout (Inactive)"
    local timeout_icon = hypridle_running and "" or ""
    local timeout_cmd = hypridle_running
        and "pkill hypridle && notify-send -a 'System' 'Screen Timeout' 'Disabled' -i preferences-desktop"
        or "hypridle & notify-send -a 'System' 'Screen Timeout' 'Enabled' -i preferences-desktop"

    local entries = {
        {
            Text = "Keybinds",
            Value = "keybinds",
            Icon = "",
            Actions = { activate = "walker -m menus:cheatsheet" },
        },
        {
            Text = timeout_text,
            Value = "timeout",
            Icon = timeout_icon,
            Actions = { activate = timeout_cmd },
        },
        {
            Text = "Layout",
            Value = "layout",
            Icon = "",
            Actions = { activate = "walker -m menus:layout-switcher" },
        },
        {
            Text = "Screenshot",
            Value = "screenshot",
            Icon = "󰹑",
            Actions = { activate = os.getenv("HOME") .. "/.config/hypr/scripts/take-screenshot.sh" },
        },
        {
            Text = "Clipboard",
            Value = "clipboard",
            Icon = "",
            Actions = { activate = "walker --provider clipboard" },
        },
        {
            Text = "Emojis",
            Value = "emojis",
            Icon = "󰞅",
            Actions = { activate = "walker -m menus:emoji-picker" },
        },
        {
            Text = "Icons",
            Value = "icons",
            Icon = "",
            Actions = { activate = "walker -m menus:icon-picker" },
        },
        {
            Text = "Color Picker",
            Value = "picker",
            Icon = "",
            Actions = { activate = os.getenv("HOME") .. "/.config/elephant/scripts/color-picker.sh" },
        },
        {
            Text = "VPN",
            Value = "vpn",
            Icon = "",
            Actions = { activate = "walker -m menus:tailscale" },
        },
        {
            Text = "Packages",
            Value = "packages",
            Icon = "",
            Actions = { activate = "walker -m menus:packages" },
        },
        {
            Text = "Bluetooth",
            Value = "bluetooth",
            Icon = "",
            Actions = { activate = "walker -m bluetooth" },
        },
        {
            Text = "Power Profile",
            Value = "power",
            Icon = "󰁹",
            Actions = { activate = "walker -m menus:power-profile" },
        }
    }

    return entries
end

Action = ""
