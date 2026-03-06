#!/bin/bash
# Sync single seat - helper script

SEAT_ID="${1:-}"
SSOT_DIR="${2:-$(pwd)}"

if [[ -z "$SEAT_ID" ]]; then
  echo "Usage: sync-seat.sh <seat-id> [ssot-dir]"
  exit 1
fi

CONFIG_FILE="$SSOT_DIR/workstation.json"
WORKSPACE_PATH=$(jq -r --arg id "$SEAT_ID" '.seats[] | select(.id == $id) | .workspace_path' "$CONFIG_FILE" | sed "s|~|$HOME|g")
BACKUP_PATH="$SSOT_DIR/_seats/$SEAT_ID"

mkdir -p "$BACKUP_PATH/snapshots"
SNAPSHOT="$BACKUP_PATH/snapshots/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$SNAPSHOT"

# Backup files
FILES=("AGENT.md" "SOUL.md" "MEMORY.md" "TOOLS.md" "IDENTITY.md" "HEARTBEAT.md")
for file in "${FILES[@]}"; do
  [[ -f "$WORKSPACE_PATH/$file" ]] && cp "$WORKSPACE_PATH/$file" "$snapshot/"
done

# Update KB symlinks
ORG_NAME=$(jq -r '.organization.name' "$CONFIG_FILE")
KBS=$(jq -r --arg id "$SEAT_ID" '.seats[] | select(.id == $id) | .kbs[]' "$CONFIG_FILE" 2>/dev/null)

for kb in $KBS; do
  KB_PATH="$SSOT_DIR/KBs/$kb"
  LINK_PATH="$WORKSPACE_PATH/imports/$ORG_NAME/$kb"
  [[ -d "$KB_PATH" ]] && ln -sf "$KB_PATH" "$LINK_PATH"
done

echo "Synced $SEAT_ID"
