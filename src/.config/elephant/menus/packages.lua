Name = "packages"
NamePretty = "Package Manager"
Icon = "system-software-install"
Cache = false

local installer = os.getenv("HOME") .. "/Scripts/packages.sh"
local update_script = os.getenv("HOME") .. "/Scripts/system-update.sh"
local bridge = os.getenv("HOME") .. "/.config/elephant/scripts/package-list-bridge.sh"

local function kitty_cmd(title, cmd)
    return "kitty --class floating -e sh -c '" .. cmd .. "; echo \"\\nDone. Press enter to continue.\"; read -r'"
end

function GetEntries()
    return {
        {
            Text = "List Installed Packages",
            Value = "list-all",
            Icon = "",
            Actions = { activate = bridge .. " all" },
        },
        {
            Text = "List Explicitly Installed Packages",
            Value = "list-explicit",
            Icon = "",
            Actions = { activate = bridge .. " explicit" },
        },
        {
            Text = "List Foreign (AUR) Packages",
            Value = "list-aur",
            Icon = "",
            Actions = { activate = bridge .. " aur" },
        },
        {
            Text = "Install (Arch Repo)",
            Value = "install-repo",
            Icon = "󰜮",
            Actions = {
                activate = kitty_cmd("Installer", installer .. " install"),
            },
        },
        {
            Text = "Install (AUR)",
            Value = "install-aur",
            Icon = "󰜮",
            Actions = {
                activate = kitty_cmd("Installer AUR", installer .. " install aur"),
            },
        },
        {
            Text = "Uninstall a Package",
            Value = "uninstall",
            Icon = "󰆴",
            Actions = {
                activate = kitty_cmd("Uninstall", installer .. " uninstall"),
            },
        },
        {
            Text = "Clean Unused Packages",
            Value = "clean",
            Icon = "󰁮",
            Actions = {
                activate = kitty_cmd("Clean", "sudo pacman -Rns $(pacman -Qdtq)"),
            },
        },
        {
            Text = "System Update",
            Value = "update",
            Icon = "󰚰",
            Actions = {
                activate = kitty_cmd("Update", update_script),
            },
        },
    }
end

Action = ""
