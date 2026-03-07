---
name: workstation
description: Enterprise-grade multi-agent organization system for OpenClaw with ORQ coordination protocol. Manages agent teams, shared knowledge bases, persistent memory, and file-level locking for coordinated editing across distributed systems. CRITICAL - Agents MUST check ORQ protocol before editing shared files to prevent conflicts. Use when building AI teams, sharing knowledge between agents, managing production changes with approval workflows, or orchestrating multi-role agent collaborations.
---

# Workstation v3.0 - Multi-Agent Organization System

> **Enterprise-grade agent coordination for OpenClaw**

Workstation transforms OpenClaw from a single-agent tool into a **multi-agent organization platform**, enabling teams of AI agents to collaborate with shared knowledge, persistent memory, and coordinated change management.

## ⚠️ IMPORTANT: Multi-Agent Coordination Protocol (ORQ)

When working in a Workstation environment, **YOU MUST** follow the ORQ (Orchestration Queue) protocol to avoid conflicts with other agents.

### Agent Auto-Configuration

**When you start a session in a Workstation seat, automatically:**

1. **Detect Workstation context:**
   ```bash
   # Check if you're in a Workstation environment
   if [[ -d ".openclaw/workspace" && -f "workstation.json" ]] || \
      [[ -d "../.openclaw/workspace" ]]; then
     echo "Workstation environment detected"
   fi
   ```

2. **Check ORQ status immediately:**
   ```bash
   # At session start, ALWAYS run:
   workstation orq clean     # Remove expired claims
   workstation orq status    # See what others are doing
   ```

3. **Read seat configuration:**
   ```bash
   # Your seat has configuration in:
   # - .openclaw/workspace/AGENT.md  (how to operate)
   # - .openclaw/workspace/SOUL.md   (who you are)
   # - .openclaw/workspace/MEMORY.md (what you know)
   # - .openclaw/workspace/TOOLS.md  (what you can use)
   # - .orq/claims.yaml              (your active claims)
   ```

4. **Understand your role from AGENT.md:**
   - Read AGENT.md first
   - It contains protocols specific to this seat
   - Follow any seat-specific rules there

### Automatic ORQ Detection

Check if you're in an ORQ-enabled environment:
```bash
# Look for .orq directory in your seat
ls -la ~/.openclaw/workspace-*/.orq/ 2>/dev/null && echo "ORQ ENABLED" || echo "Standard mode"
```

### ORQ Protocol for Agents

**Before editing ANY shared file (KBs, SSOT, Projects):**

1. **Check availability:**
   ```bash
   workstation orq check KB/path/to/file.md
   ```

2. **If available, create claim:**
   ```bash
   workstation orq claim KB/path/to/file.md --ttl 30m --reason "Updating section X"
   ```

3. **Edit the file**

4. **Commit and release:**
   ```bash
   git add KB/path/to/file.md
   git commit -m "update: description"
   git push
   workstation orq release KB/path/to/file.md
   ```

**If file is claimed by another agent:**
- Wait for them to finish
- Or coordinate via the claim reason
- Never edit without checking first

### Interpreting ORQ Claims

When you see `.orq/claims.yaml` in another seat:

```yaml
claims:
  - id: "claim-20260307-001"
    concept: "api-documentation"
    files:
      - "KB/docs/api.md"
    created: "2026-03-07T07:30:00Z"
    expires: "2026-03-07T08:00:00Z"  # Check this!
    ttl_minutes: 30
    reason: "Adding OAuth2 endpoints"
    seat: "backend"
```

**Rules:**
- If `expires` is in the future → **DON'T EDIT** those files
- If `expires` is in the past → Claim is stale, ignore it
- You can READ files anytime, just don't modify

### Automatic Protocol Enforcement

**YOU SHOULD** automatically run these checks:

1. **At session start:**
   ```bash
   workstation orq status    # See what others are doing
   workstation orq clean     # Remove expired claims
   ```

2. **Before any edit:**
   ```bash
   workstation orq check <file>  # Verify availability
   ```

3. **After completing work:**
   ```bash
   workstation orq release <file>  # Free the resource
   ```

## Core Concepts

### 🎭 Agent = Seat = Workspace

In Workstation, these terms are interchangeable:
- **Agent** (OpenClaw): Runtime entity with model, tools, sessions
- **Seat** (Workstation): Persistent workspace with memory, KB access, role
- **Workspace**: Physical directory with `AGENT.md`, `SOUL.md`, `MEMORY.md`

