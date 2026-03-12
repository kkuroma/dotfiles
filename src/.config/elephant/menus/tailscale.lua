Name = "tailscale"
NamePretty = "Tailscale VPN"
Icon = "network-vpn"
Cache = false

local flag_dir = os.getenv("HOME") .. "/Pictures/Flags/"
local selected_flag = ""

function GetEntries()
    local entries = {}

    -- Check current exit node
    local current_handle = io.popen("tailscale status --json 2>/dev/null | jq -r '.ExitNodeStatus.TailscaleIPs[0] // empty'")
    local current_node = ""
    if current_handle then
        current_node = current_handle:read("*l") or ""
        current_handle:close()
    end

    -- Add disconnect option if connected
    if current_node ~= "" then
        local country_handle = io.popen("tailscale status --json 2>/dev/null | jq -r '.Peer | to_entries[] | select(.value.ExitNode == true) | .value.Location.CountryCode // empty'")
        local country_code = ""
        if country_handle then
            country_code = country_handle:read("*l") or ""
            country_handle:close()
        end

        local flag = ""
        if country_code ~= "" then
            flag = flag_dir .. country_code:lower() .. ".svg"
        end

        table.insert(entries, {
            Text = "[Disconnect] from current node",
            Value = flag,
            Icon = flag,
            Actions = { activate = "lua:Disconnect" },
        })
    end

    -- List exit nodes
    local handle = io.popen("tailscale status --json 2>/dev/null | jq -r '.Peer | to_entries[] | select(.value.ExitNodeOption == true and .value.Location != null) | \"\\(.value.Location.Country)|\\(.value.Location.CountryCode)|\\(.value.Location.City)|\\(.value.TailscaleIPs[0])\"' | sort -t'|' -k1,1 -k3,3 -u")
    if handle then
        for line in handle:lines() do
            local country, code, city, ip = line:match("^(.-)|(.-)|(.-)|(.*)")
            if country and ip then
                local flag = ""
                if code and code ~= "" then
                    flag = flag_dir .. code:lower() .. ".svg"
                end
                table.insert(entries, {
                    Text = country .. " - " .. city,
                    Subtext = ip,
                    Value = country .. " - " .. city .. "|" .. ip .. "|" .. flag,
                    Icon = flag,
                    Actions = { activate = "lua:Connect" },
                })
            end
        end
        handle:close()
    end

    return entries
end

function Connect(value)
    local country_city, ip, flag = value:match("^(.-)|([^|]+)|([^|]*)$")
    os.execute("tailscale set --exit-node='" .. ip .. "' --exit-node-allow-lan-access=true 2>/dev/null")
    os.execute("notify-send -i " .. flag .. " -a 'Tailscale VPN' 'Tailscale VPN' 'Connected to exit node: " .. country_city .. "'")
end

function Disconnect(value)
    os.execute("tailscale set --exit-node='' 2>/dev/null")
    os.execute("notify-send -i " .. value .. " -a 'Tailscale VPN' 'Tailscale VPN' 'Disconnected from VPN'")
end

Action = ""
