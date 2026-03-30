#!/bin/bash
# Deploy ergo-inside config to ~/.config/ergo/ and reload services.
# Usage: ./deploy.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ERGO_DIR="$HOME/.config/ergo"
CADDY_DIR="$HOME/.config/caddy"
LAUNCH_DIR="$HOME/Library/LaunchAgents"

echo "Deploying ergo-inside to $ERGO_DIR..."

# Ergo config + auth-script
cp "$SCRIPT_DIR/ergo.yaml" "$ERGO_DIR/ergo.yaml"
cp "$SCRIPT_DIR/ergo_auth_script.py" "$ERGO_DIR/ergo_auth_script.py"
cp "$SCRIPT_DIR/auth_script_config.json" "$ERGO_DIR/auth_script_config.json"
chmod +x "$ERGO_DIR/ergo_auth_script.py"

# Auth-script uses the zchat Homebrew venv Python (has httpx installed)
# See ergo.yaml auth-script.command for the Python path

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
