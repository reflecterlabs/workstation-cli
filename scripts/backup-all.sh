#!/bin/bash
# Backup all seats - helper script

SSOT_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
CONFIG_FILE="$SSOT_DIR/workstation.json"

echo "Backing up all seats..."

for SEAT_ID in $(jq -r '.seats[].id' "$CONFIG_FILE"); do
  WORKSPACE_PATH=$(jq -r --arg id "$SEAT_ID" '.seats[] | select(.id == $id) | .workspace_path' "$CONFIG_FILE" | sed "s|~|$HOME|g")
  BACKUP_PATH="$SSOT_DIR/_seats/$SEAT_ID"
  
  [[ -d "$WORKSPACE_PATH" ]] || continue
  
  mkdir -p "$BACKUP_PATH/archives"
  ARCHIVE="$BACKUP_PATH/archives/backup-$(date +%Y%m%d-%H%M%S).tar.gz"
  
  tar -czf "$ARCHIVE" -C "$WORKSPACE_PATH" \
    AGENT.md SOUL.md MEMORY.md TOOLS.md IDENTITY.md HEARTBEAT.md memory/ 2>/dev/null || true
  
  echo "  $SEAT_ID: $(basename "$ARCHIVE")"
done

echo "Backup complete"