```
┌─────────────────────────────────────────────┐
│           OpenClaw Gateway                  │
├─────────────────────────────────────────────┤
│  Agent: "developer"                         │
│  ├── Workspace: ~/.openclaw/workspace-dev   │
│  ├── Model: claude-opus-4                   │
│  └── Sessions: agent:dev:main               │
│                                             │
│  Workstation Seat: "developer"              │
│  ├── MEMORY.md (persistent learnings)       │
│  ├── TOOLS.md (access & credentials)        │
│  ├── .orq/claims.yaml (ORQ coordination)    │  ← ORQ enabled
│  └── imports/KB-Core (shared knowledge)     │
└─────────────────────────────────────────────┘
```

### 🏛️ SSOT (Single Source of Truth)

Every organization has one git repository:

```
Organization-SSOT/
├── workstation.json          # Central configuration
├── KBs/                      # Knowledge Bases (git submodules)
│   ├── KB-Core/              # Organizational standards
│   ├── KB-Architecture/      # Architecture decisions
│   └── KB-Runbooks/          # Operational procedures
├── _proposals/               # Change proposals pending review
├── _seats/                   # Seat state backups
│   └── developer/
│       ├── snapshots/        # Point-in-time backups
│       └── archives/         # Compressed history
├── Projects/                 # Cross-seat initiatives
└── handoffs/                 # Inter-seat handoff documents
```

### 📚 Knowledge Base System

KBs are **git repositories** shared across all seats:

```bash
# Clone once, use everywhere
workstation kb add KB-Security https://github.com/org/security-standards.git

# Every seat gets symlinks:
~/.openclaw/workspace-{seat}/imports/
└── Organization/
    ├── KB-Core -> ~/Workstation/SSOT/KBs/KB-Core/
    ├── KB-Security -> ~/Workstation/SSOT/KBs/KB-Security/
    └── KB-Architecture -> ~/Workstation/SSOT/KBs/KB-Architecture/
```

KBs are **read-only** in seats. Modify in SSOT, then:
```bash
workstation kb update  # Pulls latest, updates all seat symlinks
```

### 🧠 Two-Level Memory Architecture

#### Level 1: MEMORY.md (Ingested Every Session)
```markdown
# Memory: {seat_id}

## Current Focus
Building authentication system v2

## Key Decisions
- JWT with asymmetric keys (decided 2026-03-06)
- Redis for refresh tokens (not DB)

## Active Projects
- Project-API-v2: 70% complete
  - Blocked on: security review
  - Next: implement refresh endpoint

## Important Context
- Never use symmetric keys for JWT (lesson from v1)
- Redis cluster: redis.internal:6379
- Security contact: @security-lead
```

**Best practice**: Keep under 500 lines. Curate ruthlessly.

#### Level 2: Daily Logs (memory/YYYY-MM-DD.md)
```markdown
# 2026-03-07

## Session 1 (09:00-11:00)
- Implemented JWT signing
- Issue: Key rotation strategy unclear
- Escalated to architect

## Session 2 (14:00-16:00)  
- Architect provided key rotation plan
- Updated MEMORY.md with decision
- Tests passing
```

Logs are **not auto-ingested**. Read on-demand when you need recent context.

### 🔒 Multi-Agent Coordination (ORQ Protocol)

For editing shared files (KBs, SSOT, Projects), use the **ORQ (Orchestration Queue)** protocol:

```bash
# 1. Check if file is available
workstation orq check KB/architecture/auth.md

# 2. If available, claim it
workstation orq claim KB/architecture/auth.md \
  --ttl 45m \
  --reason "Adding OAuth2 flow documentation"

# 3. Edit the file...
# (your work here)

# 4. Commit changes
git add KB/architecture/auth.md
git commit -m "docs: add OAuth2 flow documentation"
git push

# 5. Release the claim
workstation orq release KB/architecture/auth.md
```

#### ORQ Command Reference

```bash
workstation orq claim <file> [options]     # Claim file for editing
  --ttl 30m        # Time to live (15m, 30m, 1h, 2h)
  --reason "..."   # Why you're editing
  --concept "..."  # Concept/section being edited

workstation orq release <file> [--id <id>]  # Release claim
workstation orq check <file>                # Check availability
workstation orq status                      # Show all active claims
workstation orq sync                        # Sync claims from other seats
workstation orq clean                       # Remove expired claims
```

