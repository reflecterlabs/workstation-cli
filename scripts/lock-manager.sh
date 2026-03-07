#!/bin/bash
#
# lock-manager.sh - Manage resource locks
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSOT_DIR="${SSOT_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

ACTION="$1"  # acquire, release, list, verify
shift || true

cd "$SSOT_DIR"

LOCKS_FILE=".locks.json"

# Initialize locks file if not exists
if [[ ! -f "$LOCKS_FILE" ]]; then
  echo '{"locks": []}' > "$LOCKS_FILE"
fi

acquire_lock() {
  local resource="$1"
  local by="${2:-$(whoami)}"
  local ttl="${3:-4h}"
  local proposal="${4:-}"
  
  # Check if already locked
  if jq -e ".locks[] | select(.resource == \"$resource\")" "$LOCKS_FILE" > /dev/null 2>&1; then
    echo "Error: Resource '$resource' is already locked"
    jq ".locks[] | select(.resource == \"$resource\")" "$LOCKS_FILE"
    exit 1
  fi
  
  # Calculate expiration
  local expires
  expires=$(date -d "+$ttl" -Iseconds 2>/dev/null || date -v+${ttl} -Iseconds)
  
  # Add lock
  jq ".locks += [{\n    \"resource\": \"$resource\",\n    \"by\": \"$by\",\n    \"proposal\": \"$proposal\",\n    \"acquired_at\": \"$(date -Iseconds)\",\n    \"expires\": \"$expires\"\n  }]" "$LOCKS_FILE" > "${LOCKS_FILE}.tmp"
  mv "${LOCKS_FILE}.tmp" "$LOCKS_FILE"
  
  echo "✓ Lock acquired: $resource"
  echo "  By: $by"
  echo "  Expires: $expires"
  [[ -n "$proposal" ]] && echo "  Proposal: $proposal"
}

release_lock() {
  local resource="$1"
  local force="${2:-}"
  local by="${3:-$(whoami)}"
  
  # Check if lock exists
  if ! jq -e ".locks[] | select(.resource == \"$resource\")" "$LOCKS_FILE" > /dev/null 2>&1; then
    echo "Error: No lock found for resource '$resource'"
    exit 1
  fi
  
  # Check ownership (unless force)
  if [[ "$force" != "--force" ]]; then
    local lock_owner
    lock_owner=$(jq -r ".locks[] | select(.resource == \"$resource\") | .by" "$LOCKS_FILE")
    if [[ "$lock_owner" != "$by" ]]; then
      echo "Error: Lock owned by $lock_owner, not you ($by)"
      echo "Use --force to override (admin only)"
      exit 1
    fi
  fi
  
  # Remove lock
  jq "del(.locks[] | select(.resource == \"$resource\"))" "$LOCKS_FILE" > "${LOCKS_FILE}.tmp"
  mv "${LOCKS_FILE}.tmp" "$LOCKS_FILE"
  
  echo "✓ Lock released: $resource"
}

list_locks() {
  local now
  now=$(date -Iseconds)
  
  echo "Active locks:"
  echo ""
  
  jq -r ".locks[] | \
    \"Resource: \" + .resource + \"\n\" + \
    \"  By: \" + .by + \"\n\" + \
    \"  Expires: \" + .expires + \"\n\" + \
    \"  Proposal: \" + (.proposal // \"none\") + \"\n\" \
  " "$LOCKS_FILE" 2>/dev/null || echo "No active locks"
}

verify_locks() {
  local now
  now=$(date +%s)
  local expired=0
  
  # Check for expired locks
  for lock in $(jq -r '.locks[] | @base64' "$LOCKS_FILE" 2>/dev/null); do
    local lock_json
    lock_json=$(echo "$lock" | base64 -d)
    
    local expires
    expires=$(echo "$lock_json" | jq -r '.expires')
    local expires_epoch
    expires_epoch=$(date -d "$expires" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${expires%%.*}" +%s 2>/dev/null)
    
    if [[ "$now" -gt "$expires_epoch" ]]; then
      local resource
      resource=$(echo "$lock_json" | jq -r '.resource')
      echo "⚠ Expired lock found: $resource"
      expired=$((expired + 1))
      
      # Auto-release expired locks
      jq "del(.locks[] | select(.resource == \"$resource\"))" "$LOCKS_FILE" > "${LOCKS_FILE}.tmp"
      mv "${LOCKS_FILE}.tmp" "$LOCKS_FILE"
    fi
  done
  
  if [[ "$expired" -eq 0 ]]; then
    echo "✓ All locks valid"
  else
    echo "✓ Cleaned up $expired expired locks"
  fi
}

case "$ACTION" in
  acquire)
    acquire_lock "$@"
    ;;
  release)
    release_lock "$@"
    ;;
  list)
    list_locks
    ;;
  verify)
    verify_locks
    ;;
  *)
    echo "Usage: $0 [acquire|release|list|verify] [options]"
    echo ""
    echo "  acquire <resource> [by] [ttl] [proposal]"
    echo "  release <resource> [--force] [by]"
    echo "  list"
    echo "  verify"
    exit 1
    ;;
esac

# Git operations
git add "$LOCKS_FILE" 2>/dev/null || true
git commit -m "Locks: $ACTION" 2>/dev/null || true
