Name = "layout-switcher"
NamePretty = "Layout Switcher"
Icon = "preferences-desktop-display"
Cache = true

local scripts = os.getenv("HOME") .. "/.config/hypr/scripts/"
local icons_dir = os.getenv("HOME") .. "/.config/hypr/icons/"

local layouts = {
    { name = "dwindle",   icon = icons_dir .. "dwindle.svg" },
    { name = "master",    icon = icons_dir .. "master.svg" },
    { name = "scrolling", icon = icons_dir .. "scrolling.svg" },
    { name = "monocle",   icon = icons_dir .. "monocle.svg" },
}

function GetEntries()
    local entries = {}
    for _, layout in ipairs(layouts) do
        table.insert(entries, {
            Text = layout.name,
            Value = layout.name,
            Icon = layout.icon,
            Actions = {
                activate = "lua:ApplyLayout",
            },
        })
    end
    return entries
end

function ApplyLayout(value)
    os.execute(scripts .. "layout-switch.sh " .. value)
    os.execute("hyprctl dispatch layoutmsg setlayout " .. value)
    os.execute("notify-send -a 'System' -i '" .. icons_dir .. value .. ".svg' 'Hyprland Layout' 'Set layout to: " .. value .. "'")
end

Action = ""