#### Claim File Format

Claims are stored in `.orq/claims.yaml`:

```yaml
claims:
  - id: "claim-20260307-001"
    concept: "oauth2-docs"
    files:
      - "KB/architecture/auth.md"
    created: "2026-03-07T07:30:00Z"
    expires: "2026-03-07T08:15:00Z"  # TTL determines this
    ttl_minutes: 45
    reason: "Adding OAuth2 flow documentation"
    seat: "developer"
```

**Expired claims are ignored automatically.** No manual cleanup needed.

### 📋 Change Proposals

For major changes requiring review:

```bash
# 1. Create proposal
workstation propose change \
  --title "Add OAuth2 provider support" \
  --resource "api:authentication" \
  --impact high \
  --reviewers "architect,security-lead"

# 2. Check status
workstation proposals list --status pending

# 3. Review (as another agent)
workstation proposal review 2026-03-07-001 --approve --as dba

# 4. Execute when approved
workstation proposal execute 2026-03-07-001
```

## Quick Start

### 1. Initialize Organization

```bash
# Install
npm install -g openclaw  # Install OpenClaw first
curl -fsSL https://raw.githubusercontent.com/reflecterlabs/workstation-cli/main/install.sh | bash

# Create org
workstation init MyOrg
cd ~/Workstation/MyOrg-SSOT
```

### 2. Create Your First Seat

```bash
workstation seat create developer --role backend --model claude-opus-4

# This creates:
# - ~/.openclaw/workspace-developer/
# - AGENT.md, SOUL.md, MEMORY.md, TOOLS.md
# - ~/Workstation/MyOrg-SSOT/_seats/developer/
```

### 3. Configure OpenClaw

```json
// ~/.openclaw/openclaw.json
{
  "agents": {
    "list": [
      {
        "id": "developer",
        "workspace": "~/.openclaw/workspace-developer",
        "model": "anthropic/claude-opus-4",
        "default": true
      }
    ]
  },
  "bindings": [
    {
      "agentId": "developer",
      "match": { "channel": "discord" }
    }
  ]
}
```

### 4. Start Working

```bash
workstation seat activate developer
openclaw gateway restart

# Agent now has:
# - Its own MEMORY.md for persistent learnings
# - Access to shared KBs
# - Backup system active
```

## Multi-Agent Setup

### Scenario: Development Team

```bash
workstation init DevTeam

# Create specialized seats
workstation seat create frontend --role frontend
workstation seat create backend --role backend  
workstation seat create architect --role system-design
workstation seat create devops --role infrastructure

# Add shared KBs
workstation kb add KB-Standards https://github.com/org/standards.git
workstation kb add KB-Architecture https://github.com/org/architecture.git
```

### OpenClaw Configuration

```json
{
  "agents": {
    "list": [
      { "id": "frontend", "workspace": "~/.openclaw/workspace-frontend" },
      { "id": "backend", "workspace": "~/.openclaw/workspace-backend" },
      { "id": "architect", "workspace": "~/.openclaw/workspace-architect" },
      { "id": "devops", "workspace": "~/.openclaw/workspace-devops" }
    ]
  },
  "bindings": [
    { "agentId": "frontend", "match": { "channel": "discord", "peer": { "id": "#frontend" } } },
    { "agentId": "backend", "match": { "channel": "discord", "peer": { "id": "#backend" } } },
    { "agentId": "architect", "match": { "channel": "telegram" } }
  ]
}
```

### Context Switching

```bash
# Developer hands off to architect for review
workstation seat sync developer
git commit -m "WIP: Auth system ready for review"

workstation seat activate architect
openclaw gateway restart
# Architect now has access to developer's MEMORY.md

# After review, architect hands back
workstation seat sync architect
workstation seat activate developer
openclaw gateway restart
```

## Distributed Teams

### Setup Across Multiple Machines

```bash
# Machine 1 (Developer in Paraguay)
git clone github.com/org/DevTeam-SSOT.git ~/Workstation/DevTeam-SSOT
cd ~/Workstation/DevTeam-SSOT
workstation seat create dev-py --role backend

# Machine 2 (Architect in Argentina)
git clone github.com/org/DevTeam-SSOT.git ~/Workstation/DevTeam-SSOT
cd ~/Workstation/DevTeam-SSOT
workstation seat create architect-ar --role system-design

# Machine 3 (DevOps in Cloud)
git clone github.com/org/DevTeam-SSOT.git ~/Workstation/DevTeam-SSOT
cd ~/Workstation/DevTeam-SSOT
workstation seat create devops-cloud --role infrastructure
```

