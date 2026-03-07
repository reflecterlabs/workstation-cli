---
name: workstation
description: Organization management for AI agents. Manage multi-agent teams, knowledge bases, and persistent memory across sessions. Use when organizing multiple AI agents, sharing knowledge between agents, or managing agent workspaces with OpenClaw. Triggers on requests like "create an agent workspace", "organize AI team", "share knowledge base", "manage agent memory", or when working with OpenClaw multi-agent setups.
---

# Workstation Skill

Manage AI agent organizations with structured workspaces, shared knowledge bases, and persistent memory.

## Quick Start

```bash
# Initialize organization
workstation init MyOrg

# Create agent seat
cd ~/Workstation/MyOrg-SSOT
workstation seat create developer --role backend

# Activate
workstation seat activate developer
```

## Core Concepts

### Organization (SSOT)

Single Source of Truth - a git repository containing:
- `workstation.json` - Central configuration
- `KBs/` - Knowledge Bases (shared knowledge)
- `_seats/` - Agent state backups
- `Projects/` - Cross-agent projects

### Seat

An agent workspace:
- Individual workspace in `~/.openclaw/workspace-<seat>/`
- Own AGENT.md, SOUL.md, MEMORY.md
- Access to shared KBs via symlinks
- Backed up to SSOT

### Knowledge Base

Git repository with organizational knowledge:
- Shared across seats
- Version controlled
- Updated via `workstation kb update`

## Commands

### Organization
```bash
workstation init <name>              # Create new organization
```

### Seats
```bash
workstation seat create <id>         # Create agent workspace
workstation seat activate <id>       # Switch active workspace
workstation seat list                # List all seats
workstation seat sync [id]           # Backup and sync
```

### Knowledge Bases
```bash
workstation kb add <name> <repo>     # Add KB from git
workstation kb update                # Update all KBs
workstation kb list                  # List KBs
```

### Maintenance
```bash
workstation backup                   # Full backup
workstation status                   # Show status
workstation doctor                   # Check installation
```

## Agent Files

Each seat contains these files (see [templates/](assets/templates/)):

- **AGENT.md** - Operational manual, protocols, workflows
- **SOUL.md** - Personality, values, communication style
- **MEMORY.md** - Long-term curated memory
- **TOOLS.md** - Available tools and access credentials
- **HEARTBEAT.md** - Proactive task checklist
- **IDENTITY.md** - Identity per channel

## Memory System

### Two-Level Architecture

1. **MEMORY.md** (injected every session)
   - Curated long-term memory
   - Key learnings, decisions, contacts
   - Keep under 500 lines

2. **memory/YYYY-MM-DD.md** (on-demand)
   - Daily activity logs
   - Not auto-injected
   - Rotated daily

### Bootstrap Process

New seats include BOOTSTRAP.md - a self-destructing onboarding ritual:
1. Agent reads BOOTSTRAP.md on first startup
2. Follows checklist to configure identity
3. Deletes BOOTSTRAP.md when complete
4. Documents completion in MEMORY.md

## Change Orchestration

For critical changes across distributed agents:

### Create Proposal
```bash
workstation propose change \
  --title "Add user_preferences table" \
  --resource "database:production" \
  --impact "high" \
  --reviewers "architect,dba"
```

### Review and Approve
```bash
workstation proposals list --status pending
workstation proposal review 2026-03-07-001 --approve --as architect
```

### Lock Resources
```bash
workstation lock acquire database:production:users --ttl 4h
workstation locks list
workstation lock release database:production:users
```

See [ORCHESTRATOR.md](ORCHESTRATOR.md) for complete workflow.

## Installation

```bash
# Via curl
curl -fsSL https://raw.githubusercontent.com/reflecterlabs/workstation-cli/main/install.sh | bash

# Or from source
git clone https://github.com/reflecterlabs/workstation-cli.git
cd workstation-cli
sudo make install
```

## Architecture

```
~/.openclaw/                          # OpenClaw runtime
├── workspace/                        # Symlink to active seat
├── workspace-developer/              # Individual seat
└── openclaw.json                     # OpenClaw config

~/Workstation/
└── MyOrg-SSOT/                       # Organization SSOT
    ├── workstation.json              # Central config
    ├── KBs/KB-Core/                  # Knowledge Bases
    ├── _seats/developer/             # Seat backups
    └── templates/seat/               # Seat templates
```

## Scripts

Use bundled scripts for common operations:

- [scripts/sync-seat.sh](scripts/sync-seat.sh) - Synchronize single seat
- [scripts/backup-all.sh](scripts/backup-all.sh) - Full backup
- [scripts/auto-sync.sh](scripts/auto-sync.sh) - Cron automation
- [scripts/propose-change.sh](scripts/propose-change.sh) - Create change proposal
- [scripts/review-proposal.sh](scripts/review-proposal.sh) - Review workflow
- [scripts/lock-manager.sh](scripts/lock-manager.sh) - Resource locking

## References

- [references/workflows.md](references/workflows.md) - Common workflows
- [references/configuration.md](references/configuration.md) - Config options
- [references/examples.md](references/examples.md) - Example organizations

## CI/CD Integration

GitHub Actions workflow in `.github/workflows/ci.yml`:

```yaml
- name: Setup Workstation
  run: |
    git config --global user.name "CI"
    git config --global user.email "ci@example.com"
    workstation init MyOrg
    workstation seat create ci-agent
```

## Best Practices

1. **Keep MEMORY.md concise** - Under 500 lines, curate regularly
2. **Use descriptive seat IDs** - e.g., `backend-dev`, not `agent1`
3. **Commit often** - Workstation auto-commits on sync
4. **Use KBs for shared knowledge** - Don't duplicate in seats
5. **Configure git user** - Required for commits

## Common Patterns

### Development Team
```bash
workstation init DevTeam
workstation seat create frontend --role frontend
workstation seat create backend --role backend
workstation kb add standards https://github.com/org/standards.git
```

### Research Organization
```bash
workstation init ResearchLab
workstation seat create researcher-1 --role data-science
workstation seat create researcher-2 --role bioinformatics
```

### Multi-Project Agency
```bash
workstation init Agency
workstation seat create client-a --role account-manager
workstation seat create client-b --role account-manager
workstation seat create analyst --role data-analyst
```

## Troubleshooting

### "No workstation.json found"
Navigate to an SSOT directory or run `workstation init <name>`.

### "git config user.name/email needed"
Configure git globally or per-repo before running workstation commands.

### Sync failures
Ensure git is configured and you have write access to the SSOT repository.

## Links

- Repository: https://github.com/reflecterlabs/workstation-cli
- Documentation: https://github.com/reflecterlabs/workstation-cli/blob/main/README.md
- Issues: https://github.com/reflecterlabs/workstation-cli/issues
