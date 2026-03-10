Name = "icon-picker"
NamePretty = "Icon Picker"
Icon = "preferences-desktop"
Cache = false

local json_path = os.getenv("HOME") .. "/.config/elephant/nerd-icons.json"

local function title_case(s)
    return s:gsub("(%a)([%w]*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

function GetEntries()
    local f = io.open(json_path, "r")
    if not f then return {} end
    local raw = f:read("*a")
    f:close()

    local entries = {}

    for icon, name in raw:gmatch('"icon"%s*:%s*"([^"]+)"%s*,%s*"name"%s*:%s*"([^"]+)"') do
        local nf_type, icon_name = name:match("^nf%-(.-)%-(.+)$")
        local text
        if nf_type and icon_name then
            text = title_case(icon_name:gsub("_", " ")) .. " (" .. title_case(nf_type) .. ")"
        else
            text = name
        end

        table.insert(entries, {
            Text = text,
            Subtext = name,
            Value = icon,
            Icon = icon,
        })
    end

    return entries
end

function CopyIcon(value)
    os.execute("wl-copy '" .. value .. "'")
    os.execute("notify-send -a 'System' 'Icon Picker' 'Copied: " .. value .. "' -i preferences-desktop")
end

Action = "lua:CopyIcon"