### Coordination Workflow

```bash
# Architect makes decision, updates KB
echo "## Auth Pattern v2" >> KBs/KB-Architecture/auth.md
git add KBs/ && git commit -m "Add auth pattern v2"
git push origin main

# Developer pulls changes
git pull origin main
workstation kb update
# Now has latest auth pattern in imports/
```

## Advanced Features

### Sub-Agent Orchestration

Spawn specialized sub-agents for parallel work:

```javascript
// From main agent, spawn specialized workers
sessions_spawn({
  task: "Research OAuth2 best practices",
  agentId: "architect",
  label: "oauth-research",
  timeout: 1800
})

sessions_spawn({
  task: "Implement JWT middleware",
  agentId: "backend",
  label: "jwt-impl",
  timeout: 3600
})
```

### Change Proposals

Critical changes require review:

```bash
# Create proposal
workstation propose change \
  --title "Migrate users table to UUID" \
  --resource "db:production:users" \
  --impact critical \
  --reviewers "dba,architect,security"

# Check status
workstation proposals list --status pending

# Review (as another agent)
workstation proposal review 2026-03-07-001 --approve --as dba

# Execute when approved
workstation proposal execute 2026-03-07-001
```

### Automatic Backups

Configure cron for automatic sync:

```bash
# crontab -e

# Sync every hour
0 * * * * cd ~/Workstation/MyOrg-SSOT && workstation seat sync

# Update KBs every 4 hours
0 */4 * * * cd ~/Workstation/MyOrg-SSOT && workstation kb update

# Full backup daily
0 2 * * * cd ~/Workstation/MyOrg-SSOT && workstation backup
```

## Best Practices

### 1. Seat Hygiene

**Keep MEMORY.md curated:**
- Review weekly, archive old decisions
- Link to KBs instead of duplicating
- Use memory/ for transient logs only

### 2. KB Maintenance

**Organize knowledge hierarchically:**
```
KBs/
├── KB-Core/              # Org-wide standards
│   ├── coding-standards.md
│   └── security-policies.md
├── KB-Architecture/      # System design
│   ├── patterns/
│   └── decisions/
└── KB-Runbooks/          # Operations
    ├── deployment.md
    └── incident-response.md
```

### 3. Change Management

**Always use ORQ when editing shared files:**
```bash
# Before editing ANY shared file (KB, SSOT, Project)
workstation orq check KB/docs/api.md
workstation orq claim KB/docs/api.md --ttl 30m --reason "Updating docs"

# Edit, commit, push
git add KB/docs/api.md && git commit -m "docs: update API"
git push

# Always release when done
workstation orq release KB/docs/api.md
```

**Use proposals for major changes:**
- Database schema changes
- API breaking changes
- Infrastructure modifications
- Security policy updates

### 4. Multi-Agent Etiquette

**Before starting work:**
1. Run `workstation orq status` to see what others are doing
2. Run `workstation orq clean` to remove stale claims
3. Check if your target files are available

**While working:**
- Keep claims small (one concept per claim)
- Use reasonable TTLs (15-60 minutes)
- Write clear reasons so other agents understand

**When done:**
- Always release your claims
- Sync your seat: `workstation seat sync`
- Update MEMORY.md with key decisions

### 4. Security

**Never commit:**
- API keys or secrets (use .env)
- Personal access tokens
- Production credentials

**Always use:**
- `.gitignore` for sensitive files
- Environment variables for secrets
- Lock files for critical resources

## Commands Reference

### Organization
```bash
workstation init <name>                    # Create organization
workstation status                         # Show current state
workstation doctor                         # Check installation
```

### Seats
```bash
workstation seat create <id> [opts]        # Create seat
workstation seat activate <id>             # Switch to seat
workstation seat list                      # List seats
workstation seat sync [id]                 # Backup & sync
workstation seat remove <id>               # Remove seat
```

### Knowledge Bases
```bash
workstation kb add <name> <repo>           # Add KB
workstation kb update [name]               # Update KBs
workstation kb list                        # List KBs
workstation kb remove <name>               # Remove KB
```

