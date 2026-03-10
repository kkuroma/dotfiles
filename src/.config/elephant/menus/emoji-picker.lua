Name = "emoji-picker"
NamePretty = "Emoji Picker"
Icon = "face-smile"
Cache = true

local json_path = os.getenv("HOME") .. "/.config/elephant/emoji-en-US.json"

local function title_case(s)
    return s:gsub("_", " "):gsub("(%a)([%w]*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

function GetEntries()
    local f = io.open(json_path, "r")
    if not f then return {} end
    local raw = f:read("*a")
    f:close()

    local entries = {}

    for emoji, arr in raw:gmatch('"([^"]+)"%s*:%s*(%b[])') do
        local keywords = {}
        for val in arr:gmatch('"([^"]+)"') do
            table.insert(keywords, val)
        end

        if #keywords > 0 then
            local name = table.remove(keywords, 1)
            local text = title_case(name)
            local subtext = table.concat(keywords, ", ")

            table.insert(entries, {
                Text = text,
                Subtext = subtext,
                Icon = emoji,
                Value = emoji,
            })
        end
    end

    return entries
end

function CopyEmoji(value)
    os.execute("wl-copy '" .. value .. "'")
    os.execute("notify-send -a 'System' 'Emoji Picker' 'Copied " .. value .. " to clipboard' -i face-smile")
end

Action = "lua:CopyEmoji"
