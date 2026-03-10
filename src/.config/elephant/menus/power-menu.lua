Name = "power-menu"
NamePretty = "Power Menu"
Icon = "system-shutdown"
Cache = true

function GetEntries()
    return {
        {
            Text = "Lock",
            Value = "lock",
            Icon = "system-lock-screen",
            Subtext = "hyprlock",
            Actions = { activate = "lua:RunAction" },
        },
        {
            Text = "Logout",
            Value = "logout",
            Icon = "system-log-out",
            Subtext = "hyprctl dispatch exit",
            Actions = { activate = "lua:RunAction" },
        },
        {
            Text = "Suspend",
            Value = "suspend",
            Icon = "system-suspend",
            Subtext = "systemctl suspend",
            Actions = { activate = "lua:RunAction" },
        },
        {
            Text = "Hibernate",
            Value = "hibernate",
            Icon = "system-hibernate",
            Subtext = "systemctl hibernate",
            Actions = { activate = "lua:RunAction" },
        },
        {
            Text = "Shutdown",
            Value = "shutdown",
            Icon = "system-shutdown",
            Subtext = "systemctl poweroff",
            Actions = { activate = "lua:RunAction" },
        },
        {
            Text = "Reboot",
            Value = "reboot",
            Icon = "system-reboot",
            Subtext = "systemctl reboot",
            Actions = { activate = "lua:RunAction" },
        },
    }
end

function RunAction(value)
    local actions = {
        lock = "hyprlock",
        logout = "sleep 0.2 && hyprctl dispatch exit",
        suspend = "systemctl suspend",
        hibernate = "systemctl hibernate",
        shutdown = "systemctl poweroff",
        reboot = "systemctl reboot",
    }

    local cmd = actions[value]
    if cmd then
        os.execute(cmd)
    end
end

Action = "lua:RunAction"
