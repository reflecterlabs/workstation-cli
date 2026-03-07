# Workstation Architecture v3.0

## System Overview

Workstation is a **multi-agent organization layer** that sits on top of OpenClaw, providing:

1. **Persistent Memory** - Long-term memory across sessions
2. **Knowledge Sharing** - Shared KBs across agents  
3. **Change Coordination** - Proposals, locks, and approvals
4. **Team Management** - Multiple specialized agents
5. **Distributed Sync** - Git-based state synchronization

## Core Abstractions

### 1. Agent = Seat = Workspace

These three terms represent the same concept at different levels:

| Term | Context | Meaning |
|------|---------|---------|
| **Agent** | OpenClaw | Runtime entity with model, tools, sessions |
| **Seat** | Workstation | Logical role with memory, KB access, permissions |
| **Workspace** | Filesystem | Physical directory with configuration files |

```
┌─────────────────────────────────────────────┐
│  OpenClaw Agent "developer"                 │
│  ├── Model: claude-opus-4                   │
│  ├── Session: agent:dev:main                │
│  └── Workspace: ~/.openclaw/workspace-dev   │
├─────────────────────────────────────────────┤
│  Workstation Seat "developer"               │
│  ├── MEMORY.md (curated learnings)          │
│  ├── TOOLS.md (credentials)                 │
│  └── imports/ (KB symlinks)                 │
└─────────────────────────────────────────────┘
```

### 2. SSOT (Single Source of Truth)

A git repository that contains all organizational state:

```
Organization-SSOT/
├── workstation.json          # Central configuration
├── .locks.json               # Resource locks
├── .git/                     # Version control
│
├── KBs/                      # Knowledge Bases
│   └── Each KB is a git repo
│
├── _proposals/               # Pending changes
│   └── YYYY-MM-DD-XXX-description/
│       ├── proposal.md       # Change details
│       ├── impact.md         # Impact analysis
│       ├── rollback.md       # Rollback plan
│       ├── STATUS            # pending|approved|executed
│       └── APPROVALS         # Reviewer signatures
│
├── _seats/                   # Seat backups
│   └── {seat-id}/
│       ├── snapshots/        # Point-in-time backups
│       └── archives/         # Compressed history
│
├── Projects/                 # Cross-seat initiatives
│   └── Project-Name/
│
└── handoffs/                 # Inter-seat handoffs
    └── from-{A}-to-{B}.md
```

### 3. Knowledge Base System

KBs are **git submodules** (or just git repos) that provide shared knowledge:

```
┌─────────────────────────────────────────────┐
│  SSOT (Central Git Repo)                    │
│  └── KBs/                                   │
│      ├── KB-Core/ (git submodule)           │
│      ├── KB-Architecture/ (git submodule)   │
│      └── KB-Runbooks/ (git submodule)       │
└────────────────────┬────────────────────────┘
                     │ git clone --recursive
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
┌──────────────┐ ┌──────────┐ ┌──────────────┐
│  Machine A   │ │Machine B │ │  Machine C   │
│  Developer   │ │Architect │ │    DevOps    │
├──────────────┤ ├──────────┤ ├──────────────┤
│workspace-dev │ │workspace-│ │workspace-ops │
│              │ │architect │ │              │
│imports/      │ │imports/  │ │imports/      │
├── KB-Core/ ──┼─┼─ KB-Core/─┼─┼── KB-Core/  │
└── KB-Arch/ ──┴─┴─ KB-Arch/┴─┴── KB-Arch/  │
   (symlink)      (symlink)      (symlink)
```

KBs are **read-only** in seat workspaces. Modifications happen in SSOT.

### 4. Two-Level Memory

#### Level 1: MEMORY.md (Ingested Every Session)
- Curated, high-value information
- Key decisions, active projects, important context
- Keep under 500 lines
- Loaded into context on every agent invocation

#### Level 2: Daily Logs (memory/YYYY-MM-DD.md)
- Transient, detailed activity logs
- Not auto-ingested
- Read on-demand when recent context needed
- Rotated daily

