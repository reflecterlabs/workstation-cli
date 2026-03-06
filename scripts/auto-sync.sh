#!/bin/bash
# Auto-sync for cron - helper script

SSOT_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
CONFIG_FILE="$SSOT_DIR/workstation.json"

# Update KBs
cd "$SSOT_DIR/KBs"
for kb in */; do
  [[ -d "$kb/.git" ]] || continue
  cd "$kb"
  git pull --quiet 2>/dev/null || true
  cd ..
done

# Sync each seat
for SEAT_ID in $(jq -r '.seats[].id' "$CONFIG_FILE"); do
  "$SSOT_DIR/scripts/sync-seat.sh" "$SEAT_ID" "$SSOT_DIR" || true
done

echo "Auto-sync completed: $(date)"
