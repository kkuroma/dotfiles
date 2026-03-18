Name = "apply-wallpaper"
NamePretty = "Pick Color & Scheme"
Icon = "color-select"
Cache = false

local state_dir = os.getenv("HOME") .. "/.cache/walker-wallpaper/"
local color_cache = state_dir .. "colors/"

local schemes = {
    "scheme-content",
    "scheme-expressive",
    "scheme-vibrant",
    "scheme-tonal-spot",
    "scheme-rainbow",
    "scheme-fruit-salad",
}

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
    return false
end

function GetEntries()
    local entries = {}

    local color_data = read_file(state_dir .. "colors.txt")
    if not color_data then return entries end

    for hex in color_data:gmatch("#(%x+)") do
        local swatch = color_cache .. hex .. ".png"
        local icon = file_exists(swatch) and swatch or ""

        for _, scheme in ipairs(schemes) do
            local scheme_short = scheme:gsub("scheme%-", "")
            table.insert(entries, {
                Text = "#" .. hex,
                Subtext = scheme_short,
                Value = hex .. "|" .. scheme,
                Icon = icon,
            })
        end
    end

    -- Fixed themes
    local fixed_themes = {
        { name = "Gruvbox",    icon = "📻", value = "gruvbox" },
        { name = "Catppuccin", icon = "🐱", value = "catppuccin" },
        { name = "Rosé Pine",  icon = "🌹", value = "rosepine" },
        { name = "Kanagawa",   icon = "🏯", value = "kanagawa" },
        { name = "Everforest", icon = "🌲", value = "everforest" },
        { name = "Ocean",      icon = "🌊", value = "ocean" },
    }
    for _, theme in ipairs(fixed_themes) do
        table.insert(entries, {
            Text = theme.name,
            Subtext = "fixed-themes",
            Value = "fixed|" .. theme.value,
            Icon = theme.icon,
        })
    end

    return entries
end

Action = os.getenv("HOME") .. "/.config/elephant/scripts/apply-wallpaper.sh '%VALUE%'"