### 5. Change Coordination

For critical changes that affect shared resources:

```
┌─────────────────────────────────────────────┐
│  Change Proposal System                     │
├─────────────────────────────────────────────┤
│                                             │
│  1. CREATE                                  │
│     └── Proposal written to _proposals/     │
│         ├── What will change                │
│         ├── Impact analysis                 │
│         └── Rollback plan                   │
│                                             │
│  2. LOCK                                    │
│     └── Resource locked in .locks.json      │
│         └── Prevents concurrent changes     │
│                                             │
│  3. REVIEW                                  │
│     └── Reviewers check proposal            │
│         └── APPROVALS file updated          │
│                                             │
│  4. EXECUTE                                 │
│     └── Change implemented                  │
│         └── Only when approved              │
│                                             │
│  5. RELEASE                                 │
│     └── Lock removed                        │
│         └── Results documented              │
│                                             │
└─────────────────────────────────────────────┘
```

## Data Flow

### Session Start

```
User invokes agent
        │
        ▼
┌─────────────────┐
│ OpenClaw Gateway│
│ loads workspace │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Ingest files:   │
│ - AGENT.md      │
│ - SOUL.md       │
│ - MEMORY.md     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Load KBs via    │
│ symlinks in     │
│ imports/        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Agent ready     │
│ for interaction │
└─────────────────┘
```

### Context Switch (Seat Change)

```
workstation seat activate architect
        │
        ▼
┌─────────────────┐
│ 1. Sync current │
│    seat state   │
│    to _seats/   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. Update       │
│    ~/.openclaw/ │
│    workspace    │
│    symlink      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 3. Restart      │
│    OpenClaw     │
│    Gateway      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 4. New seat     │
│    context      │
│    loaded       │
└─────────────────┘
```

### Cross-Machine Sync

```
Machine A (Developer)
        │
        │ git push
        ▼
┌─────────────────┐
│  GitHub/GitLab  │
│  Central Repo   │
└────────┬────────┘
         │ git pull
         ▼
Machine B (Architect)
        │
        │ workstation kb update
        ▼
┌─────────────────┐
│  KBs refreshed  │
│  symlinks       │
│  updated        │
└─────────────────┘
```

## Security Model

### Secrets Management

```
Secrets NEVER in SSOT:
❌ API keys
❌ Database passwords  
❌ Personal tokens
❌ Production credentials

Secrets in local environment:
✅ ~/.openclaw/.env
✅ Environment variables
✅ Secret management tools (Vault, etc.)
```

### Access Control

```
SSOT Repository (GitHub/GitLab)
├── Branch protection on main
├── Required reviews for changes
├── CI/CD validation
└── Audit log of all changes

Individual Seats
├── Local credentials only
├── No cross-seat file access
├── Sandboxed execution (optional)
└── Locked resources (.locks.json)
```

### Locking Strategy

```
Resource Lock (.locks.json)
{
  "locks": [
    {
      "resource": "db:production:users",
      "type": "exclusive",
      "by": "developer-1",
      "proposal": "2026-03-07-001",
      "acquired_at": "2026-03-07T10:00:00",
      "expires": "2026-03-07T14:00:00"
    }
  ]
}

TTL prevents indefinite locks
Auto-expire after 4 hours (configurable)
Force release available for admins
```

## Scalability

### Single Machine

- Unlimited seats (limited by disk)
- 1 active seat at a time (OpenClaw limitation)
- Fast context switching (~2 seconds)

### Multiple Machines

- Same SSOT cloned on each
- Git handles synchronization
- Eventual consistency model
- Conflict resolution via git merge

### Performance

```
Startup Time:
- Cold start: ~3-5 seconds
- Context switch: ~2 seconds
- KB update: ~1-5 seconds (depends on KB size)

Memory:
- MEMORY.md: < 500 lines (~10KB)
- Daily logs: Rotated, compress after 30 days
- KBs: Lazy loaded, not all in context

Disk:
- Seat workspace: ~1MB (templates + memory)
- KBs: Variable (1MB - 100MB typical)
- Snapshots: 30 retained (~30MB per seat)
- Archives: 30 days retained (~100MB per seat)
```

