#!/usr/bin/env bash
# ==============================================================================
# VESPER SDDM - Installation Script
# Installs theme to /usr/share/sddm/themes/vesper and activates it
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_THEME_DIR="/usr/share/sddm/themes/vesper"
CONFIG_FILE="/etc/sddm.conf.d/theme.conf"
BACKUP_DIR="/etc/sddm.conf.d/backups"

echo "=========================================================="
echo "             VESPER SDDM THEME INSTALLER                  "
echo "        A Minimal, Adaptive SDDM Login Experience         "
echo "=========================================================="

if [ "$EUID" -ne 0 ]; then
    echo "==> Requesting superuser permissions..."
    exec sudo "$0" "$@"
fi

# 1. Sync latest colors and wallpaper before copying
echo "==> Synchronizing adaptive desktop colors..."
"$SCRIPT_DIR/sync/sync-colors.sh" "$SCRIPT_DIR"

# 2. Safety check: Backup existing VESPER installation if present
if [ -d "$TARGET_THEME_DIR" ]; then
    THEME_BACKUP_NAME="${TARGET_THEME_DIR}.bak_$(date +%Y%m%d_%H%M%S)"
    echo "==> Existing VESPER installation detected."
    echo "==> Creating safety backup at: $THEME_BACKUP_NAME"
    cp -r "$TARGET_THEME_DIR" "$THEME_BACKUP_NAME"
fi

# 3. Install to system theme directory
echo "==> Installing theme to: $TARGET_THEME_DIR"
mkdir -p "$TARGET_THEME_DIR"
cp -r "$SCRIPT_DIR/Main.qml" "$TARGET_THEME_DIR/"
cp -r "$SCRIPT_DIR/metadata.desktop" "$TARGET_THEME_DIR/"
cp -r "$SCRIPT_DIR/theme.conf" "$TARGET_THEME_DIR/"
cp -r "$SCRIPT_DIR/palette.json" "$TARGET_THEME_DIR/"
cp -r "$SCRIPT_DIR/assets" "$TARGET_THEME_DIR/"
cp -r "$SCRIPT_DIR/components" "$TARGET_THEME_DIR/"
cp -r "$SCRIPT_DIR/layouts" "$TARGET_THEME_DIR/"
cp -r "$SCRIPT_DIR/sync" "$TARGET_THEME_DIR/"

# Set safe, non-excessive permissions (755 for directories & scripts, 644 for regular files)
echo "==> Setting safe file permissions (755 dirs, 644 files)..."
find "$TARGET_THEME_DIR" -type d -exec chmod 755 {} +
find "$TARGET_THEME_DIR" -type f -exec chmod 644 {} +
chmod 755 "$TARGET_THEME_DIR/sync/sync-colors.sh"

# 4. Track pre-existing state for clean rollback
mkdir -p "$BACKUP_DIR"
if [ -f "$CONFIG_FILE" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp "$CONFIG_FILE" "$BACKUP_DIR/theme.conf.bak_$TIMESTAMP"
    echo "==> Backed up existing $CONFIG_FILE to $BACKUP_DIR/theme.conf.bak_$TIMESTAMP"
else
    touch "$BACKUP_DIR/original_was_absent"
    echo "==> Recorded that $CONFIG_FILE did not previously exist."
fi

# 5. Activate theme in /etc/sddm.conf.d/theme.conf
mkdir -p /etc/sddm.conf.d
cat << CONF_EOF > "$CONFIG_FILE"
[Theme]
Current=vesper
CONF_EOF
chmod 644 "$CONFIG_FILE"

echo "==> Updated $CONFIG_FILE: Current=vesper"

# 6. Install convenient sync command to /usr/local/bin pointing to self-contained theme sync script
cat << SYNC_BIN_EOF > /usr/local/bin/vesper-sddm-sync
#!/usr/bin/env bash
# Quick helper to sync current user desktop colors to installed VESPER theme
set -euo pipefail
if [ "\$EUID" -ne 0 ]; then
    exec sudo "\$0" "\$@"
fi
"$TARGET_THEME_DIR/sync/sync-colors.sh" "$TARGET_THEME_DIR"
find "$TARGET_THEME_DIR" -type d -exec chmod 755 {} +
find "$TARGET_THEME_DIR" -type f -exec chmod 644 {} +
chmod 755 "$TARGET_THEME_DIR/sync/sync-colors.sh"
echo "==> VESPER SDDM theme synchronized successfully!"
SYNC_BIN_EOF

chmod 755 /usr/local/bin/vesper-sddm-sync
echo "==> Installed sync helper: /usr/local/bin/vesper-sddm-sync"

echo "=========================================================="
echo "  Installation Complete!                                 "
echo "  Theme:   VESPER (/usr/share/sddm/themes/vesper)        "
echo "  Layout:  $(grep -E '^layout=' "$TARGET_THEME_DIR/theme.conf" | cut -d= -f2 || echo 'left-editorial')"
echo "  Run 'vesper-sddm-sync' anytime to update colors.       "
echo "=========================================================="
