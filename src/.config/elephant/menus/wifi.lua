Name = "wifi"
NamePretty = "WiFi"
Icon = "network-wireless"
Cache = false

function GetEntries()
    local entries = {}

    -- Get current connection
    local cur_handle = io.popen("nmcli -t -f NAME connection show --active 2>/dev/null | grep -v lo | head -n 1")
    local current = ""
    if cur_handle then
        current = cur_handle:read("*l") or ""
        cur_handle:close()
    end

    -- nmtui option
    table.insert(entries, {
        Text = "Open Network Manager TUI",
        Value = "nmtui",
        Actions = { activate = "kitty --class floating --title nmtui -e nmtui" },
    })

    -- Disconnect option if connected
    if current ~= "" then
        table.insert(entries, {
            Text = "Disconnect from: " .. current,
            Value = "disconnect:" .. current,
            Actions = { activate = "lua:Disconnect" },
        })
    end

    -- Scan and list networks
    os.execute("nmcli device wifi rescan 2>/dev/null")

    local handle = io.popen("nmcli -t -f SSID,SECURITY,SIGNAL device wifi list 2>/dev/null | sort -t: -k3 -rn | awk -F: '!seen[$1]++'")
    if handle then
        for line in handle:lines() do
            local ssid, security, signal = line:match("^(.-):(.-):(.*)")
            if ssid and ssid ~= "" then
                local sec_text = (security == "--" or security == "") and "Open" or security
                local text = ssid .. " (" .. sec_text .. ") " .. signal .. "%"

                table.insert(entries, {
                    Text = text,
                    Subtext = ssid,
                    Value = ssid,
                    Actions = { activate = "lua:ConnectWifi" },
                })
            end
        end
        handle:close()
    end

    return entries
end

function Disconnect(value)
    local ssid = value:match("^disconnect:(.+)$")
    if ssid then
        os.execute("nmcli connection down '" .. ssid .. "' 2>/dev/null")
        os.execute("notify-send -a 'System' 'WiFi Manager' 'Disconnected from " .. ssid .. "' -i network-wireless")
    end
end

function ConnectWifi(value)
    -- Check if we already have a saved profile
    local saved = false
    local h = io.popen("nmcli -t -f NAME connection show 2>/dev/null")
    if h then
        for line in h:lines() do
            if line == value then
                saved = true
                break
            end
        end
        h:close()
    end

    if saved then
        os.execute("nmcli connection up id '" .. value .. "' 2>/dev/null")
        os.execute("notify-send -a 'System' 'WiFi Manager' 'Connected to " .. value .. "' -i network-wireless")
    else
        -- For new networks, open nmtui since we can't do password prompts in elephant
        os.execute("notify-send -a 'System' 'WiFi Manager' 'New network — opening nmtui' -i network-wireless")
        os.execute("kitty --class floating --title nmtui -e nmtui connect '" .. value .. "'")
    end
end

Action = ""