## Failure Modes

### Agent Crash

```
State before crash:
├── MEMORY.md (saved)
├── memory/ logs (saved)
└── Session history (in OpenClaw)

Recovery:
1. Restart OpenClaw
2. Load same workspace
3. MEMORY.md provides context
4. Continue from last known state
```

### Lock Leak

```
Scenario: Agent crashes while holding lock

Detection:
- Lock TTL expires (default 4 hours)
- Manual check: workstation locks list

Recovery:
1. Verify lock owner is dead
2. workstation lock release <resource> --force
3. Document incident
```

### Git Conflict

```
Scenario: Two agents modify workstation.json simultaneously

Detection:
- git pull fails with merge conflict
- CI/CD validation fails

Resolution:
1. Manual merge resolution
2. Prefer explicit changes over auto-merged
3. Re-validate configuration
4. Push resolved version
```

### KB Drift

```
Scenario: Local KB out of sync with remote

Detection:
- workstation kb update shows changes
- Missing recent documentation

Resolution:
1. workstation kb update
2. Re-read relevant KB sections
3. Update MEMORY.md if decisions affected
```

## Extension Points

### Custom Scripts

Place in `scripts/` directory:
```
scripts/
├── custom-sync.sh        # Custom sync logic
├── notify-slack.sh       # Slack notifications  
├── validate-proposal.sh  # Proposal validation
└── post-deploy.sh        # Post-deployment hooks
```

### Custom KB Types

```bash
# Add domain-specific KB
workstation kb add KB-Security \
  https://github.com/org/security.git

# Create local KB
cd KBs/
git init KB-ProjectX
# Add content
git add . && git commit -m "Initial"
```

### Integration Hooks

```bash
# Pre-sync hook
cat > .workstation/hooks/pre-sync << 'EOF'
#!/bin/bash
# Run tests before syncing
cd ~/project && npm test || exit 1
EOF
chmod +x .workstation/hooks/pre-sync

# Post-activate hook
cat > .workstation/hooks/post-activate << 'EOF'
#!/bin/bash
# Send notification
notify-send "Switched to seat: $1"
EOF
```

## Migration Guide

### From Single Agent

```bash
# 1. Backup current workspace
cp -r ~/.openclaw/workspace ~/.openclaw/workspace-backup

# 2. Initialize Workstation
workstation init MyOrg

# 3. Import existing workspace as first seat
workstation seat import main --from ~/.openclaw/workspace-backup

# 4. Create additional seats as needed
workstation seat create developer
workstation seat create architect

# 5. Configure OpenClaw for multi-agent
# Edit ~/.openclaw/openclaw.json
```

### From Another System

```bash
# Export from old system
old-system export > migration.json

# Transform to Workstation format
workstation migrate --from migration.json

# Validate
workstation doctor

# Test each seat
workstation seat activate developer
openclaw gateway restart
```

## Future Enhancements

### Planned Features

1. **Web UI for Seat Management**
   - Visual seat switching
   - KB browser
   - Proposal dashboard

2. **Real-time Collaboration**
   - WebSocket sync for active seats
   - Live cursor in shared docs
   - Instant notifications

3. **Advanced Orchestration**
   - Auto-agent selection based on task
   - Dynamic sub-agent spawning
   - Workflow automation

4. **Enterprise Features**
   - LDAP/SSO integration
   - Audit logging
   - Compliance reporting
   - RBAC for seats

## References

- [OpenClaw Multi-Agent](https://docs.openclaw.ai/concepts/multi-agent)
- [OpenClaw Sub-Agents](https://docs.openclaw.ai/tools/subagents)
- [SKILL.md](SKILL.md) - Main skill documentation
- [ORCHESTRATOR.md](ORCHESTRATOR.md) - Orchestration patterns
