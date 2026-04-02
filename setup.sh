#!/bin/bash
# First-time setup for ergo-inside: install dependencies, create dirs, register services.
# Usage: ./setup.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ERGO_DIR="$HOME/.config/ergo"
CADDY_DIR="$HOME/.config/caddy"
LAUNCH_DIR="$HOME/Library/LaunchAgents"

echo "=== ergo-inside setup ==="

# --- Check dependencies ---
missing=()
command -v ergo &>/dev/null || missing+=("ergo (brew install ergo or download from github.com/ergochat/ergo)")
command -v caddy &>/dev/null || missing+=("caddy (brew install caddy)")

if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing dependencies:"
    for m in "${missing[@]}"; do
        echo "  - $m"
    done
    exit 1
fi

echo "Dependencies OK: ergo $(ergo version 2>&1 | head -1), caddy $(caddy version 2>&1 | head -1)"

# --- Create directories ---
echo "Creating directories..."
mkdir -p "$ERGO_DIR" "$CADDY_DIR" "$LAUNCH_DIR"

# --- Deploy configs ---
echo "Deploying configs..."
"$SCRIPT_DIR/deploy.sh"

# --- Init ergo database (if first time) ---
if [ ! -f "$ERGO_DIR/ircd.db" ]; then
    echo "Initializing ergo database..."
    ergo initdb --conf "$ERGO_DIR/ergo.yaml" --quiet
fi

# --- Register launchd services ---
echo "Registering launchd services..."
launchctl load "$LAUNCH_DIR/com.h2os.ergo.plist" 2>/dev/null || true
launchctl load "$LAUNCH_DIR/com.h2os.caddy.plist" 2>/dev/null || true

# --- Verify ---
sleep 2
if lsof -i :6667 -sTCP:LISTEN &>/dev/null; then
    echo "ergo listening on :6667"
else
    echo "WARNING: ergo not listening on :6667 — check $ERGO_DIR/launchd.log"
fi

if lsof -i :6697 -sTCP:LISTEN &>/dev/null; then
    echo "caddy listening on :6697 (TLS)"
else
    echo "WARNING: caddy not listening on :6697 — check $CADDY_DIR/caddy.log"
fi

echo ""
echo "Setup complete. Test: openssl s_client -connect zchat.inside.h2os.cloud:6697"
