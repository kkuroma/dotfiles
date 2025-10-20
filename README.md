# My Archlinux Configs

This repository contains my Arch Linux Hyprland rice configuration, including packages, dotfiles, and system settings.

![](assets/2025-10-18_23-36-51.mp4)

## Pulling Configs from Current System

Running `scripts/pull-configs.sh` on your system will pull relevant packages, `/etc` settings, `.config`, and `.zshrc`.

## Installing on a New Machine

Follow these steps to replicate this setup on another Arch Linux system:

### 1. Clone the Repository

```bash
git clone https://github.com/kkuroma/dotfiles ~/dotfiles
cd ~/dotfiles
```

### 2. Install Packages

Install official repository packages:
```bash
sudo pacman -S --needed - < pacman.txt
```

Install AUR packages (requires an AUR helper like `yay` or `paru`):
```bash
yay -S --needed - < pacman-aur.txt
# or
paru -S --needed - < pacman-aur.txt
```

### 3. Apply Configuration Files

**Symlink .config directory:**
```bash
# Backup existing config if needed
mv ~/.config ~/.config.backup

# Create symlink to dotfiles
ln -s ~/dotfiles/.config ~/.config
```

**Symlink .zshrc:**
```bash
# Backup existing .zshrc if needed
mv ~/.zshrc ~/.zshrc.backup

# Create symlink to dotfiles
ln -s ~/dotfiles/.zshrc ~/.zshrc
```

### 4. Configure /etc Files (Optional, if you want your system to be 100% like mine)

Review the `etc/` directory and copy relevant configuration files to `/etc`:

```bash
# Example: Copy specific configs (review each file first!)
sudo cp -r ~/dotfiles/etc/your-config-file /etc/

# Or review BACKUP_INFO.txt for guidance
cat ~/dotfiles/etc/BACKUP_INFO.txt
```

**Important `/etc` files to review:**
- `/etc/pacman.conf` - Pacman configuration
- `/etc/mkinitcpio.conf` - Initial ramdisk configuration
- `/etc/locale.conf` and `/etc/locale.gen` - Locale settings
- `/etc/X11/xorg.conf.d/` - Display configuration
- `/etc/modprobe.d/` - Kernel module configuration

### 5. Enable Services (Optional, if you want your system to be 100% like mine)

Check `SYSTEM_SETUP.md` for the list of enabled services and enable them on your system:

```bash
# Example system services
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

# Example user services
systemctl --user enable pipewire
systemctl --user enable wireplumber
```

### 6. Post-Installation (Optional, if you want your system to be 100% like mine)

- Regenerate locale: `sudo locale-gen`
- Rebuild initramfs if you changed mkinitcpio.conf: `sudo mkinitcpio -P`
- Reboot to apply all changes
