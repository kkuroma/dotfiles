Name = "choose-wallpaper"
NamePretty = "Choose Wallpaper"
Icon = "preferences-desktop-wallpaper"
Cache = false

local wall_dir = os.getenv("HOME") .. "/Pictures/Wallpapers/"
local cache_dir = os.getenv("HOME") .. "/.cache/wallpaper-thumbnails/"
local thumb_dir = os.getenv("HOME") .. "/Pictures/Thumbnails/"

local image_exts = { jpg = true, jpeg = true, png = true, gif = true, webp = true }
local video_exts = { mp4 = true, webm = true }

local function get_ext(filename)
    return filename:match("%.([^%.]+)$"):lower()
end

local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
    return false
end

local function get_thumbnail(filename, full_path)
    local base = filename:match("(.+)%.[^%.]+$")
    local ext = get_ext(filename)
    local thumb = cache_dir .. base .. ".png"

    if file_exists(thumb) then
        return thumb
    end

    if video_exts[ext] then
        local full_thumb = thumb_dir .. base .. ".jpg"
        if not file_exists(full_thumb) then
            os.execute("ffmpeg -i '" .. full_path .. "' -vframes 1 -q:v 2 '" .. full_thumb .. "' -y 2>/dev/null")
        end
        if file_exists(full_thumb) then
            os.execute("magick '" .. full_thumb .. "' -resize 200x200^ -gravity center -extent 200x200 '" .. thumb .. "' 2>/dev/null")
        end
    elseif image_exts[ext] then
        os.execute("magick '" .. full_path .. "[0]' -resize 200x200^ -gravity center -extent 200x200 +adjoin '" .. thumb .. "' 2>/dev/null")
    end

    if file_exists(thumb) then
        return thumb
    end
    return nil
end

function GetEntries()
    os.execute("mkdir -p '" .. cache_dir .. "'")
    os.execute("mkdir -p '" .. thumb_dir .. "'")

    local entries = {}
    local handle = io.popen("find '" .. wall_dir .. "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' -o -iname '*.webm' -o -iname '*.mp4' \\) -printf '%f\\n' | sort")
    if handle then
        for filename in handle:lines() do
            local full_path = wall_dir .. filename
            local thumb = get_thumbnail(filename, full_path)
            local scripts = os.getenv("HOME") .. "/.config/elephant/scripts/"
            local ext = get_ext(filename)

            -- For images, preview the source file; for videos, preview the extracted frame
            local preview_path = full_path
            if video_exts[ext] then
                local base = filename:match("(.+)%.[^%.]+$")
                local frame = thumb_dir .. base .. ".jpg"
                if file_exists(frame) then
                    preview_path = frame
                end
            end

            table.insert(entries, {
                Text = filename,
                Value = full_path,
                Icon = thumb or full_path,
                Preview = preview_path,
                PreviewType = "file",
                Actions = {
                    activate = scripts .. "wallpaper-bridge.sh '" .. full_path .. "'",
                    quick_apply = scripts .. "quick-apply-wallpaper.sh '" .. full_path .. "'",
                },
            })
        end
        handle:close()
    end
    return entries
end

Action = os.getenv("HOME") .. "/.config/elephant/scripts/wallpaper-bridge.sh '%VALUE%'"
