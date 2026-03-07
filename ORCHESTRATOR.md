---
name: workstation-orchestrator
description: Coordinate critical changes across distributed agents. Use when modifying production databases, changing API contracts, updating shared configurations, or any operation that requires multi-agent review and approval. Triggers on requests like "propose change", "review modification", "approve database migration", "orchestrate deployment", or when working with critical shared resources.
---

# Workstation Orchestrator

Coordinate critical changes across distributed agents with proposals, reviews, and state tracking.

## Overview

When multiple agents work on shared resources (databases, APIs, configurations), changes must be:
1. **Proposed** - Documented before execution
2. **Reviewed** - Approved by another agent
3. **Tracked** - State visible to all
4. **Coordinated** - No conflicts or race conditions

## Change Proposal System

### Creating a Proposal

```bash
# Agent A wants to modify production DB
workstation propose change \
  --title "Add user_preferences table" \
  --resource "database:production" \
  --impact "high" \
  --reviewers "architect,dba"
```

This creates:
```
_proposals/
└── 2026-03-07-001-add-user-preferences/
    ├── proposal.md          # Detalles del cambio
    ├── impact.md            # Análisis de impacto
    ├── rollback.md          # Plan de rollback
    ├── STATUS               # pending|reviewing|approved|rejected|executed
    ├── REVIEWERS            # Lista de revisores
    └── APPROVALS            # Firmas de aprobación
```

### Proposal Template (proposal.md)

```markdown
# Change Proposal: Add user_preferences table

**ID**: 2026-03-07-001  
**Proposed by**: developer-1  
**Date**: 2026-03-07  
**Status**: pending  
**Resource**: database:production  
**Impact**: high

## Description
Add a new table `user_preferences` to store user settings and preferences.

## Changes
```sql
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY,
  preferences JSONB NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## Impact Analysis
- **Database**: New table, ~10MB initial size
- **API**: New endpoints needed (see impact.md)
- **Backwards Compatible**: Yes
- **Rollback**: DROP TABLE (see rollback.md)

## Testing Plan
1. Run migrations on staging
2. Test API endpoints
3. Verify rollback procedure

## Approvals Required
- [ ] architect (schema review)
- [ ] dba (performance review)
```

## Review Workflow

### Agent B Reviews

```bash
# List pending proposals
workstation proposals list --status pending

# Review specific proposal
cd _proposals/2026-03-07-001-add-user-preferences
cat proposal.md
cat impact.md

# Request changes or approve
workstation proposal approve 2026-03-07-001 \
  --as architect \
  --comment "Schema looks good, indexes recommended on user_id"
```

### Approval Recording

```bash
# APPROVALS file gets updated:
approver: architect
date: 2026-03-07T10:30:00
status: approved
comment: "Schema approved with recommendations"
```

## State Tracking

### KB State Files

Each KB tracks its current state:

```
KBs/KB-Core/
├── README.md
├── .state/                    # Estado del KB
│   ├── current.json          # Estado actual
│   ├── lock.json             # Locks activos
│   └── history/              # Historial de cambios
│       ├── 2026-03-06-001.json
│       └── 2026-03-07-001.json
```

### current.json

```json
{
  "version": "2.1.0",
  "last_updated": "2026-03-07T09:00:00",
  "active_proposals": [
    "2026-03-07-001"
  ],
  "locked_resources": [
    {
      "resource": "database:production",
      "by": "developer-1",
      "proposal": "2026-03-07-001",
      "since": "2026-03-07T08:00:00"
    }
  ],
  "last_modified_by": "architect",
  "checksum": "sha256:abc123..."
}
```

### lock.json

```json
{
  "locks": [
    {
      "resource": "database:production:users_table",
      "type": "exclusive",
      "by": "developer-1",
      "proposal": "2026-03-07-001",
      "expires": "2026-03-07T12:00:00"
    }
  ]
}
```

## Commands

### Proposals

```bash
# Create proposal
workstation propose change --title "..." --resource "..."

# List proposals
workstation proposals list [--status pending|approved|rejected|executed]

# Review proposal
workstation proposal review <id> [--approve|--reject|--request-changes]

# Check status
workstation proposal status <id>

# Execute approved proposal
workstation proposal execute <id> [--dry-run]
```

### Locks

```bash
# Acquire lock on resource
workstation lock acquire <resource> [--ttl 2h] [--proposal <id>]

# Release lock
workstation lock release <resource>

# List active locks
workstation locks list

# Force release (admin only)
workstation lock release <resource> --force
```

### State

```bash
# Check KB state
workstation state check <kb-name>

# Update KB state
workstation state update <kb-name> [--proposal <id>]

# Sync all KB states
workstation state sync