### Change Management
```bash
workstation propose change [opts]          # Create proposal
workstation proposals list [filters]       # List proposals
workstation proposal review <id> [action]  # Review proposal
workstation proposal execute <id>          # Execute proposal
```

### Multi-Agent Coordination (ORQ)
```bash
workstation orq claim <file> [opts]        # Claim file for editing
  --ttl 30m        # Time limit (15m, 30m, 1h, 2h)
  --reason "..."   # Why you're editing
  --concept "..."  # Concept being edited

workstation orq release <file> [--id <id>] # Release claim
workstation orq check <file>               # Check if file is available
workstation orq status                     # Show all active claims
workstation orq sync                       # Sync claims from other seats
workstation orq clean                      # Remove expired claims
```

### Maintenance
```bash
workstation backup                         # Full backup
workstation restore <seat> [snapshot]      # Restore seat
workstation migrate <from> <to>            # Migrate seat
```

## Integration with OpenClaw

### Workspace Files

Each seat workspace contains:

| File | Purpose | Ingested? |
|------|---------|-----------|
| `AGENT.md` | Operational manual, protocols | ✅ Always |
| `SOUL.md` | Personality, values, tone | ✅ Always |
| `IDENTITY.md` | Identity per channel | ✅ Once |
| `MEMORY.md` | Curated long-term memory | ✅ Always |
| `TOOLS.md` | Tools, credentials, access | ✅ On demand |
| `HEARTBEAT.md` | Proactive tasks | ✅ If present |
| `BOOTSTRAP.md` | First-run setup | ✅ Once, then delete |

### Session Keys

```
agent:developer:main                    # Main session
agent:developer:subagent:uuid           # Sub-agent session
agent:developer:cron:task-name          # Cron session
```

### Routing

```json
{
  "bindings": [
    {
      "agentId": "developer",
      "match": {
        "channel": "discord",
        "accountId": "dev-bot",
        "peer": { "kind": "direct", "id": "@user123" }
      }
    }
  ]
}
```

## Troubleshooting

### "Seat not found"
```bash
# Check if seat exists in config
jq '.seats[].id' workstation.json

# If missing, recreate
workstation seat create <id>
```

### "Workspace already active"
```bash
# Another process has the workspace open
lsof ~/.openclaw/workspace-<seat>

# Or force sync
workstation seat sync <seat> --force
```

### "ORQ/Claim conflict"
```bash
# Check who has claimed the file
workstation orq status

# If stale (expired), clean it
workstation orq clean

# If you need to override (emergency only)
workstation orq release <file> --force
```

### "KB sync failed"
```bash
# Check KB status
cd KBs/KB-Name && git status

# If conflicts, resolve manually
git pull origin main
# Fix conflicts
git push origin main
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenClaw Gateway                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Agent Runtime                          │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐           │   │
│  │  │  Agent   │ │  Agent   │ │  Agent   │           │   │
│  │  │ (Seat 1) │ │ (Seat 2) │ │ (Seat 3) │           │   │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘           │   │
│  │       │            │            │                  │   │
│  │  ┌────▼────────────▼────────────▼────┐             │   │
│  │  │        Workstation SSOT          │             │   │
│  │  │  ┌─────┐ ┌─────┐ ┌─────┐         │             │   │
│  │  │  │ KBs │ │Prop-│ │Proj-│         │             │   │
│  │  │  │     │ │osals│ │ects │         │             │   │
│  │  │  └──┬──┘ └──┬──┘ └──┬──┘         │             │   │
│  │  │     └───────┴───────┘            │             │   │
│  │  │            │                      │             │   │
│  │  │  ┌─────────▼──────────┐           │             │   │
│  │  │  │   Sync Engine      │           │             │   │
│  │  │  │  (git + locks)     │           │             │   │
│  │  │  └────────────────────┘           │             │   │
│  │  └───────────────────────────────────┘             │   │
│  └────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
         │           │           │
    Discord     Telegram    WhatsApp
```

## Links

- **Repository**: https://github.com/reflecterlabs/workstation-cli
- **Documentation**: https://github.com/reflecterlabs/workstation-cli/blob/main/docs/
- **Issues**: https://github.com/reflecterlabs/workstation-cli/issues
- **OpenClaw**: https://docs.openclaw.ai

## License

MIT License - Reflecter Labs

---

**Built for AI-native organizations** 🤖⚡
