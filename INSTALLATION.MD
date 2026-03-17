# Installing my configuration

My scripts were written to enable various "levels" of installation, from just my "rice" to converting an arch installation to a full-fledged copy of my setup. The latter is mostly for me to reproduce my setup on new machines quickly.

## Scripts
Here are the scripts' functionalities
- `scripts/pull-configs.sh` pull configs to repo directory
- `scripts/apply-configs.sh` applies the rice.
- `scripts/pacman-install.sh` install necessary packages. This allows installation of packages at many levels.
- `scripts/hyprpm.sh` applies the necessary hyprland plugins

## Existing installation / updates

**IMPORTANT** back up your configuration before installing my setup. Review the package list to predetermine any potential conflicts. The remaining steps should be the same as fresh installations.

### Updated prerequisites

> These packages are required for the core functionality of my desktop

```
hyprland hyprlock hyprpicker hypridle waybar walker elephant-all-bin swaync swayosd matugen-bin
```

In the case you only wanted the essential elephant providers:

```
elephant-bin elephant-bluetooth-bin elephant-calc-bin elephant-clipboard-bin elephant-desktopapplications-bin elephant-menus-bin elephant-providerlist-bin elephant-runner-bin elephant-websearch-bin
```

Essentially, the Hypr ecosystem + waybar + walker stack make up my primary desktop setup.

> These packages are opinionated picks that integrate with my desktop experience

```
kitty fastfetch duf btop yazi cava fzf fcitx5 fcitx5-chinese-addons fcitx5-configtool fcitx5-mozc codium zen-browser-bin dolphin
```

> Patching steps:

Run `scripts/apply-configs.sh`, this should pull my latest patches to the rice seamlessly, preserving screen-specific settings (like monitors and workspaces). Some daemons and autostart processes might be added between patches, so a logout or reboot might be required to see all changes. Modify the `exclude` list in the script to match your needs.

## Fresh Installation

### Requirements
A minimal arch installation, `git`, and an AUR helper of your choice (yay or paru). To apply my `zshrc`, make sure to install zsh and oh-my-zsh first
```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
Set your default shell to ZSH when prompted, then restart. Make sure you have installed display drivers for your graphics card to avoid issues with setting your screen resolution later on.

### Steps
This is the intended way to apply my configurations. Start by running
```sh
scripts/pacman-install.sh
```
Installing, at the very least, system and rice applications when prompted. You can choose to install my full set of applications as well.
```sh
scripts/apply-configs.sh
```
This will apply the configuration files to the respective directories. Make sure to look through the file and configure some variable/locations accordingly. You might need to log out or restart for all changes to apply.

### Potential manual interventions
- Keyrings: some keyrings might not be valid and would require you to add them manually

### Post Installation
- Press MainMod+K to view the keybinds! Feel free to edit them at `~/.config/hypr/components/binds.conf`
- Start a terminal session (MainMod+T by default). You'll likely see oh-my-zsh installing the plugins at the first launch.
- **Vencord** enable the CSS via its settings.
- **Fcitx** install your languages via fcitx and edit `~/.config/waybar/scripts/ime-status.sh` and `~/.config/waybar/scripts/ime-switch.sh` accordingly. My configs come with only the languages I speak.
- **Cursor** edit `/usr/share/icons/default/index.theme` to inherit your cursor theme of choice (BreezeX-Black in my case). This, combined with hyprland's settings, should be enough to set the cursor for *most* apps. Electron apps are particularly stubborn, as it falls back to Adwaita even with new defaults. The most surefire solution, if you don't wish to use Adwaita ever, is to simply delete `/usr/share/icons/Adwaita`. 