# Show conflicts
workstation state conflicts
```

## Critical Change Workflow

### Scenario: Database Migration

```bash
# 1. Developer proposes change
workstation propose change \
  --title "Migrate users to UUID" \
  --resource "database:production:users" \
  --impact critical \
  --reviewers "dba,architect"
# Output: Proposal created: 2026-03-07-005-migrate-users-uuid

# 2. System checks for conflicts
workstation state check database:production
# Output: No active locks, resource available

# 3. Lock is acquired
workstation lock acquire database:production:users \
  --proposal 2026-03-07-005 \
  --ttl 4h

# 4. DBA reviews
workstation proposal review 2026-03-07-005 --approve --as dba

# 5. Architect reviews
workstation proposal review 2026-03-07-005 --approve --as architect

# 6. Execute (only when all approvals ready)
workstation proposal execute 2026-03-07-005 --dry-run  # First test
workstation proposal execute 2026-03-07-005            # Then execute

# 7. Lock released automatically
workstation locks list
# Output: No active locks on database:production:users
```

## Distributed Coordination

### Sync Across Machines

```bash
# Machine A (Developer)
workstation propose change ...
git add _proposals/
git commit -m "Proposal: Add user preferences"
git push origin main

# Machine B (DBA)
git pull origin main
workstation proposals list  # See new proposal
workstation proposal review ... --approve
git add _proposals/
git commit -m "Review: Approve user preferences"
git push origin main

# Machine A sees approval
git pull origin main
workstation proposal execute ...
```

## Safety Rules

### Auto-Reject Conditions

```bash
# Proposal is auto-rejected if:
- Resource is already locked by another proposal
- Checksum mismatch in KB state
- Required reviewers not available
- Rollback plan not provided for critical changes
```

### Lock Expiration

```bash
# Locks expire automatically (default: 4 hours)
# Prevents indefinite locks if agent crashes
workstation lock acquire ... --ttl 2h  # Custom TTL

# Warning at 80% of TTL
# Alert at 95% of TTL
# Auto-release at 100% with notification
```

## CI/CD Integration

### GitHub Action

```yaml
name: Critical Change Review

on:
  push:
    paths:
      - '_proposals/**'

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Check proposal status
        run: |
          workstation doctor
          
          # Verify all critical proposals have 2+ approvals
          for proposal in _proposals/*/; do
            if [[ $(cat "$proposal/impact.md" | grep -c "critical") -gt 0 ]]; then
              approvals=$(grep -c "^approver:" "$proposal/APPROVALS")
              if [[ $approvals -lt 2 ]]; then
                echo "ERROR: Critical proposal missing approvals: $proposal"
                exit 1
              fi
            fi
          done
      
      - name: Validate locks
        run: |
          # Ensure no expired locks
          workstation locks verify
```

## Best Practices

### For Proposers

1. **Always provide rollback plan** for critical changes
2. **Include testing steps** in proposal
3. **Set realistic TTL** for locks (not too short, not infinite)
4. **Notify reviewers** via Discord/Slack when proposal ready

### For Reviewers

1. **Check impact analysis** thoroughly
2. **Verify rollback plan** is feasible
3. **Test on staging** if possible
4. **Document concerns** clearly if rejecting

### For System

1. **Auto-expire locks** to prevent deadlocks
2. **Maintain audit log** of all changes
3. **Alert on conflicts** immediately
4. **Backup before execution** of critical changes

## Emergency Procedures

### Breaking Glass (Emergency Override)

```bash
# In true emergency, admin can override
workstation proposal execute <id> --emergency \
  --reason "Production down, immediate fix needed"
# This:
# - Executes immediately
# - Logs emergency reason
# - Notifies all team members
# - Creates post-mortem requirement
```

### Conflict Resolution

```bash
# When two agents propose changes to same resource
workstation conflicts list

# Output:
# CONFLICT: database:production
#   Proposal 2026-03-07-001 by developer-1 (LOCKED)
#   Proposal 2026-03-07-002 by developer-2 (PENDING)

# Resolve:
# 1. Reject newer proposal
workstation proposal reject 2026-03-07-002 \
  --reason "Resource locked by 2026-03-07-001"

# 2. Or coordinate sequential execution
workstation proposal schedule 2026-03-07-002 \
  --after 2026-03-07-001
```

## Scripts Reference

- [scripts/propose-change.sh](scripts/propose-change.sh) - Create proposal
- [scripts/review-proposal.sh](scripts/review-proposal.sh) - Review workflow
- [scripts/lock-manager.sh](scripts/lock-manager.sh) - Resource locking
- [scripts/state-sync.sh](scripts/state-sync.sh) - State synchronization

## Integration with workstation-cli

The orchestrator extends workstation with:
- `_proposals/` directory in SSOT
- `.state/` directory in each KB
- Lock management commands
- Proposal workflow commands

Install alongside workstation-cli for full coordination capabilities.
