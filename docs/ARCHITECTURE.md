# Architecture

## Overview

Workstation CLI is a bash-based tool that provides organization management for OpenClaw agents. It follows a **git-native** approach where all state is stored in version-controlled repositories.

---

## Core Concepts

### SSOT (Single Source of Truth)

Each organization has an SSOT directory:

```
MyOrg-SSOT/
├── workstation.json      # Central configuration
├── KBs/                  # Knowledge Bases (git repos)
├── _seats/              # Seat backups
├── Projects/            # Cross-seat projects
└── templates/           # Templates for new seats
```

This directory is a git repository that tracks:
- Organization structure
- Seat configurations
- KB references
- Project definitions

### Seat

A **seat** represents an agent workspace:

```
~/.openclaw/workspace-developer/     # Runtime workspace
├── AGENT.md                         # Operational manual
├── SOUL.md                          # Personality
├── MEMORY.md                        # Long-term memory
├── TOOLS.md                         # Tool access
└── imports/                         # KB symlinks
```

Key characteristics:
- Each seat maps to an OpenClaw workspace
- Seats are activated by symlinking `~/.openclaw/workspace`
- State is backed up to SSOT on sync

### Knowledge Base

KBs are git repositories that contain:
- Organizational standards
- Technical documentation
- Best practices
- Domain knowledge

KBs are:
- Cloned into `SSOT/KBs/`
- Symlinked into seat workspaces
- Updated via `git pull`

---

## Data Flow

```
┌─────────────────────────────────────────────────────────┐
│                    USER COMMANDS                        │
│  workstation seat create developer                      │
│  workstation seat activate developer                    │
│  workstation seat sync                                  │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│              WORKSTATION CLI (bin/workstation)         │
│                                                         │
│  1. Parse command                                       │
│  2. Find SSOT (walk up directory tree)                  │
│  3. Read workstation.json                               │
│  4. Execute logic                                       │
│  5. Update JSON state                                   │
│  6. Git commit changes                                  │
└─────────────────────────┬───────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          │               │               │
          ▼               ▼               ▼
┌─────────────────┐ ┌──────────┐ ┌─────────────────┐
│   SSOT Repo     │ │  KBs     │ │ OpenClaw        │
│                 │ │          │ │                 │
│ workstation.json│ │ KB-Core/ │ │ workspace-dev/  │
│ _seats/         │ │ KB-Tech/ │ │ workspace-ops/  │
└─────────────────┘ └──────────┘ └─────────────────┘
```

---

## State Management

### Configuration (`workstation.json`)

Single JSON file contains all organization state:

```json
{
  "organization": { ... },
  "seats": [ ... ],
  "kbs": [ ... ],
  "projects": [ ... ],
  "sync": { ... }
}
```

Access pattern:
- Read: `jq '.seats[] | select(.id == "dev")' workstation.json`
- Write: `jq '.seats += [new_seat]' workstation.json > tmp && mv tmp workstation.json`

### Workspace Activation

Seats are activated via symlinks:

```bash
# Before activation
~/.openclaw/workspace -> (broken or pointing elsewhere)

# After: workstation seat activate developer
~/.openclaw/workspace -> /home/user/.openclaw/workspace-developer
```

### Backup Strategy

Three levels of backup:

1. **Snapshots** (`_seats/<id>/snapshots/`)
   - Per-sync file copies
   - 30 retained
   - Fast recovery

2. **Archives** (`_seats/<id>/archives/`)
   - Compressed tarballs
   - 30 days retained
   - Space efficient

3. **Git** (SSOT repository)
   - All configuration changes
   - History of workstation.json
   - Remote backup ready

---

## Module Structure

```
workstation-cli/
├── bin/
│   └── workstation          # Main executable
│
├── templates/
│   └── seat/               # Seat templates
│       ├── BOOTSTRAP.md
│       ├── AGENT.md
│       ├── SOUL.md
│       ├── MEMORY.md
│       ├── TOOLS.md
│       ├── HEARTBEAT.md
│       └── IDENTITY.md
│
├── docs/                   # Documentation
│   ├── INSTALL.md
│   ├── ARCHITECTURE.md
│   └── API.md
│
└── tests/                  # Test suite
    └── run-tests.sh
```

---

## Command Flow Examples

### `workstation init MyOrg`

```
1. Validate name
2. Create directory structure
3. Generate workstation.json
4. Copy templates
5. Initialize git repo
6. Initial commit
```

### `workstation seat create dev --role backend`

```
1. Validate ID format
2. Find SSOT
3. Create workspace directory
4. Copy and template files
5. Create backup directory
6. Update workstation.json
7. Git commit
```

### `workstation seat sync dev`

```
1. Find SSOT
2. Create snapshot
3. Copy critical files to snapshot
4. Update KB symlinks
5. Update last_sync timestamp
6. Git commit changes
```

---

## Security Considerations

### Secrets

- Never commit `.env` files
- API keys stored in environment variables
- Tokens in `~/.openclaw/.env`, not in SSOT

### Access Control

- SSOT is a git repo: use GitHub/GitLab permissions
- Seats can be private repos
- KBs are read-only for seats

### Isolation

- Each seat has isolated workspace
- No cross-seat file access (except via KBs)
- Symlinks prevent accidental KB modifications

---

## Extensibility

### Adding New Commands

1. Add function in `bin/workstation`:
```bash
cmd_newcommand() {
  # Implementation
}
```

2. Add to main case statement:
```bash
"newcommand") cmd_newcommand "$@" ;;
```

### Custom Templates

Place templates in `SSOT/templates/seat/`:
- Use `{PLACEHOLDER}` syntax
- Available placeholders:
  - `{SEAT_ID}`
  - `{ORG_NAME}`
  - `{ROLE}`
  - `{DATE}`

---

## Performance

### Optimizations

- Lazy loading: Only read JSON when needed
- Git operations batched
- Symlinks instead of copies for KBs
- Compressed archives for old backups

### Bottlenecks

- Large `workstation.json` files
- Many seats (>100)
- Large KB repositories
- Slow git remotes

---

## Future Architecture

Potential improvements:

1. **SQLite Backend**: For large organizations
2. **REST API**: For remote management
3. **Plugin System**: For custom commands
4. **Web UI**: For visual management
