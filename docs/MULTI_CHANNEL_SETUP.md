# Multi-Channel Agent Setup for OpenClaw

> Configure multiple agents on a single machine, each with their own communication channel

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SINGLE MACHINE                                │
│                    (Your PC/Server)                                  │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │   Agent PM   │  │ Agent Design │  │ Agent Dev    │              │
│  │              │  │              │  │              │              │
│  │  Telegram    │  │  WhatsApp    │  │   Discord    │              │
│  │  @pm_bot     │  │  @design_bot │  │  #dev-agent  │              │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘              │
│         │                  │                  │                      │
│         └──────────────────┼──────────────────┘                      │
│                            │                                         │
│                            ▼                                         │
│              ┌─────────────────────────┐                            │
│              │   WORKSTATION CLI       │                            │
│              │   (Shared SSOT)         │                            │
│              ├─────────────────────────┤                            │
│              │ ~/Workstation/Org-SSOT/ │                            │
│              │   workstation.json      │                            │
│              │   KBs/ (shared)         │                            │
│              │   _seats/ (backups)     │                            │
│              └─────────────────────────┘                            │
│                            │                                         │
│         ┌──────────────────┼──────────────────┐                      │
│         ▼                  ▼                  ▼                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │~/.openclaw/  │  │~/.openclaw/  │  │~/.openclaw/  │              │
│  │workspace-pm/ │  │workspace-    │  │workspace-dev/│              │
│  │              │  │ design/       │  │              │              │
│  │ • AGENT.md   │  │ • AGENT.md   │  │ • AGENT.md   │              │
│  │ • SOUL.md    │  │ • SOUL.md    │  │ • SOUL.md    │              │
│  │ • MEMORY.md  │  │ • MEMORY.md  │  │ • MEMORY.md  │              │
│  │ • TICK.md    │  │ • TICK.md    │  │ • TICK.md    │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   GIT (SSOT)     │
                    │   Coordination   │
                    └──────────────────┘
```

---

## Step-by-Step Setup

### 1. Initialize Organization

```bash
# Create organization
workstation init MiEmpresa
cd ~/Workstation/MiEmpresa-SSOT

# Create core KB
cat > KBs/KB-Core/COMMUNICATION.md << 'EOF'
# Communication Channels

## Agent: PM
- Channel: Telegram
- Bot: @miempresa_pm_bot
- Purpose: Roadmap, priorities, coordination

## Agent: Design
- Channel: WhatsApp
- Number: +XX XXX XXX XXXX
- Purpose: Visual design, brand, UX

## Agent: Developer
- Channel: Discord
- Channel: #dev-agent
- Purpose: Implementation, technical decisions
EOF

git add . && git commit -m "Add communication channels config"
```

### 2. Create Agent Seats

```bash
# Create seats for each role
workstation seat create pm --role "product-manager"
workstation seat create design --role "designer"
workstation seat create developer --role "developer"
```

### 3. Configure OpenClaw for Multi-Channel

Each agent needs its own OpenClaw configuration. Create separate config files:

```bash
mkdir -p ~/.openclaw/agents/{pm,design,developer}
```

#### Agent: PM (Telegram)

```bash
# File: ~/.openclaw/agents/pm/config.json
cat > ~/.openclaw/agents/pm/config.json << 'EOF'
{
  "agent_id": "pm",
  "seat": "pm",
  "channels": {
    "telegram": {
      "enabled": true,
      "bot_token": "${TELEGRAM_PM_BOT_TOKEN}",
      "allowed_chats": ["private", "group"]
    }
  },
  "workspace": "~/.openclaw/workspace-pm",
  "organization": "MiEmpresa"
}
EOF
```

#### Agent: Design (WhatsApp)

```bash
# File: ~/.openclaw/agents/design/config.json
cat > ~/.openclaw/agents/design/config.json << 'EOF'
{
  "agent_id": "design",
  "seat": "design",
  "channels": {
    "whatsapp": {
      "enabled": true,
      "session": "design_agent",
      "allowed_groups": ["design-team"]
    }
  },
  "workspace": "~/.openclaw/workspace-design",
  "organization": "MiEmpresa"
}
EOF
```

#### Agent: Developer (Discord)

```bash
# File: ~/.openclaw/agents/developer/config.json
cat > ~/.openclaw/agents/developer/config.json << 'EOF'
{
  "agent_id": "developer",
  "seat": "developer",
  "channels": {
    "discord": {
      "enabled": true,
      "token": "${DISCORD_DEV_BOT_TOKEN}",
      "guild_id": "YOUR_GUILD_ID",
      "channel": "dev-agent"
    }
  },
  "workspace": "~/.openclaw/workspace-developer",
  "organization": "MiEmpresa"
}
EOF
```

### 4. Create Agent-Specific AGENT.md

Each agent needs to know about other agents' channels:

#### For PM Agent

```markdown
# AGENT.md - PM

