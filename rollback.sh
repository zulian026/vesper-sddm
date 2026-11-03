#!/usr/bin/env bash
# ==============================================================================
# VESPER SDDM - Rollback Script
# Reverts active SDDM theme to exact previous configuration
# ==============================================================================

set -euo pipefail

CONFIG_FILE="/etc/sddm.conf.d/theme.conf"
BACKUP_DIR="/etc/sddm.conf.d/backups"
TARGET_THEME_DIR="/usr/share/sddm/themes/vesper"

if [ "$EUID" -ne 0 ]; then
    echo "==> Requesting superuser permissions..."
    exec sudo "$0" "$@"
fi

echo "=========================================================="
echo "             VESPER SDDM THEME ROLLBACK                   "
echo "=========================================================="

LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/theme.conf.bak_* 2>/dev/null | head -n 1 || true)

if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
    echo "==> Restoring from backup: $LATEST_BACKUP"
    cp "$LATEST_BACKUP" "$CONFIG_FILE"
    chmod 644 "$CONFIG_FILE"
    echo "==> Active theme restored from backup: $(cat "$CONFIG_FILE")"
elif [ -f "$BACKUP_DIR/original_was_absent" ]; then
    echo "==> $CONFIG_FILE did not exist before installation. Removing it..."
    rm -f "$CONFIG_FILE"
    echo "==> Removed $CONFIG_FILE (system returned to pristine state)."
else
    echo "==> No backup records found. Removing $CONFIG_FILE..."
    rm -f "$CONFIG_FILE"
fi

# Remove sync helper
if [ -f /usr/local/bin/vesper-sddm-sync ]; then
    rm -f /usr/local/bin/vesper-sddm-sync
    echo "==> Removed /usr/local/bin/vesper-sddm-sync"
fi

# Ask if VESPER theme directory should be deleted
if [ -d "$TARGET_THEME_DIR" ]; then
    read -rp "Do you also want to remove $TARGET_THEME_DIR? [y/N]: " choice
    case "$choice" in
        [yY][eE][sS]|[yY])
            rm -rf "$TARGET_THEME_DIR"
            echo "==> Removed $TARGET_THEME_DIR."
            ;;
        *)
            echo "==> Kept theme files in $TARGET_THEME_DIR (inactive)."
            ;;
    esac
fi

echo "==> Rollback completed successfully!"
