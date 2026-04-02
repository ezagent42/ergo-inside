#!/bin/bash
# Backup running ergo-inside config back to this repository.
# Usage: ./backup.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ERGO_DIR="$HOME/.config/ergo"
CADDY_DIR="$HOME/.config/caddy"
LAUNCH_DIR="$HOME/Library/LaunchAgents"

echo "=== ergo-inside backup ==="

# --- Ergo config + auth-script ---
for f in ergo.yaml ergo_auth_script.py auth_script_config.json; do
    src="$ERGO_DIR/$f"
    dst="$SCRIPT_DIR/$f"
    if [ -f "$src" ]; then
        if ! diff -q "$src" "$dst" &>/dev/null; then
            cp "$src" "$dst"
            echo "Updated: $f"
        else
            echo "Unchanged: $f"
        fi
    else
        echo "WARNING: $src not found, skipping"
    fi
done

# --- Caddy config ---
src="$CADDY_DIR/Caddyfile"
dst="$SCRIPT_DIR/Caddyfile"
if [ -f "$src" ]; then
    if ! diff -q "$src" "$dst" &>/dev/null; then
        cp "$src" "$dst"
        echo "Updated: Caddyfile"
    else
        echo "Unchanged: Caddyfile"
    fi
else
    echo "WARNING: $src not found, skipping"
fi

# --- LaunchAgents ---
for f in com.h2os.ergo.plist com.h2os.caddy.plist; do
    src="$LAUNCH_DIR/$f"
    dst="$SCRIPT_DIR/launchd/$f"
    if [ -f "$src" ]; then
        if ! diff -q "$src" "$dst" &>/dev/null; then
            cp "$src" "$dst"
            echo "Updated: launchd/$f"
        else
            echo "Unchanged: launchd/$f"
        fi
    else
        echo "WARNING: $src not found, skipping"
    fi
done

echo ""
echo "Backup complete. Review changes with: git diff"
