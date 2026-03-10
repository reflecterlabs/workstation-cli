# TICK.md - Task Coordination

> Living task state for Workstation Seat  
> Place in `~/.openclaw/workspace-{seat_id}/TICK.md`

---

## Current Status

**Seat**: `{SEAT_ID}`  
**Last Updated**: `{DATE}`  
**Active Claims**: See `workstation claims`  

---

## Active Tasks

### TASK-001: [Task Title]

**Status**: 🟡 In Progress  
**Priority**: High  
**Claim**: `src/file.py` (expires: 2026-03-10T11:00:00Z)  
**Dependencies**: None  
**Blocked by**: None

#### Description
Brief description of what needs to be done.

#### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

#### Notes
- Context, decisions, learnings

---

## Backlog

### TASK-002: [Future Task]

**Status**: ⚪ Not Started  
**Priority**: Medium  
**Dependencies**: TASK-001

#### Description
What needs to be done.

---

## Completed

### TASK-000: [Completed Task]

**Status**: ✅ Done  
**Completed**: 2026-03-09  
**Summary**: Brief summary of what was accomplished.

---

## Coordination Log

### 2026-03-10

**10:00** - Claimed `src/auth.py` for refactoring  
**10:15** - Synced with KB-Standards updates  
**10:30** - Released claim, all tests passing

---

## Workstation Integration

### Commands to Use

```bash
# View active claims (external state)
workstation claims

# Create claim for new task
workstation claim src/feature.py --ttl 60m --reason "Implement X"

# Release when done
workstation release src/feature.py

# Sync state
workstation seat sync
```

### Why TICK.md + Workstation?

| Feature | TICK.md | Workstation CLI |
|---------|---------|-----------------|
| **State** | Human-readable, narrative | Machine-readable, atomic |
| **Claims** | Documented here | Enforced by `workstation.json` |
| **History** | Context and decisions | Git commits, timestamps |
| **Purpose** | Planning and reflection | Execution and coordination |

**Best Practice**: Update TICK.md *after* using workstation commands. TICK.md is your narrative; workstation is your source of truth.

---

## Task Lifecycle

```
Backlog → Proposed → Claimed → In Progress → Review → Done

1. **Backlog**: Idea exists, not prioritized
2. **Proposed**: Submitted for approval
3. **Claimed**: `workstation claim` executed, exclusive lock held
4. **In Progress**: Active work happening
5. **Review**: PR created, awaiting review
6. **Done**: Merged, claim released
```

---

## Dependency Management

### Visual Map

```
TASK-001 (auth refactor)
    └── TASK-002 (API endpoints) [blocked by TASK-001]
            └── TASK-003 (frontend integration) [blocked by TASK-002]
```

### Coordination

When you complete a task:
1. Notify dependent agents (via human channel or comments)
2. Update their TICK.md if you have access
3. Help unblock if needed (BYOA principle: prioritize unblocking others)

---

## Rituals

### Daily Standup (Self)

At session start, update this section:

```markdown
## Today

### Goals
- [ ] Complete TASK-001
- [ ] Start TASK-002 if unblocked

### Blockers
- None / Waiting for [agent] on [task]

### Notes
- [Any context from yesterday]
```

### End-of-Day Sync

Before ending session:

```bash
# 1. Update this file with progress
# 2. Sync workstation
workstation seat sync
# 3. Update MEMORY.md with learnings
# 4. Clear completed tasks from Active section
```

---

## Emergency Procedures

### Stale Claims

If another agent has a claim that seems abandoned:

1. Check expiration: `workstation claims`
2. If expired, you can claim (system will allow)
3. If not expired but blocking, escalate to human

### Conflicting Tasks

If two agents have tasks that conflict:

1. Do NOT work without coordination
2. Comment on both TICK.md files
3. Escalate to human for prioritization
4. Consider splitting work or pair-programming

---

## Template

### Creating New Task

```markdown
### TASK-XXX: [Title]

**Status**: ⚪ Not Started  
**Priority**: [High/Medium/Low]  
**Claim**: [file or None]  
**Dependencies**: [TASK-XXX or None]  
**Blocked by**: [TASK-XXX or None]

#### Description
[What needs to be done]

#### Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

#### Notes
- [Context]
```

---

## References

- [Purple Horizons tick-md](https://github.com/purple-horizons/tick-md) - Inspiration
- [BYOA.md](BYOA.md) - Coordination protocol
- [AGENT.md](AGENT.md) - Operational rules

---

*Keep this file updated. It's your living task state. 🤖⚡*
