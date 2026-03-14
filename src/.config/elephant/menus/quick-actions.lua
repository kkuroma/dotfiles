Name = "quick-actions"
NamePretty = "Quick Actions"
Cache = false

local fetch_bin = os.getenv("HOME") .. "/.config/elephant/fetch/fetch"

local function run_fetch()
    local f = io.popen(fetch_bin)
    if not f then return {} end
    local data = {}
    for line in f:lines() do
        local k, v = line:match("^(%w+)=(.*)$")
        if k then data[k] = v end
    end
    f:close()
    return data
end

local function get_hypr_layout()
    local f = io.popen("hyprctl activeworkspace -j")
    if not f then return "N/A" end
    local json = f:read("*a")
    f:close()
    return json:match('"tiledLayout"%s*:%s*"([^"]+)"') or "N/A"
end

function GetEntries()
    local d = run_fetch()
    local hypr_layout = get_hypr_layout()

    local hypridle_running = d.hypridle == "1"
    local timeout_subtext = hypridle_running and "Current: active" or "Current: inactive"
    local timeout_icon = hypridle_running and "" or ""
    local timeout_cmd = hypridle_running
        and "pkill hypridle && notify-send -a 'System' 'Screen Timeout' 'Disabled' -i preferences-desktop"
        or "hypridle & notify-send -a 'System' 'Screen Timeout' 'Enabled' -i preferences-desktop"

    local bt_on = d.bluetooth == "1"
    local current_bluetooth = bt_on and "Powered: On" or "Powered: Off"
    local bluetooth_icon = bt_on and "󰂯" or "󰂲"

    local tailscale_ip = d.tailscale or ""
    local tailscale_location = tailscale_ip ~= "" and ("Connected: " .. tailscale_ip) or "Not Connected"

    local num_packages = d.packages or "N/A"
    local current_power_profile = d.power or ""

    local entries = {
        {
            Text = "Keybinds",
            Value = "keybinds",
            Subtext = "View Keybinds",
            Icon = "",
            Actions = { activate = "walker -m menus:cheatsheet" },
        },
        {
            Text = "Screen Timeout",
            Value = "timeout",
            Subtext = timeout_subtext,
            Icon = timeout_icon,
            Actions = { activate = timeout_cmd },
        },
        {
            Text = "Layout",
            Value = "layout",
            Subtext = "Current: " .. hypr_layout,
            Icon = "",
            Actions = { activate = "walker -m menus:layout-switcher" },
        },
        {
            Text = "Screenshot",
            Value = "screenshot",
            Subtext = "Take Screenshot",
            Icon = "󰹑",
            Actions = { activate = "setsid sh -c ~/.config/hypr/scripts/take-screenshot.sh &" },
        },
        {
            Text = "Clipboard",
            Value = "clipboard",
            Subtext = "Open Clipboard",
            Icon = "",
            Actions = { activate = "walker --provider clipboard" },
        },
        {
            Text = "Emojis",
            Value = "emojis",
            Subtext = "Pick Emoji",
            Icon = "󰞅",
            Actions = { activate = "walker -m menus:emoji-picker" },
        },
        {
            Text = "Icons",
            Value = "icons",
            Subtext = "Pick Nerd Font Icon",
            Icon = "",
            Actions = { activate = "walker -m menus:icon-picker" },
        },
        {
            Text = "Color Picker",
            Value = "picker",
            Subtext = "Pick Hex Color",
            Icon = "",
            Actions = { activate = "setsid sh -c ~/.config/hypr/scripts/color-picker.sh &" },
        },
        {
            Text = "Tailscale VPN",
            Value = "vpn",
            Subtext = tailscale_location,
            Icon = "",
            Actions = { activate = "walker -m menus:tailscale" },
        },
        {
            Text = "Packages",
            Value = "packages",
            Subtext = "" .. num_packages .. " installed",
            Icon = "",
            Actions = { activate = "walker -m menus:packages" },
        },
        {
            Text = "Bluetooth",
            Value = "bluetooth",
            Subtext = current_bluetooth,
            Icon = bluetooth_icon,
            Actions = { activate = "walker -m bluetooth" },
        },
        {
            Text = "Power Profile",
            Value = "power",
            Subtext = "Active: " .. current_power_profile,
            Icon = "󰁹",
            Actions = { activate = "walker -m menus:power-profile" },
        },
        {
            Text = "Code Launcher",
            Value = "code",
            Subtext = "Launch File in IDE",
            Icon = "",
            Actions = { activate = "kitty --class floating -e sh -c '~/.config/hypr/scripts/code-launcher.sh 0'" },
        },
        {
            Text = "App Launcher",
            Value = "app",
            Subtext = "Open Apps",
            Icon = "󱃷",
            Actions = { activate = "walker" },
        }
    }

    return entries
end

Action = ""
