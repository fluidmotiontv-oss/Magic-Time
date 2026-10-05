#!/bin/bash
# Secretary Bot Workspace & D9 Synchronization Daemon
# Manages persistent memory and temporal updates under the Port Waikato anchor

WORKSPACE="$HOME/dragon9_workspace"
LOG_FILE="$WORKSPACE/logs/secretarybot.log"
SYNC_SCRIPT="$WORKSPACE/d9-sync.sh"

mkdir -p "$(dirname "$LOG_FILE")"

echo "[$(date -u +"%Y-%m-%d %T UTC")] [SECRETARYBOT] Initializing daemon..." >> "$LOG_FILE"

# Ensure sync script exists and is executable
if [ -f "$SYNC_SCRIPT" ]; then
    chmod +x "$SYNC_SCRIPT"
    echo "[$(date -u +"%Y-%m-%d %T UTC")] [SECRETARYBOT] Triggering initial Dragon 9 sync..." >> "$LOG_FILE"
    "$SYNC_SCRIPT" --init-persistence
else
    echo "[$(date -u +"%Y-%m-%d %T UTC")] [SECRETARYBOT] ERROR: d9-sync.sh not found!" >> "$LOG_FILE"
    exit 1
fi

echo "[$(date -u +"%Y-%m-%d %T UTC")] [SECRETARYBOT] Daemon active and managing workspace memory." >> "$LOG_FILE"
echo "Secretary Bot daemon initialized successfully. Logged to $LOG_FILE"
