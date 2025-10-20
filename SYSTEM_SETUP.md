# System Setup Guide

Generated: $(date)

## Enabled Services

### User Services
```bash
UNIT FILE             STATE   PRESET
wireplumber.service   enabled enabled
xdg-user-dirs.service enabled enabled
p11-kit-server.socket enabled enabled
pipewire-pulse.socket enabled enabled
pipewire.socket       enabled enabled
5 unit files listed.
```

### System Services
```bash
bluetooth.service                  enabled disabled
cronie.service                     enabled disabled
docker.service                     enabled disabled
getty@.service                     enabled enabled
grub-btrfsd.service                enabled disabled
NetworkManager-dispatcher.service  enabled disabled
NetworkManager-wait-online.service enabled disabled
NetworkManager.service             enabled disabled
nvidia-hibernate.service           enabled disabled
nvidia-resume.service              enabled disabled
nvidia-suspend.service             enabled disabled
sddm.service                       enabled disabled
sshd.service                       enabled disabled
systemd-network-generator.service  enabled enabled
systemd-networkd.service           enabled enabled
systemd-resolved.service           enabled enabled
systemd-timesyncd.service          enabled enabled
tailscaled.service                 enabled disabled
systemd-networkd-varlink.socket    enabled disabled
systemd-networkd.socket            enabled disabled
systemd-resolved-monitor.socket    enabled disabled
systemd-resolved-varlink.socket    enabled disabled
systemd-userdbd.socket             enabled enabled
remote-fs.target                   enabled enabled
24 unit files listed.
```

## Network Configuration

- Using **NetworkManager**

## Custom systemd Units

### System units:
- `dbus-org.bluez.service`
- `dbus-org.freedesktop.network1.service`
- `dbus-org.freedesktop.nm-dispatcher.service`
- `dbus-org.freedesktop.resolve1.service`
- `dbus-org.freedesktop.timesync1.service`
- `display-manager.service`

## Important Config Files to Review

- **Display**: /etc/X11/xorg.conf.d/
- **Boot**: /etc/mkinitcpio.conf
- **Pacman**: /etc/pacman.conf
- **Locale**: /etc/locale.conf, /etc/locale.gen
- **Kernel modules**: /etc/modprobe.d/

## Setup Instructions for New Machine

1. Install packages from pacman.txt and pacman-aur.txt
2. Enable services listed above using `systemctl enable <service>`
3. Review and adapt network configuration
4. Copy relevant config files from /etc based on your hardware
5. Symlink .config directory
