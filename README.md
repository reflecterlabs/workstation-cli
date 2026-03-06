# Workstation CLI v2.0

**Organization Manager for OpenClaw Agents**

[![Version](https://img.shields.io/badge/version-2.0.0-blue)](https://github.com/agentzfactory/workstation)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Workstation is a command-line tool for managing AI agent organizations with OpenClaw. It provides structure for multi-agent setups, knowledge bases, and persistent memory across sessions.

---

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/agentzfactory/workstation.git

# Make it available globally
sudo ln -sf $(pwd)/workstation/bin/workstation /usr/local/bin/workstation

# Or add to your PATH
export PATH="$PATH:$(pwd)/workstation/bin"
```

### Prerequisites

- `jq` - JSON processor
- `git` - Version control
- OpenClaw (optional, for agent runtime)

```bash
# Ubuntu/Debian
sudo apt-get install jq git

# macOS
brew install jq git
```

---

## 📖 Usage

### 1. Initialize Organization

```bash
workstation init MyCompany
cd ~/Workstation/MyCompany-SSOT
```

### 2. Create Agent Seat

```bash
workstation seat create developer --role backend --model openrouter/anthropic/claude-sonnet-4-5
```

### 3. Activate Seat

```bash
workstation seat activate developer
openclaw gateway restart
```

### 4. Add Knowledge Base

```bash
workstation kb add KB-Core https://github.com/myorg/KB-Core.git
workstation seat sync
```

---

## 🏗️ Architecture

```
~/.openclaw/                          # OpenClaw runtime
├── workspace/                        # Symlink to active seat
├── workspace-developer/              # Individual seat workspace
├── workspace-analyst/                # Another seat
└── openclaw.json                     # OpenClaw config

~/Workstation/
└── MyCompany-SSOT/                   # Organization SSOT
    ├── workstation.json              # Central configuration
    ├── KBs/                          # Knowledge Bases
    │   ├── KB-Core/                  # Organizational knowledge
    │   └── KB-Engineering/           # Technical knowledge
    ├── _seats/                       # Seat backups
    │   ├── developer/
    │   └── analyst/
    ├── Projects/                     # Cross-seat projects
    └── templates/seat/               # Seat templates
```

---

## 📚 Commands

### General

| Command | Description |
|---------|-------------|
| `workstation version` | Show version info |
| `workstation doctor` | Check installation |
| `workstation status` | Show current status |
| `workstation help` | Show help |

### Organization

| Command | Description |
|---------|-------------|
| `workstation init <name>` | Create new organization |

### Seats

| Command | Description |
|---------|-------------|
| `workstation seat create <id> [--role <role>] [--model <model>]` | Create new seat |
| `workstation seat activate <id>` | Switch to seat |
| `workstation seat list` | List all seats |
| `workstation seat sync [id]` | Sync seat(s) |

### Knowledge Bases

| Command | Description |
|---------|-------------|
| `workstation kb add <name> <repo>` | Add KB from git repo |
| `workstation kb update` | Update all KBs |
| `workstation kb list` | List KBs |

### Maintenance

| Command | Description |
|---------|-------------|
| `workstation backup` | Full backup |

---

## 🎭 Seat Templates

When creating a seat, these files are copied to the workspace:

- `BOOTSTRAP.md` - First-time setup ritual (self-destructs after)
- `AGENT.md` - Operational manual
- `SOUL.md` - Personality and values
- `TOOLS.md` - Available tools and access
- `MEMORY.md` - Long-term memory
- `HEARTBEAT.md` - Proactive task checklist
- `IDENTITY.md` - Identity per channel

---

## 🔄 Synchronization

### Automatic (Cron)

```bash
# Edit crontab
crontab -e

# Sync every hour
0 * * * * /usr/local/bin/workstation seat sync

# Backup every 4 hours
0 */4 * * * /usr/local/bin/workstation backup
```

### Manual

```bash
# Sync specific seat
workstation seat sync developer

# Sync all seats
workstation seat sync

# Full backup
workstation backup
```

---

## 💾 Memory System

### Two-Level Memory

1. **MEMORY.md** - Curated long-term memory (injected every session)
   - Key learnings
   - Important decisions
   - Active projects
   - Key contacts

2. **memory/YYYY-MM-DD.md** - Daily logs (on-demand)
   - Daily activities
   - Conversations
   - Tasks completed

### Backup Strategy

- **Snapshots**: Per-sync backups (30 retained)
- **Archives**: Compressed tarballs (30 days retained)
- **Git**: All changes committed to SSOT

---

## 🔧 Configuration

### Environment Variables

```bash
# Root directory for organizations
export WORKSTATION_ROOT="$HOME/Workstation"

# OpenClaw home directory
export OPENCLAW_HOME="$HOME/.openclaw"

# Enable debug output
export WORKSTATION_DEBUG=1
```

### workstation.json

```json
{
  "version": "2.0.0",
  "organization": {
    "name": "MyCompany",
    "timezone": "UTC",
    "backup": {
      "enabled": true,
      "interval": "4h"
    }
  },
  "seats": [
    {
      "id": "developer",
      "role": "backend",
      "model": "openrouter/anthropic/claude-sonnet-4-5",
      "workspace_path": "~/.openclaw/workspace-developer",
      "kbs": ["KB-Core", "KB-Engineering"]
    }
  ],
  "kbs": [
    {
      "name": "KB-Core",
      "repo": "https://github.com/myorg/KB-Core",
      "auto_update": true
    }
  ]
}
```

---

## 🤝 Integration with OpenClaw

Workstation complements OpenClaw:

| Feature | OpenClaw | Workstation |
|---------|----------|-------------|
| Agent Runtime | ✅ | ❌ (uses OpenClaw) |
| Multi-Agent | ❌ | ✅ |
| Knowledge Bases | ❌ | ✅ |
| Memory Backup | ❌ | ✅ |
| Organization | ❌ | ✅ |

---

## 📝 Examples

### Example 1: Development Team

```bash
# Init
workstation init DevTeam

# Create seats for each developer
workstation seat create frontend-dev --role frontend
workstation seat create backend-dev --role backend
workstation seat create devops --role devops

# Shared KB
workstation kb add KB-Standards https://github.com/devteam/standards.git

# Each developer activates their seat
workstation seat activate frontend-dev
```

### Example 2: Research Organization

```bash
workstation init ResearchLab

workstation seat create researcher-1 --role data-science
workstation seat create researcher-2 --role bioinformatics

workstation kb add KB-Methods https://github.com/lab/methods.git
workstation kb add KB-Datasets https://github.com/lab/datasets.git
```

---

## 🛠️ Development

```bash
# Clone
git clone https://github.com/agentzfactory/workstation.git
cd workstation

# Run tests
./tests/run-tests.sh

# Lint
shellcheck bin/workstation
```

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -am 'Add feature'`
4. Push: `git push origin feature/my-feature`
5. Open Pull Request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

## 🔗 Links

- [Documentation](docs/)
- [OpenClaw](https://github.com/openclaw/openclaw)
- [Issues](https://github.com/agentzfactory/workstation/issues)

---

**Built for AI-native organizations** 🤖⚡
