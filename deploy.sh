#!/bin/bash
# Deploy ergo-inside config to ~/.config/ergo/ and reload services.
# Usage: ./deploy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ERGO_DIR="$HOME/.config/ergo"
CADDY_DIR="$HOME/.config/caddy"
LAUNCH_DIR="$HOME/Library/LaunchAgents"

echo "Deploying ergo-inside to $ERGO_DIR..."

# Resolve zchat's Python path dynamically (avoids hardcoding Homebrew version)
ZCHAT_PYTHON=""
ZCHAT_PREFIX="$(brew --prefix zchat 2>/dev/null || true)"
if [ -n "$ZCHAT_PREFIX" ] && [ -x "$ZCHAT_PREFIX/libexec/bin/python" ]; then
    ZCHAT_PYTHON="$ZCHAT_PREFIX/libexec/bin/python"
fi
if [ -z "$ZCHAT_PYTHON" ]; then
    echo "Warning: could not resolve zchat Homebrew Python, using system python3"
    ZCHAT_PYTHON="$(which python3)"
fi
echo "Auth-script Python: $ZCHAT_PYTHON"

# Ergo config + auth-script
# Patch auth-script command with resolved Python path before copying
sed "s|command:.*# zchat-python|command: \"$ZCHAT_PYTHON\" # zchat-python|" \
    "$SCRIPT_DIR/ergo.yaml" > "$ERGO_DIR/ergo.yaml"
cp "$SCRIPT_DIR/ergo_auth_script.py" "$ERGO_DIR/ergo_auth_script.py"
cp "$SCRIPT_DIR/auth_script_config.json" "$ERGO_DIR/auth_script_config.json"
chmod +x "$ERGO_DIR/ergo_auth_script.py"

# Caddy config
cp "$SCRIPT_DIR/Caddyfile" "$CADDY_DIR/Caddyfile"

# LaunchAgents
cp "$SCRIPT_DIR/launchd/com.h2os.ergo.plist" "$LAUNCH_DIR/"
cp "$SCRIPT_DIR/launchd/com.h2os.caddy.plist" "$LAUNCH_DIR/"

# Reload services
echo "Reloading ergo..."
launchctl kickstart -k "gui/$(id -u)/com.h2os.ergo" 2>/dev/null || \
    (launchctl unload "$LAUNCH_DIR/com.h2os.ergo.plist" 2>/dev/null; \
     launchctl load "$LAUNCH_DIR/com.h2os.ergo.plist")

echo "Reloading caddy..."
launchctl kickstart -k "gui/$(id -u)/com.h2os.caddy" 2>/dev/null || \
    (launchctl unload "$LAUNCH_DIR/com.h2os.caddy.plist" 2>/dev/null; \
     launchctl load "$LAUNCH_DIR/com.h2os.caddy.plist")

echo "Done. Services restarted."
