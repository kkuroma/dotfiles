Name = "power-profile"
NamePretty = "Power Profile"
Icon = "battery"
Cache = false

local profiles = {
    { name = "performance", label = "Performance", icon = "" },
    { name = "balanced",    label = "Balanced",    icon = "" },
    { name = "power-saver", label = "Power Saver", icon = "" },
}

function GetEntries()
    local current = ""
    local h = io.popen("powerprofilesctl get 2>/dev/null")
    if h then
        current = h:read("*l") or ""
        h:close()
    end

    local entries = {}
    for _, p in ipairs(profiles) do
        local text = p.label
        if p.name == current then
            text = "[Active] " .. text
        end
        table.insert(entries, {
            Text = text,
            Value = p.name,
            Icon = p.icon,
            Actions = { activate = "lua:SetProfile" },
        })
    end
    return entries
end

function SetProfile(value)
    os.execute("powerprofilesctl set " .. value)
    os.execute("notify-send -a 'System' 'Power Profile' 'Switched to " .. value .. "' -i preferences-desktop")
end

Action = ""
