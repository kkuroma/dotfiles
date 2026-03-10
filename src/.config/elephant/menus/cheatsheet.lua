Name = "cheatsheet"
NamePretty = "Cheat Sheet"
Icon = "input-keyboard"
Cache = false

local binds_conf = os.getenv("HOME") .. "/.config/hypr/components/binds.conf"

-- Key name → icon/symbol substitutions (edit these as you like)
local key_icons = {
    ["$mainMod"]     = "",
    ["SUPER"]        = "",
    ["CTRL"]         = "󰘴",
    ["SHIFT"]        = "󰘶",
    ["ALT"]          = "Alt",
    ["SPACE"]        = "󱁐",
    ["ESCAPE"]       = "Esc",
    ["RETURN"]       = "↵",
    ["TAB"]          = "Tab",
    ["Print"]        = "PrtSc",
    ["bracketleft"]  = "[",
    ["bracketright"] = "]",
    ["backslash"]    = "\\",
    ["mouse:272"]    = "LMB",
    ["mouse:273"]    = "RMB",
    ["mouse_down"]   = "Scroll↓",
    ["mouse_up"]     = "Scroll↑",
    ["left"]         = "←",
    ["right"]        = "→",
    ["up"]           = "↑",
    ["down"]         = "↓",
    ["minus"]        = "−",
    ["equal"]        = "=",
    ["comma"]        = ",",
    ["period"]       = ".",
    ["tab"]          = "Tab",
}

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function substitute_key(key)
    local trimmed = trim(key)
    return key_icons[trimmed] or trimmed
end

local function parse_keys(bind_part)
    -- bind_part is like "$mainMod SHIFT, K"
    -- split on comma: first part is modifiers + key, rest is action
    local mods_and_key = bind_part:match("^([^,]+)")
    if not mods_and_key then return nil end

    local parts = {}
    for word in mods_and_key:gmatch("%S+") do
        table.insert(parts, substitute_key(word))
    end

    if #parts == 0 then return nil end

    return table.concat(parts, " + ")
end

function GetEntries()
    local entries = {}
    local f = io.open(binds_conf, "r")
    if not f then return entries end

    for line in f:lines() do
        -- only process bind lines with a comment
        local bind_part, comment = line:match("^bind[a-z]* = (.-)#(.+)$")
        if bind_part and comment then
            comment = trim(comment)

            -- extract modifiers + key (everything before the action)
            -- format: "MODS, key, action, args"
            local csv_parts = {}
            for part in bind_part:gmatch("[^,]+") do
                table.insert(csv_parts, trim(part))
            end

            if #csv_parts >= 2 then
                -- first csv part: modifiers, second: key name
                local mods = csv_parts[1]
                local key = csv_parts[2]

                local key_parts = {}
                -- split modifiers by space
                for word in mods:gmatch("%S+") do
                    local sub = substitute_key(word)
                    if sub ~= "" then
                        table.insert(key_parts, sub)
                    end
                end
                -- add the actual key
                local key_sub = substitute_key(key)
                if key_sub ~= "" then
                    table.insert(key_parts, key_sub)
                end

                local keys_str = table.concat(key_parts, " + ")

                if keys_str ~= "" and comment ~= "" then
                    table.insert(entries, {
                        Text = comment,
                        Subtext = keys_str,
                        Value = keys_str,
                    })
                end
            end
        end
    end

    f:close()
    return entries
end

Action = ""
