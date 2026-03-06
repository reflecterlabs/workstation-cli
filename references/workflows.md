# Workstation Workflows

## Seat Creation Workflow

```
workstation seat create <id> [--role <role>] [--model <model>]
    │
    ▼
1. Validate ID format (lowercase, alphanumeric, hyphens)
2. Find SSOT directory
3. Create OpenClaw workspace
4. Copy and template seat files
5. Create backup directory structure
6. Update workstation.json
7. Git commit
```

## Daily Agent Workflow

```
Session Start
    │
    ▼
1. workstation seat sync
2. Read MEMORY.md
3. Check HEARTBEAT.md
4. Review recent memory/ logs
    │
    ▼
Working
    │
    ▼
1. Follow AGENT.md protocols
2. Update MEMORY.md with learnings
3. Document in memory/YYYY-MM-DD.md
    │
    ▼
Session End
    │
    ▼
1. workstation seat sync
2. Git commit changes
```

## Knowledge Base Update Workflow

```
workstation kb update
    │
    ▼
1. For each KB in KBs/:
   - git pull origin main
    │
    ▼
2. For each seat:
   - Update symlinks in imports/
    │
    ▼
3. Git commit changes
```

## Backup Workflow

```
workstation backup
    │
    ▼
1. For each seat:
   - Create tar.gz archive
   - Cleanup old archives (>30 days)
    │
    ▼
2. Git commit to SSOT
```

## Multi-Agent Handoff Workflow

When work needs to transfer between agents:

```
Agent A (Current)
    │
    ▼
1. Document state in MEMORY.md
2. Create handoff note:
   echo "Handoff: [task description]" >> MEMORY.md
3. workstation seat sync
    │
    ▼
Agent B (Next)
    │
    ▼
1. workstation seat activate agent-b
2. Read MEMORY.md
3. Continue work
```

## CI/CD Integration Workflow

```yaml
# .github/workflows/agents.yml
name: Agent Workflows

on:
  schedule:
    - cron: '0 */4 * * *'  # Every 4 hours

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Workstation
        run: |
          curl -fsSL https://raw.githubusercontent.com/reflecterlabs/workstation-cli/main/install.sh | bash
          git config --global user.name "CI"
          git config --global user.email "ci@example.com"
      
      - name: Sync agents
        run: |
          cd ~/Workstation/MyOrg-SSOT
          workstation seat sync
          workstation kb update
```

## Bootstrap Ritual

For new agent activation:

1. **Verify structure** - Confirm workspace files exist
2. **Configure IDENTITY.md** - Set name, emoji, tagline
3. **Personalize SOUL.md** - Define personality and values
4. **Review AGENT.md** - Understand protocols
5. **Verify KB access** - Check imports/
6. **Create MEMORY.md** - Initial entry
7. **Delete BOOTSTRAP.md** - Self-destruct
8. **Document completion** - Record in MEMORY.md

## Memory Management Workflow

### Weekly Maintenance

```bash
# Archive old daily logs
find memory/ -name "*.md" -mtime +30 -exec gzip {} \;

# Review and curate MEMORY.md
# - Remove outdated info
# - Consolidate related learnings
# - Update active projects

# Sync
workstation seat sync
```

### Monthly Review

1. Review all seat MEMORY.md files
2. Identify common patterns
3. Update KBs with shared knowledge
4. Archive completed projects

## Emergency Recovery

```bash
# Recover from backup
cd ~/Workstation/MyOrg-SSOT

# Restore seat from latest archive
tar -xzf _seats/<seat>/archives/backup-latest.tar.gz -C ~/.openclaw/workspace-<seat>/

# Or restore from snapshot
cp -r _seats/<seat>/snapshots/latest/* ~/.openclaw/workspace-<seat>/
```
