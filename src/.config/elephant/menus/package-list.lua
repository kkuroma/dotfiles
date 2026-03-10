Name = "package-list"
NamePretty = "Package List"
Icon = "system-software-install"
Cache = false

local state_dir = os.getenv("HOME") .. "/.cache/walker-packages/"
local icons = {
    explicit = "",
    aur = "",
    dep = "",
}

function GetEntries()
    local f = io.open(state_dir .. "packages.txt", "r")
    if not f then return {} end

    local entries = {}

    for line in f:lines() do
        local tag, name, version = line:match("^(%S+) (%S+) (%S+)")
        if tag and name and version then
            table.insert(entries, {
                Text = name,
                Subtext = version,
                Value = name,
                Icon = icons[tag] or "",
            Actions = { activate = "lua:CopyName" },
            })
        end
    end

    f:close()
    return entries
end

function CopyName(value)
    os.execute("wl-copy '" .. value .. "'")
    os.execute("notify-send -a 'System' 'Package List' 'Copied: " .. value .. "' -i system-software-install")
end

Action = "lua:CopyName"
