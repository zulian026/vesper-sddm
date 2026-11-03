# VESPER — Installation & Migration Guide

Complete reference for installing, migrating, configuring, and verifying the **VESPER SDDM** theme on your Linux system.

---

## 1. Prerequisites

VESPER requires SDDM with Qt 6 QML support:
```bash
# On CachyOS / Arch Linux:
sudo pacman -S --needed sddm qt6-declarative
```

Python 3.11+ is standard on modern Linux systems and is used by the color and wallpaper synchronization script.

---

## 2. Non-Destructive Preview Testing

Before changing any system files or display manager settings, verify the theme directly in a windowed sandbox inside your existing desktop session:

```bash
cd ~/Projects/noctalia-sddm

# Test primary layout (left-editorial)
./preview.sh

# Test any other layout variant
./preview.sh --layout center
./preview.sh --layout right-sidebar
./preview.sh --layout split-screen
./preview.sh --layout bottom-center
./preview.sh --layout compact-floating
```

The preview script uses an isolated temporary sandbox (`/tmp/vesper-sddm-preview-XXXXXX`) so your working directory and system files remain untouched.

---

## 3. Migration Strategy from Previous Themes

If you have a previously installed theme (such as the earlier `noctalia-sddm` installation):

1. **Do not manually delete `/usr/share/sddm/themes/noctalia-sddm`** before testing VESPER. Keeping the old theme directory ensures an immediate fallback path if needed.
2. The `install.sh` script will:
   - Back up `/etc/sddm.conf.d/theme.conf` (which points to your existing theme) to `/etc/sddm.conf.d/backups/theme.conf.bak_<timestamp>`.
   - Install VESPER cleanly into `/usr/share/sddm/themes/vesper`.
   - Point SDDM to the new theme: `Current=vesper`.
   - Install `/usr/local/bin/vesper-sddm-sync`.
3. If you ever need to revert, running `sudo ./rollback.sh` will automatically restore your previous `theme.conf` from the backup.

---

## 4. System Installation

To execute the installation:

```bash
cd ~/Projects/noctalia-sddm
sudo ./install.sh
```

### Installation Verification Checklist:
- [ ] Theme files exist in `/usr/share/sddm/themes/vesper/`.
- [ ] File permissions are `755` for directories and `644` for files.
- [ ] `/etc/sddm.conf.d/theme.conf` contains `Current=vesper`.
- [ ] Backup exists in `/etc/sddm.conf.d/backups/`.
- [ ] `/usr/local/bin/vesper-sddm-sync` is executable (`chmod 755`).

---

## 5. Synchronizing Colors & Wallpapers

To sync your active wallpaper and dynamic colors to the installed theme at any time:

```bash
sudo vesper-sddm-sync
```

---

## 6. Layout Configuration

To change the layout on an installed system, edit `/usr/share/sddm/themes/vesper/theme.conf`:

```ini
[General]
layout=left-editorial   # Available: left-editorial, center, right-sidebar, split-screen, bottom-center, compact-floating
```

---

## 7. Rollback

To revert the active display manager back to your previous configuration:

```bash
cd ~/Projects/noctalia-sddm
sudo ./rollback.sh
```
