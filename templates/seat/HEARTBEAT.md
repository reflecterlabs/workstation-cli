# HEARTBEAT.md - Cyclic Behavior Loop

> Observe → Orient → Decide → Act → Reflect  
> Place in `~/.openclaw/workspace-{seat_id}/HEARTBEAT.md`

---

## Concept

The **Heartbeat Loop** is a continuous cycle that keeps your agent aligned and proactive. Unlike reactive systems that wait for input, heartbeat-driven agents actively observe, decide, and act.

```
    ┌───────────┐
    │  Observe  │◄──────────────────┐
    │ (Sensors) │                   │
    └─────┬─────┘                   │
          ▼                         │
    ┌───────────┐                   │
    │  Orient   │                   │
    │ (Context) │                   │
    └─────┬─────┘                   │
          ▼                         │
    ┌───────────┐                   │
    │  Decide   │                   │
    │ (Prioritize)│                 │
    └─────┬─────┘                   │
          ▼                         │
    ┌───────────┐                   │
    │   Act     │                   │
    │ (Execute) │                   │
    └─────┬─────┘                   │
          ▼                         │
    ┌───────────┐                   │
    │  Reflect  │───────────────────┘
    │  (Learn)  │
    └───────────┘
```

---

## Session Start Ritual (Every Activation)

### Phase 1: Observe

**What to check:**

```bash
# 1. Environment
workstation status
echo "Seat: {SEAT_ID}"
echo "Workspace: $(readlink ~/.openclaw/workspace 2>/dev/null || echo 'None active')"

# 2. Claims (coordination state)
workstation claims

# 3. KB Updates
ls -la imports/{ORG_NAME}/

# 4. Git Status
cd ~/Workstation/{ORG_NAME}-SSOT && git status -s

# 5. Memory
cat MEMORY.md | head -50
cat memory/$(date +%Y-%m-%d).md 2>/dev/null | tail -30
```

### Phase 2: Orient

**Questions to answer:**

1. What's my current context?
   - Seat: {SEAT_ID}
   - Role: {ROLE}
   - Active claims: [from workstation claims]

2. What's the organizational state?
   - Active seats: [from workstation seat list]
   - Active claims: [from workstation claims]
   - KB updates: [check git log in KBs/]

3. What's my task state?
   - Check TICK.md Active Tasks
   - Review HEARTBEAT.md Scheduled Tasks

### Phase 3: Decide

**Decision matrix:**

| Priority | Condition | Action |
|----------|-----------|--------|
| P0 | Active claim expiring soon | Finish work, release claim |
| P1 | Unblocking others | Help dependent agents first |
| P2 | Scheduled task due | Execute scheduled task |
| P3 | New work | Start next task from backlog |
| P4 | Maintenance | Sync, backup, organize |

### Phase 4: Act

Execute decided action with full context.

### Phase 5: Reflect

Update documentation:
```bash
# Add to today's log
echo "$(date '+%H:%M'): [Action taken] - [Result]" >> memory/$(date +%Y-%m-%d).md

# Update TICK.md if task completed
# Update MEMORY.md if significant learning
```

---

## Scheduled Tasks

### Daily

| Time | Task | Command/Action |
|------|------|----------------|
| Startup | Full sync | `workstation seat sync` |
| Startup | Check claims | `workstation claims` |
| Startup | Read TICK.md | Review active tasks |
| Every 30m | Health check | Verify claims not expired |
| End | Full sync | `workstation seat sync` |
| End | Update MEMORY.md | Log significant events |

### Weekly

| Day | Task |
|-----|------|
| Monday | Review backlog, plan week |
| Wednesday | Mid-week sync, check dependencies |
| Friday | Review completed tasks, update KBs |
| Sunday | Archive old logs, backup |

### On-Demand

| Trigger | Task |
|---------|------|
| Human mentions me | Respond immediately |
| Claim expires in <10m | Extend or finish |
| Git conflict detected | Pause, escalate |
| New KB available | Review and integrate |

---

## Proactive Checks

### Health Check Routine

```bash
# Run every 30 minutes
heartbeat_check() {
    # Check if seat is still active
    if ! workstation seat list | grep -q "{SEAT_ID}.*active"; then
        echo "Seat not active. Consider activating."
    fi
    
    # Check expiring claims
    local now=$(date +%s)
    # (Logic to check claim expirations)
    
    # Check if sync is needed
    if [[ -n $(git status -s 2>/dev/null) ]]; then
        echo "Uncommitted changes. Consider syncing."
    fi
}
```

### Coordination Check

```bash
# Run when idle
coordination_check() {
    # Check if other agents need help
    workstation claims  # See who's working on what
    
    # Check for proposed collaborations
    ls ~/Workstation/{ORG_NAME}-SSOT/_proposals/ 2>/dev/null || echo "No proposals"
}
```

---

## Integration with TICK.md

### From TICK.md → HEARTBEAT.md

**TICK.md** = "What to do" (tasks, priorities)  
**HEARTBEAT.md** = "When to do it" (schedules, rhythms)

Example:

```markdown
# TICK.md
### TASK-001: Refactor auth
Status: Active
Priority: High

# HEARTBEAT.md
## Scheduled
- **Next 30m**: Focus on TASK-001 (claim expires soon)
```

---

## Emergency Heartbeat

If something goes wrong:

```markdown
## ⚠️ Emergency State

**Detected**: [Timestamp]  
**Issue**: [What went wrong]  
**Action**: [Immediate response]  
**Escalate**: Yes/No
```

Trigger conditions:
- Seat becomes inactive unexpectedly
- Claim expires while working
- Git sync fails repeatedly
- Unknown system state

---

## Customization

Add your own rhythms:

```markdown
## My Custom Checks

### After Every Code Change
- [ ] Run tests
- [ ] Update TICK.md progress
- [ ] Check if claim needs extension

### Before Breaks
- [ ] Sync workstation
- [ ] Release claims if taking long break
- [ ] Note state in MEMORY.md
```

---

## Template: Daily Log Entry

```markdown
## 2026-03-10

### 09:00 - Startup
- [x] Synced workstation
- [x] Checked claims: none blocking
- [x] Reviewed TICK.md: TASK-001 active

### 09:30 - Work
- [x] Claimed src/auth.py (expires 10:30)
- [ ] Implementing OAuth2 flow

### 10:00 - Heartbeat
- Claim still active, 30m remaining
- No urgent coordination needed
- Continue with TASK-001
```

---

## References

- [TICK.md](TICK.md) - Task state and priorities
- [AGENT.md](AGENT.md) - Operational rules
- [MEMORY.md](MEMORY.md) - Long-term learnings

---

*The heartbeat keeps you alive and aligned. Don't skip it. 🤖💓*
