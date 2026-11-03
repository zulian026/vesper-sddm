#!/usr/bin/env bash
# ==============================================================================
# VESPER SDDM - Test Mode Runner with Multi-Layout Support
# Safely launches SDDM greeter in windowed test mode without modifying system
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_CONF="$SCRIPT_DIR/theme.conf"
PREVIEW_LAYOUT=""

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --layout|-l)
            PREVIEW_LAYOUT="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: ./preview.sh [--layout <layout-name>]"
            echo "Available layouts:"
            echo "  - left-editorial   (Primary)"
            echo "  - center           (Baseline)"
            echo "  - right-sidebar"
            echo "  - split-screen"
            echo "  - bottom-center"
            echo "  - compact-floating"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Run './preview.sh --help' for usage."
            exit 1
            ;;
    esac
done

# Validate layout if specified
if [ -n "$PREVIEW_LAYOUT" ]; then
    case "$PREVIEW_LAYOUT" in
        center|left-editorial|right-sidebar|split-screen|bottom-center|compact-floating)
            echo "==> Previewing layout override: $PREVIEW_LAYOUT"
            ;;
        *)
            echo "Error: Invalid layout '$PREVIEW_LAYOUT'."
            echo "Valid choices: center, left-editorial, right-sidebar, split-screen, bottom-center, compact-floating"
            exit 1
            ;;
    esac
fi

# Sync colors before launching
echo "==> Syncing adaptive colors for preview..."
"$SCRIPT_DIR/sync/sync-colors.sh" "$SCRIPT_DIR"

RUN_DIR="$SCRIPT_DIR"

# If a layout override is requested, isolate it inside a temporary sandbox directory
# so that the project's actual theme.conf is never touched or modified on disk.
if [ -n "$PREVIEW_LAYOUT" ]; then
    SANDBOX_DIR=$(mktemp -d -t vesper-sddm-preview-XXXXXX)
    trap 'rm -rf "$SANDBOX_DIR" 2>/dev/null || true' EXIT INT TERM HUP

    # Symlink all components, layouts, assets, and QML files
    for item in "$SCRIPT_DIR"/*; do
        base=$(basename "$item")
        if [ "$base" != "theme.conf" ]; then
            ln -s "$item" "$SANDBOX_DIR/$base"
        fi
    done

    # Generate isolated theme.conf with requested layout override
    sed -E "s/^layout=.*/layout=$PREVIEW_LAYOUT/" "$THEME_CONF" > "$SANDBOX_DIR/theme.conf"
    RUN_DIR="$SANDBOX_DIR"
fi

ACTIVE_LAYOUT=$(grep -E "^layout=" "$RUN_DIR/theme.conf" | cut -d= -f2 || echo "left-editorial")
echo "==> Launching SDDM Qt6 Greeter with VESPER (Active Layout: $ACTIVE_LAYOUT)..."
echo "    (Close the preview window or press Ctrl+C to exit)"
sddm-greeter-qt6 --test-mode --theme "$RUN_DIR"
