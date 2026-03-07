#!/bin/bash
#
# review-proposal.sh - Review a change proposal
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSOT_DIR="${SSOT_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

PROPOSAL_ID="$1"
ACTION="${2:-}"  # approve, reject, request-changes
REVIEWER="${REVIEWER:-$(whoami)}"
COMMENT="${COMMENT:-}"

cd "$SSOT_DIR"

# Find proposal directory
PROPOSAL_DIR=$(find _proposals -type d -name "${PROPOSAL_ID}-*" | head -1)

if [[ -z "$PROPOSAL_DIR" ]]; then
  echo "Error: Proposal $PROPOSAL_ID not found"
  exit 1
fi

# Check current status
CURRENT_STATUS=$(cat "$PROPOSAL_DIR/STATUS")
if [[ "$CURRENT_STATUS" == "executed" ]]; then
  echo "Error: Proposal already executed"
  exit 1
fi

if [[ "$CURRENT_STATUS" == "rejected" ]]; then
  echo "Error: Proposal already rejected"
  exit 1
fi

# Update status based on action
case "$ACTION" in
  approve)
    echo "approver: $REVIEWER" >> "$PROPOSAL_DIR/APPROVALS"
    echo "date: $(date -Iseconds)" >> "$PROPOSAL_DIR/APPROVALS"
    echo "status: approved" >> "$PROPOSAL_DIR/APPROVALS"
    if [[ -n "$COMMENT" ]]; then
      echo "comment: $COMMENT" >> "$PROPOSAL_DIR/APPROVALS"
    fi
    echo "" >> "$PROPOSAL_DIR/APPROVALS"
    
    # Update proposal.md checkboxes
    sed -i "s/- \[ \] $REVIEWER/- [x] $REVIEWER/" "$PROPOSAL_DIR/proposal.md"
    
    # Check if all reviewers approved
    TOTAL_REVIEWERS=$(grep -c "^- \[" "$PROPOSAL_DIR/proposal.md" || echo "0")
    APPROVED_REVIEWERS=$(grep -c "^- \[x\]" "$PROPOSAL_DIR/proposal.md" || echo "0")
    
    if [[ "$APPROVED_REVIEWERS" -ge "$TOTAL_REVIEWERS" && "$TOTAL_REVIEWERS" -gt 0 ]]; then
      echo "approved" > "$PROPOSAL_DIR/STATUS"
      echo "✓ Proposal $PROPOSAL_ID fully approved"
    else
      echo "reviewing" > "$PROPOSAL_DIR/STATUS"
      echo "✓ Approved by $REVIEWER ($APPROVED_REVIEWERS/$TOTAL_REVIEWERS)"
    fi
    ;;
    
  reject)
    echo "rejected" > "$PROPOSAL_DIR/STATUS"
    echo "rejected_by: $REVIEWER" >> "$PROPOSAL_DIR/APPROVALS"
    echo "date: $(date -Iseconds)" >> "$PROPOSAL_DIR/APPROVALS"
    if [[ -n "$COMMENT" ]]; then
      echo "reason: $COMMENT" >> "$PROPOSAL_DIR/APPROVALS"
    fi
    echo "✗ Proposal $PROPOSAL_ID rejected by $REVIEWER"
    ;;
    
  request-changes)
    echo "changes_requested" > "$PROPOSAL_DIR/STATUS"
    echo "requested_by: $REVIEWER" >> "$PROPOSAL_DIR/APPROVALS"
    echo "date: $(date -Iseconds)" >> "$PROPOSAL_DIR/APPROVALS"
    if [[ -n "$COMMENT" ]]; then
      echo "changes_needed: $COMMENT" >> "$PROPOSAL_DIR/APPROVALS"
    fi
    echo "→ Changes requested by $REVIEWER"
    ;;
    
  *)
    echo "Usage: $0 <proposal-id> [approve|reject|request-changes]"
    echo ""
    echo "Current proposal status:"
    cat "$PROPOSAL_DIR/proposal.md" | head -20
    exit 1
    ;;
esac

# Git operations
git add "$PROPOSAL_DIR"
git commit -m "Review: $ACTION $PROPOSAL_ID by $REVIEWER" || true

echo ""
echo "Remember to push: git push origin main"
