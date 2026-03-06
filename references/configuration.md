# Workstation Configuration Reference

## workstation.json Schema

```json
{
  "version": "2.0.0",
  "schema": "workstation-v2",
  
  "organization": {
    "name": "string",
    "description": "string",
    "timezone": "string",
    "openclaw_config_path": "string",
    "backup": {
      "enabled": "boolean",
      "interval": "string",
      "auto_commit": "boolean",
      "retention_days": "number"
    }
  },
  
  "seats": [
    {
      "id": "string",
      "name": "string",
      "openclaw_agent_id": "string",
      "role": "string",
      "workspace_path": "string",
      "backup_path": "string",
      "model": "string",
      "kbs": ["string"],
      "discord": {
        "enabled": "boolean",
        "webhook_env": "string"
      },
      "created_at": "string",
      "last_sync": "string",
      "status": "string"
    }
  ],
  
  "kbs": [
    {
      "name": "string",
      "repo": "string",
      "local_path": "string",
      "description": "string",
      "auto_update": "boolean",
      "update_interval": "string"
    }
  ],
  
  "projects": [
    {
      "id": "string",
      "name": "string",
      "path": "string",
      "description": "string",
      "seats_involved": ["string"],
      "status": "string",
      "milestones": []
    }
  ],
  
  "sync": {
    "auto_backup": {
      "enabled": "boolean",
      "interval": "string",
      "on_change": "boolean"
    },
    "kb_update": {
      "enabled": "boolean",
      "interval": "string"
    },
    "memory": {
      "backup_on_change": "boolean",
      "compress_after_days": "number"
    }
  }
}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WORKSTATION_ROOT` | `~/Workstation` | Root directory for organizations |
| `OPENCLAW_HOME` | `~/.openclaw` | OpenClaw installation directory |
| `WORKSTATION_DEBUG` | `0` | Enable debug output (set to `1`) |

## Git Configuration

Required for commits:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

Or per-organization:

```bash
cd ~/Workstation/MyOrg-SSOT
git config user.name "Agent Name"
git config user.email "agent@org.com"
```

## Discord Webhooks

For notifications, set in environment:

```bash
export DISCORD_SEATNAME_WEBHOOK="https://discord.com/api/webhooks/..."
```

Reference in workstation.json:

```json
{
  "discord": {
    "enabled": true,
    "webhook_env": "DISCORD_SEATNAME_WEBHOOK",
    "notify_on": ["memory_update", "error"]
  }
}
```

## Backup Retention

### Snapshots
- Stored in `_seats/<seat>/snapshots/`
- Keep last 30 snapshots
- Used for quick recovery

### Archives
- Stored in `_seats/<seat>/archives/`
- Compressed tar.gz files
- Keep last 30 days
- Used for long-term backup

## Model Configuration

Per-seat model overrides:

```json
{
  "model": "openrouter/anthropic/claude-opus-4"
}
```

Supported providers:
- OpenRouter: `openrouter/anthropic/claude-*`
- OpenAI: `openrouter/openai/gpt-4o`
- Any OpenClaw-supported model

## Cron Schedule

Example crontab for auto-sync:

```bash
# Sync every hour
0 * * * * cd ~/Workstation/MyOrg-SSOT && /usr/local/bin/workstation seat sync

# Backup every 4 hours
0 */4 * * * cd ~/Workstation/MyOrg-SSOT && /usr/local/bin/workstation backup

# KB update daily at 6am
0 6 * * * cd ~/Workstation/MyOrg-SSOT && /usr/local/bin/workstation kb update
```

## File Locations

### SSOT Structure
```
MyOrg-SSOT/
├── workstation.json          # Config
├── .git/                     # Git repo
├── .gitignore               # Git ignore rules
├── KBs/                     # Knowledge bases
│   └── KB-Core/
├── _seats/                  # Seat backups
│   └── <seat>/
│       ├── snapshots/
│       └── archives/
├── Projects/                # Cross-seat projects
│   └── Project-Name/
└── templates/seat/          # Seat templates
    └── *.md
```

### Seat Workspace
```
~/.openclaw/workspace-<seat>/
├── AGENT.md
├── SOUL.md
├── MEMORY.md
├── TOOLS.md
├── HEARTBEAT.md
├── IDENTITY.md
├── BOOTSTRAP.md           # Deleted after use
├── .gitignore
├── imports/
│   └── <org>/
│       └── KB-*/          # Symlinks to KBs
└── memory/
    └── YYYY-MM-DD.md
```

## Security

### .gitignore Recommendations

```gitignore
# Workstation
.env
.env.local
*.log
.workstation/local/

# KBs (cloned, not committed)
KBs/*/
!KBs/KB-Core/

# Seat backups
_seats/*/snapshots/
_seats/*/archives/

# OS
.DS_Store
Thumbs.db
```

### Secret Management

Never commit secrets. Use environment variables:

```bash
# ~/.bashrc
export OPENROUTER_API_KEY="..."
export DISCORD_WEBHOOK_URL="..."
export GITHUB_TOKEN="..."
```

## Troubleshooting Config

### Reset Seat State

```bash
# Remove and recreate seat workspace
rm -rf ~/.openclaw/workspace-<seat>
workstation seat sync <seat>
```

### Fix Broken Symlinks

```bash
cd ~/Workstation/MyOrg-SSOT
workstation seat sync <seat>  # Recreates KB symlinks
```

### Recover from Corrupted Config

```bash
# Restore from git
cd ~/Workstation/MyOrg-SSOT
git checkout HEAD -- workstation.json
```
