#!/bin/bash
#
# propose-change.sh - Create a change proposal
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSOT_DIR="${1:-$(cd "$SCRIPT_DIR/.." && pwd)}"

cd "$SSOT_DIR"

# Generate proposal ID
DATE=$(date +%Y-%m-%d)
SEQUENCE=$(ls -1 _proposals/ 2>/dev/null | grep "^$DATE" | wc -l)
SEQUENCE=$((SEQUENCE + 1))
SEQUENCE_PADDED=$(printf "%03d" $SEQUENCE)
PROPOSAL_ID="${DATE}-${SEQUENCE_PADDED}"

# Parse arguments
TITLE="${TITLE:-Untitled Change}"
RESOURCE="${RESOURCE:-unknown}"
IMPACT="${IMPACT:-medium}"  # low, medium, high, critical
REVIEWERS="${REVIEWERS:-}"
PROPOSED_BY="${PROPOSED_BY:-$(whoami)}"

# Create proposal directory
PROPOSAL_DIR="_proposals/${PROPOSAL_ID}-$(echo "$TITLE" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-')"
mkdir -p "$PROPOSAL_DIR"

# Create proposal.md
cat > "$PROPOSAL_DIR/proposal.md" << EOF
# Change Proposal: $TITLE

**ID**: $PROPOSAL_ID  
**Proposed by**: $PROPOSED_BY  
**Date**: $(date -Iseconds)  
**Status**: pending  
**Resource**: $RESOURCE  
**Impact**: $IMPACT

## Description
[Describe the change here]

## Changes
[Detail what will be modified]

## Impact Analysis
- **Resource**: $RESOURCE
- **Impact Level**: $IMPACT
- **Backwards Compatible**: [Yes/No]
- **Estimated Downtime**: [None/Seconds/Minutes]

## Testing Plan
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Rollback Plan
[How to undo this change if needed]

## Approvals Required
EOF

# Add reviewer checkboxes
for reviewer in $(echo "$REVIEWERS" | tr ',' ' '); do
  echo "- [ ] $reviewer" >> "$PROPOSAL_DIR/proposal.md"
done

# Create impact.md
cat > "$PROPOSAL_DIR/impact.md" << EOF
# Impact Analysis: $TITLE

## Resource Impact
- Resource: $RESOURCE
- Type: [read/write/schema/infra]
- Duration: [temporary/permanent]

## Dependencies
[List what depends on this resource]

## Risk Assessment
- Likelihood: [low/medium/high]
- Impact: [$IMPACT]
- Mitigation: [How to reduce risk]

## Performance Impact
[Expected performance changes]
EOF

# Create rollback.md
cat > "$PROPOSAL_DIR/rollback.md" << EOF
# Rollback Plan: $TITLE

## Automatic Rollback
[Can this be rolled back automatically?]

## Manual Rollback Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Verification
[How to verify rollback succeeded]

## Data Preservation
[What data needs to be preserved during rollback]
EOF

# Create STATUS file
echo "pending" > "$PROPOSAL_DIR/STATUS"

# Create REVIEWERS file
echo "$REVIEWERS" | tr ',' '\n' > "$PROPOSAL_DIR/REVIEWERS"

# Create APPROVALS file (empty)
touch "$PROPOSAL_DIR/APPROVALS"

# Create LOCK file (for tracking)
cat > "$PROPOSAL_DIR/LOCK" << EOF
resource: $RESOURCE
status: none
acquired_by: 
acquired_at: 
expires_at: 
EOF

echo "Proposal created: $PROPOSAL_ID"
echo "Directory: $PROPOSAL_DIR"
echo ""
echo "Next steps:"
echo "1. Edit $PROPOSAL_DIR/proposal.md"
echo "2. Complete impact.md and rollback.md"
echo "3. Run: git add $PROPOSAL_DIR && git commit -m \"Proposal: $TITLE\""
echo "4. Request reviews from: $REVIEWERS"