## Communication Channels

### My Channel
- **Platform**: Telegram
- **Bot**: @miempresa_pm_bot
- **Purpose**: Roadmap, priorities, coordination

### Other Agents' Channels

| Agent | Channel | How to Reach |
|-------|---------|--------------|
| Design | WhatsApp | Human relays or design claims |
| Developer | Discord | Mention in workstation claims |

## Cross-Channel Coordination

Since agents are on different channels, use:

1. **workstation claims** - File-level coordination
2. **TICK.md updates** - Async status updates
3. **Human relay** - When real-time needed
4. **_proposals/** - Formal proposals

### Example: Request Design Review

```bash
# PM creates proposal
cat > _proposals/DESIGN-001.md << 'EOF'
# Design Review Request

**From**: PM
**To**: Design
**Priority**: High

## Request
Need landing page design for new feature.
Deadline: 2026-03-20

## Context
See KB-Core/FEATURE-LAUNCH.md
EOF

# Commit and sync
git add . && git commit -m "Proposal: Design review for landing page"
workstation seat sync

# Notify human to relay to design channel
# (Or design agent checks TICK.md via their session)
```
```

### 5. Setup Scripts

Create a master setup script:

```bash
#!/bin/bash
# setup-multi-agent.sh

ORG_NAME="${1:-MiEmpresa}"
echo "Setting up multi-agent organization: $ORG_NAME"

# 1. Create organization
workstation init "$ORG_NAME"
cd ~/Workstation/${ORG_NAME}-SSOT

# 2. Create seats
workstation seat create pm --role "product-manager"
workstation seat create design --role "designer"
workstation seat create developer --role "developer"

# 3. Copy templates
cp -r templates/organizations/startup-team/pm/* ~/.openclaw/workspace-pm/
cp -r templates/organizations/startup-team/marketing/* ~/.openclaw/workspace-design/
cp -r templates/organizations/startup-team/developer/* ~/.openclaw/workspace-developer/

# 4. Create channel configs
mkdir -p ~/.openclaw/agents/{pm,design,developer}

# PM Telegram config
cat > ~/.openclaw/agents/pm/channel.conf << EOF
CHANNEL=telegram
BOT_TOKEN=\${TELEGRAM_PM_TOKEN}
WORKSPACE=pm
EOF

# Design WhatsApp config
cat > ~/.openclaw/agents/design/channel.conf << EOF
CHANNEL=whatsapp
SESSION=design_agent
WORKSPACE=design
EOF

# Developer Discord config
cat > ~/.openclaw/agents/developer/channel.conf << EOF
CHANNEL=discord
TOKEN=\${DISCORD_DEV_TOKEN}
WORKSPACE=developer
EOF

# 5. Create cross-reference document
cat > KBs/KB-Core/AGENT_CHANNELS.md << EOF
# Agent Communication Channels

| Agent | Channel | Contact | Purpose |
|-------|---------|---------|---------|
| PM | Telegram | @miempresa_pm_bot | Roadmap, priorities |
| Design | WhatsApp | +XX XXX XXX XXXX | Visual, brand, UX |
| Developer | Discord | #dev-agent | Implementation |

## Coordination Protocol

1. File claims via workstation
2. Update TICK.md for status
3. Human relay for urgent matters
4. Git commits for decisions
EOF

echo "✓ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure Telegram bot for PM"
echo "2. Configure WhatsApp for Design"
echo "3. Configure Discord for Developer"
echo "4. Test: workstation seat activate pm"
```

---

## Coordination Patterns

### Pattern 1: File Claims (Async)

```bash
# Developer claims a file
workstation seat activate developer
workstation claim src/feature.js --ttl 60m

# PM sees claim via git
cd ~/Workstation/MiEmpresa-SSOT
git pull
cat workstation.json | jq '.claims'

# Design waits or coordinates
```

### Pattern 2: TICK.md Updates

Each agent updates their TICK.md:

```markdown
# design/TICK.md

## Blocked By
- Waiting for: developer/api-design (see ../developer/TICK.md)
- Blocking: pm/landing-page
```

### Pattern 3: Human Relay

For urgent, real-time coordination:

```
Human: "@design, PM needs the mockup by tomorrow"
Design Agent: Acknowledges, updates TICK.md
```

### Pattern 4: Proposal System

Formal requests via `_proposals/`:

```bash
_proposals/
├── 2026-03-10-pm-to-design.md
├── 2026-03-10-dev-to-pm.md
└── STATUS.md
```

---

## Running the Agents

### Option 1: Single OpenClaw Instance with Routing

Configure OpenClaw to route messages to correct agent based on channel:

```json
{
  "agents": {
    "pm": {
      "workspace": "workspace-pm",
      "channels": ["telegram:pm_bot"]
    },
    "design": {
      "workspace": "workspace-design",
      "channels": ["whatsapp:design_session"]
    },
    "developer": {
      "workspace": "workspace-developer",
      "channels": ["discord:dev_channel"]
    }
  }
}
```

### Option 2: Multiple OpenClaw Instances

Run separate instances per agent:

```bash
# Terminal 1: PM Agent
export OPENCLAW_CONFIG=~/.openclaw/agents/pm
export WORKSTATION_ROOT=~/Workstation
export OPENCLAW_HOME=~/.openclaw
openclaw gateway start

# Terminal 2: Design Agent
export OPENCLAW_CONFIG=~/.openclaw/agents/design
openclaw gateway start

# Terminal 3: Developer Agent
export OPENCLAW_CONFIG=~/.openclaw/agents/developer
openclaw gateway start
```

### Option 3: Docker Containers

```yaml
# docker-compose.agents.yml
version: '3.8'
services:
  agent-pm:
    image: openclaw:latest
    environment:
      - AGENT_ID=pm
      - WORKSPACE=/workspace-pm
      - CHANNEL=telegram
    volumes:
      - ~/.openclaw/workspace-pm:/workspace-pm
      - ~/Workstation/MiEmpresa-SSOT:/ssot

  agent-design:
    image: openclaw:latest
    environment:
      - AGENT_ID=design
      - WORKSPACE=/workspace-design
      - CHANNEL=whatsapp
    volumes:
      - ~/.openclaw/workspace-design:/workspace-design
      - ~/Workstation/MiEmpresa-SSOT:/ssot

  agent-developer:
    image: openclaw:latest
    environment:
      - AGENT_ID=developer
      - WORKSPACE=/workspace-developer
      - CHANNEL=discord
    volumes:
      - ~/.openclaw/workspace-developer:/workspace-developer
      - ~/Workstation/MiEmpresa-SSOT:/ssot
```

---

## Best Practices

### 1. Clear Channel Ownership

Each agent should know:
- Which channel is theirs
- Which channels belong to other agents
- How to reach each agent (via workstation, not direct message)

### 2. Async-First Communication

```markdown
## Prefer async (TICK.md, Git) for:
- Status updates
- Task assignments
- Non-urgent questions

## Use human relay for:
- Urgent blockers
- Real-time decisions
- Complex negotiations
```

### 3. Regular Sync

```bash
# Each agent runs at session start:
workstation seat sync

# Reads:
# - workstation.json (claims, state)
# - Other agents' TICK.md
# - New proposals in _proposals/
```

### 4. Human in the Loop

Always have a human:
- For final decisions
- For conflict resolution
- For complex negotiations
- As emergency contact

---

## Troubleshooting

### Problem: Agents don't see each other's updates

**Solution**: Ensure all agents sync to same Git repo:
```bash
cd ~/Workstation/MiEmpresa-SSOT
git pull  # Before starting work
git push  # After syncing
```

### Problem: Channel routing not working

**Solution**: Check OpenClaw routing config:
```bash
openclaw config get agents.pm.channels
# Should show correct channel mapping
```

### Problem: File permission conflicts

**Solution**: Use workstation claims:
```bash
workstation claim file.txt --ttl 30m
# Prevents other agents from editing
```

---

## Example: Complete Workflow

```
1. Human messages PM on Telegram:
   "We need a new landing page for Feature X"

2. PM Agent:
   - Activates: workstation seat activate pm
   - Creates proposal: _proposals/LANDING-PAGE.md
   - Commits: git commit -m "Proposal: Landing page"
   - Syncs: workstation seat sync
   - Responds: "Created proposal. Coordinating with Design."

3. Design Agent (next session):
   - Syncs: workstation seat sync
   - Sees proposal in _proposals/
   - Claims design work: workstation claim design/
   - Updates TICK.md with timeline
   - Commits and syncs

4. Developer Agent (sees update):
   - Syncs and sees design claim
   - Waits for design completion
   - Can prepare API/backend in parallel

5. PM Agent (monitors):
   - Checks TICK.md files
   - Reports progress to human
```

---

## References

- [OpenClaw Multi-Agent Setup](https://docs.openclaw.ai/multi-agent)
- [Workstation CLI Coordination](../README.md)
- [BYOA Protocol](../BYOA.md)

---

*Multiple agents, multiple channels, one coordinated team.*
