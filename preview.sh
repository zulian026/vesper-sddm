#!/usr/bin/env bash
# ==============================================================================
# VESPER SDDM - Test Mode Runner with Multi-Layout Support
# Safely launches SDDM greeter in windowed test mode or captures 1080p screenshots
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_CONF="$SCRIPT_DIR/theme.conf"
PREVIEW_LAYOUT=""
SCREENSHOT_PATH=""
RENDER_WIDTH=1920
RENDER_HEIGHT=1080

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --layout|-l)
            PREVIEW_LAYOUT="$2"
            shift 2
            ;;
        --screenshot|-s)
            SCREENSHOT_PATH="$2"
            shift 2
            ;;
        --width)
            RENDER_WIDTH="$2"
            shift 2
            ;;
        --height)
            RENDER_HEIGHT="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: ./preview.sh [options]"
            echo "Options:"
            echo "  --layout, -l <name>       Select layout to preview"
            echo "  --screenshot, -s <file>   Render offscreen 1920x1080 screenshot to file"
            echo "  --width <px>              Custom screenshot width (default: 1920)"
            echo "  --height <px>             Custom screenshot height (default: 1080)"
            echo ""
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
            ;;
        *)
            echo "Error: Invalid layout '$PREVIEW_LAYOUT'."
            echo "Valid choices: center, left-editorial, right-sidebar, split-screen, bottom-center, compact-floating"
            exit 1
            ;;
    esac
fi

# Sync colors before preview or rendering
echo "==> Syncing adaptive colors..."
"$SCRIPT_DIR/sync/sync-colors.sh" "$SCRIPT_DIR"

ACTIVE_LAYOUT="${PREVIEW_LAYOUT:-$(grep -E '^layout=' "$THEME_CONF" | cut -d= -f2 || echo 'left-editorial')}"

# If screenshot capture is requested, run native offscreen renderer
if [ -n "$SCREENSHOT_PATH" ]; then
    mkdir -p "$(dirname "$SCREENSHOT_PATH")"
    RENDERER_BIN="/tmp/vesper_render_bin"
    RENDERER_SRC="$SCRIPT_DIR/sync/render-screenshot.cpp"

    if [ ! -f "$RENDERER_BIN" ] || [ "$RENDERER_SRC" -nt "$RENDERER_BIN" ]; then
        echo "==> Compiling native Qt6 offscreen screenshot renderer..."
        /usr/lib/qt6/moc "$RENDERER_SRC" -o /tmp/render-screenshot.moc
        g++ -O2 -std=c++17 -fPIC "$RENDERER_SRC" -I/tmp $(pkg-config --cflags --libs Qt6Quick Qt6Gui Qt6Qml) -o "$RENDERER_BIN"
    fi

    echo "==> Rendering layout '$ACTIVE_LAYOUT' at ${RENDER_WIDTH}x${RENDER_HEIGHT} -> $SCREENSHOT_PATH"
    "$RENDERER_BIN" "$SCRIPT_DIR" "$ACTIVE_LAYOUT" "$SCREENSHOT_PATH" "$RENDER_WIDTH" "$RENDER_HEIGHT"
    echo "==> Screenshot captured successfully: $SCREENSHOT_PATH"
    exit 0
fi

RUN_DIR="$SCRIPT_DIR"

# If an interactive layout override is requested, isolate it inside a temporary sandbox directory
if [ -n "$PREVIEW_LAYOUT" ]; then
    SANDBOX_DIR=$(mktemp -d -t vesper-sddm-preview-XXXXXX)
    trap 'rm -rf "$SANDBOX_DIR" 2>/dev/null || true' EXIT INT TERM HUP

    for item in "$SCRIPT_DIR"/*; do
        base=$(basename "$item")
        if [ "$base" != "theme.conf" ]; then
            ln -s "$item" "$SANDBOX_DIR/$base"
        fi
    done

    sed -E "s/^layout=.*/layout=$PREVIEW_LAYOUT/" "$THEME_CONF" > "$SANDBOX_DIR/theme.conf"
    RUN_DIR="$SANDBOX_DIR"
fi

echo "==> Launching SDDM Qt6 Greeter with VESPER (Active Layout: $ACTIVE_LAYOUT)..."
echo "    (Close the preview window or press Ctrl+C to exit)"
sddm-greeter-qt6 --test-mode --theme "$RUN_DIR"
