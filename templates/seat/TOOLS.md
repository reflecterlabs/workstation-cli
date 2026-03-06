# {SEAT_ID}

**Organization**: {ORG_NAME}  
**Role**: {ROLE}

---

## Activation Checklist

- [x] Workspace initialized
- [ ] OpenClaw configured
- [ ] KBs synchronized
- [ ] Discord/Notifications configured

## Access & Credentials

### OpenClaw
- Agent ID: `{SEAT_ID}`
- Workspace: `~/.openclaw/workspace-{SEAT_ID}`
- Config: `~/.openclaw/openclaw.json`

### Environment Variables Needed
```bash
# Required
export OPENROUTER_API_KEY=""

# Optional (for notifications)
export DISCORD_{SEAT_ID}_WEBHOOK=""
export GITHUB_TOKEN=""
```

### SSH / Servers
- [Server name]: [access method]

### APIs
- [API name]: [endpoint or reference]

## Tools Available

| Tool | Purpose | Usage |
|------|---------|-------|
| `workstation` | Organization management | `workstation seat sync` |
| `openclaw` | Agent runtime | `openclaw status` |
| [Other CLI] | [Purpose] | `command` |

## Quick Commands

```bash
# Sync with SSOT
workstation seat sync {SEAT_ID}

# Check status
workstation seat status

# Activate this seat
workstation seat activate {SEAT_ID}

# Update KBs
workstation kb update
```

## Project Context

### Active Projects
- [Project 1]: [brief context]
- [Project 2]: [brief context]

### Regular Contacts
- [Role/Name]: [how to reach]

## Notes

[Any operational notes specific to this seat]

---

*Update this file as you discover new tools or access requirements.*
