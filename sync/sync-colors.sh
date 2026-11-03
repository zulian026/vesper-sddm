#!/usr/bin/env bash
# ==============================================================================
# VESPER SDDM - Adaptive Color & Wallpaper Synchronization Script
# Extracts active desktop wallpaper and colors to synchronize with VESPER theme
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="${1:-$THEME_DIR}"

echo "==> Synchronizing adaptive colors to VESPER SDDM theme at: $TARGET_DIR"

python3 - << PYEOF
import json, os, subprocess, sys, shutil, pwd
import tomllib

target_dir = "$TARGET_DIR"
theme_conf_path = os.path.join(target_dir, "theme.conf")
palette_json_path = os.path.join(target_dir, "palette.json")
assets_dir = os.path.join(target_dir, "assets")
os.makedirs(assets_dir, exist_ok=True)

# Build environment to communicate with user's desktop session even if run via sudo
sudo_user = os.environ.get("SUDO_USER")
if sudo_user:
    try:
        pw = pwd.getpwnam(sudo_user)
        user_env = os.environ.copy()
        user_env["HOME"] = pw.pw_dir
        user_env["XDG_RUNTIME_DIR"] = f"/run/user/{pw.pw_uid}"
        user_env["USER"] = sudo_user
    except Exception:
        user_env = os.environ.copy()
else:
    user_env = os.environ.copy()

# Default sensible fallback palette (VESPER Dark M3)
defaults = {
    "background": "#141314",
    "surface": "#201f20",
    "surfaceAlt": "#2b292b",
    "foreground": "#e6e1e3",
    "muted": "#948f96",
    "accent": "#ccc3d7",
    "accentForeground": "#342e3d",
    "border": "#49454b",
    "error": "#ffb4ab"
}

wallpaper_path = ""
scheme = "m3-content"
mode = "dark"

# 1. Try to query running desktop shell/daemon via IPC if available
try:
    wp_res = subprocess.run(["noctalia", "msg", "wallpaper-get"], env=user_env, capture_output=True, text=True, timeout=2)
    if wp_res.returncode == 0 and wp_res.stdout.strip():
        wallpaper_path = wp_res.stdout.strip()

    scheme_res = subprocess.run(["noctalia", "msg", "color-scheme-get"], env=user_env, capture_output=True, text=True, timeout=2)
    if scheme_res.returncode == 0 and scheme_res.stdout.strip():
        parts = scheme_res.stdout.strip().split()
        if len(parts) >= 2:
            scheme = parts[1]

    mode_res = subprocess.run(["noctalia", "msg", "theme-mode-get"], env=user_env, capture_output=True, text=True, timeout=2)
    if mode_res.returncode == 0 and mode_res.stdout.strip():
        mode = mode_res.stdout.strip()
except Exception:
    pass

# 2. If daemon IPC did not provide wallpaper, parse via user config export
if not wallpaper_path:
    try:
        cfg_res = subprocess.run(["noctalia", "config", "export"], env=user_env, capture_output=True, text=True, timeout=2)
        if cfg_res.returncode == 0 and cfg_res.stdout.strip():
            cfg_data = tomllib.loads(cfg_res.stdout)
            wp_cfg = cfg_data.get("wallpaper", {})
            wallpaper_path = (wp_cfg.get("default", {}).get("path") or 
                              wp_cfg.get("last", {}).get("path") or "")
            theme_cfg = cfg_data.get("theme", {})
            scheme = theme_cfg.get("wallpaper_scheme", scheme)
            mode = theme_cfg.get("mode", mode)
    except Exception:
        pass

palette = dict(defaults)

# 3. Generate adaptive colors from wallpaper using available system utilities
if wallpaper_path and os.path.isfile(wallpaper_path):
    print(f"--> Found active wallpaper: {wallpaper_path}")
    print(f"--> Using scheme: {scheme}, mode: {mode}")

    # Copy wallpaper to theme assets with world-readable permissions
    dest_wp = os.path.join(assets_dir, "background.png")
    try:
        shutil.copy2(wallpaper_path, dest_wp)
        os.chmod(dest_wp, 0o644)
        print(f"--> Copied wallpaper to: {dest_wp} (permissions 644)")
    except Exception as e:
        print(f"Warning: Failed to copy wallpaper: {e}", file=sys.stderr)

    try:
        flag = "--dark" if mode != "light" else "--light"
        cmd = ["noctalia", "theme", wallpaper_path, "--scheme", scheme, flag]
        gen_res = subprocess.run(cmd, env=user_env, capture_output=True, text=True, timeout=5)
        if gen_res.returncode == 0:
            m3_data = json.loads(gen_res.stdout)
            palette["background"] = m3_data.get("background", defaults["background"])
            palette["surface"] = m3_data.get("surface_container", defaults["surface"])
            palette["surfaceAlt"] = m3_data.get("surface_container_high", defaults["surfaceAlt"])
            palette["foreground"] = m3_data.get("on_surface", defaults["foreground"])
            palette["muted"] = m3_data.get("outline", defaults["muted"])
            palette["accent"] = m3_data.get("primary", defaults["accent"])
            palette["accentForeground"] = m3_data.get("on_primary", defaults["accentForeground"])
            palette["border"] = m3_data.get("outline_variant", defaults["border"])
            palette["error"] = m3_data.get("error", defaults["error"])
            print("--> Successfully extracted dynamic colors from wallpaper")
        else:
            print("Warning: Theme generator failed, falling back to VESPER defaults", file=sys.stderr)
    except Exception as e:
        print(f"Warning: Could not run theme generator: {e}", file=sys.stderr)
else:
    print("--> No active wallpaper found; using VESPER default fallback palette")

# 4. Save palette.json with strict 644 permissions
with open(palette_json_path, "w") as f:
    json.dump(palette, f, indent=2)
os.chmod(palette_json_path, 0o644)
print(f"--> Wrote palette: {palette_json_path} (644)")

# 5. Preserve existing layout if configured
existing_layout = "left-editorial"
if os.path.isfile(theme_conf_path):
    try:
        with open(theme_conf_path, "r") as f:
            for l in f:
                if l.strip().startswith("layout="):
                    val = l.strip().split("=")[1].strip()
                    if val: existing_layout = val
    except Exception:
        pass

# 6. Write theme.conf with SDDM properties and strict 644 permissions
conf_content = f"""# ==============================================================================
# VESPER SDDM Theme Configuration
# Generated automatically by sync-colors.sh
# ==============================================================================
[General]
background=assets/background.png
type=image
dimBackground=0.25
blurBackground=false

# Typography
fontFamily=Inter
clockFontSize=72
dateFontSize=14
uiFontSize=13

# Semantic Color Tokens (Adaptive Palette)
colorBackground={palette['background']}
colorSurface={palette['surface']}
colorSurfaceAlt={palette['surfaceAlt']}
colorForeground={palette['foreground']}
colorMuted={palette['muted']}
colorAccent={palette['accent']}
colorAccentForeground={palette['accentForeground']}
colorBorder={palette['border']}
colorError={palette['error']}

# Interaction & Layout
layout={existing_layout}
panelRadius=14
inputRadius=8
showSessionSelect=true
showKeyboardSelect=true
showPowerButtons=true
showClock=true
showDate=true
showAvatar=true
"""

with open(theme_conf_path, "w") as f:
    f.write(conf_content)
os.chmod(theme_conf_path, 0o644)
print(f"--> Wrote theme configuration: {theme_conf_path} (644)")

print("==> Synchronization finished successfully!")
PYEOF
