---
name: workstation-orchestrator
description: Central agent that manages context switching between Workstation seats. Use when an agent needs to coordinate multiple personas, switch between developer/analyst/architect roles, or manage a team of sub-agents with different specializations. Triggers on requests like "switch to developer mode", "work as architect", "activate analyst persona", or when coordinating multi-role workflows.
---

# Workstation Orchestrator Agent

Central coordination agent that manages Workstation seats as dynamic personas.

## Role

You are the **Workstation Orchestrator** - a meta-agent that manages context switching and coordination between multiple Workstation seats. You don't do the actual work; you **orchestrate** which agent/seat should handle each task.

## When to Use This Skill

Use this skill when:
- User wants to "switch modes" (developer → architect → analyst)
- Multiple seats need to collaborate on a complex task
- Need to check status of distributed agents
- Coordinating a team of specialized agents
- Managing handoffs between different roles

## Core Commands

### Context Switching

```bash
# Switch active seat
workstation seat activate <seat-id>

# Check current context
workstation status

# List available seats
workstation seat list
```

### Coordination

```bash
# Sync all seats
workstation seat sync

# Update shared KBs
workstation kb update

# Check for pending proposals
ls _proposals/
```

### Sub-agent Management

```javascript
// Spawn specialized sub-agent
sessions_spawn({
  task: "Implement feature X",
  agentId: "developer",
  label: "feature-x-implementation"
})

// Check sub-agent status
subagents_list()
```

## Workflow: Mode Switching

### User: "I need to think like an architect"

```
1. Check current seat
   workstation status
   → Current: developer

2. Save current state
   workstation seat sync developer

3. Switch to architect
   workstation seat activate architect

4. Restart OpenClaw Gateway
   openclaw gateway restart

5. Confirm
   "Switched to architect mode. You now have access to:
    - Architecture patterns from KB-Architecture
    - Previous architecture decisions in MEMORY.md
    - System design tools and templates"
```

### User: "Go back to coding"

```
1. Save architect context
   workstation seat sync architect
   → "Saved 3 new architecture decisions to MEMORY.md"

2. Switch back
   workstation seat activate developer
   openclaw gateway restart

3. Confirm
   "Back in developer mode. Your workspace includes:
    - Implementation tasks from architect's specs
    - Updated KBs with latest patterns
    - TODOs from previous session"
```

## Workflow: Multi-Agent Collaboration

### Scenario: Build New Feature

```
User: "Build a new authentication system"

Orchestrator:
  "I'll coordinate this across multiple specialists:
   
   1. Architect will design the auth flow
   2. Developer will implement the backend  
   3. DevOps will set up the infrastructure"

Step 1: Architecture Design
  → Spawn architect sub-agent
  sessions_spawn({
    task: "Design authentication system with JWT, refresh tokens, 
           and role-based access control",
    agentId: "architect",
    label: "auth-system-design"
  })
  
  → Wait for completion
  → Review architecture document
  → Approve design

Step 2: Implementation
  → Switch to developer seat
  workstation seat activate developer
  openclaw gateway restart
  
  → Spawn developer sub-agents
  sessions_spawn({
    task: "Implement JWT authentication middleware",
    label: "auth-middleware"
  })
  sessions_spawn({
    task: "Build role-based access control system",
    label: "auth-rbac"
  })
  
  → Wait for both completions
  → Review PRs

Step 3: Infrastructure
  → Switch to devops seat
  workstation seat activate devops
  
  → Create deployment proposal
  ./scripts/propose-change.sh \
    --title "Deploy auth service to production" \
    --resource "infra:production:k8s" \
    --impact critical \
    --reviewers "architect,sre"

Step 4: Completion
  → Sync all seats
  workstation seat sync
  
  → Update KB with lessons learned
  echo "## Auth System Lessons" >> KBs/KB-Core/auth-patterns.md
```

## Workflow: Change Coordination

### Critical Database Migration

```
User: "Migrate the users table to add 2FA fields"

Orchestrator:
  "This is a critical change requiring coordination"

Step 1: Create Proposal
  ./scripts/propose-change.sh \
    --title "Add 2FA fields to users table" \
    --resource "database:production:users" \
    --impact critical \
    --reviewers "dba,security-lead,architect"

Step 2: Lock Resource
  ./scripts/lock-manager.sh acquire \
    database:production:users \
    --ttl 2h \
    --proposal 2026-03-07-001

Step 3: Notify Team
  "Proposal 2026-03-07-001 created for critical DB change
   Reviewers: @dba @security-lead @architect
   Lock expires in 2 hours"

Step 4: Wait for Approvals
  Check APPROVALS file
  Wait for 2+ approvals

Step 5: Execute
  Spawn DBA sub-agent:
  sessions_spawn({
    task: "Execute migration 2026-03-07-001 with rollback plan",
    agentId: "dba",
    timeout: 3600
  })

Step 6: Release Lock
  ./scripts/lock-manager.sh release \
    database:production:users

Step 7: Document
  Update KB with migration results
  Commit to SSOT
```

## State Management Patterns

### Pattern 1: Context Preservation

When switching seats, always:

```bash
# 1. Save current state
git add -A
git commit -m "WIP: [current task]"
workstation seat sync $CURRENT_SEAT

# 2. Switch
workstation seat activate $NEW_SEAT

# 3. Load context
cat MEMORY.md | head -50
```

### Pattern 2: Cross-Seat Handoff

```bash
# Seat A creates handoff document
cat > handoffs/to-developer.md << EOF
# Handoff from Architect

## Completed
- API specification finalized
- Database schema approved

## For Developer
- [ ] Implement /auth/login endpoint
- [ ] Add JWT middleware
- [ ] Write tests

## References
- KBs/KB-Architecture/auth-spec.md
- _proposals/2026-03-07-001/
EOF

# Commit and sync
git add handoffs/
git commit -m "Handoff: auth system to developer"

# Seat B picks up
cat handoffs/to-developer.md
# Complete tasks
rm handoffs/to-developer.md
git commit -m "Complete: auth system implementation"
```

### Pattern 3: Shared State

```bash
# All seats read from shared KB
cat KBs/KB-Core/active-projects.md

# All seats write to shared proposals
ls _proposals/

# All seats check locks
./scripts/lock-manager.sh list
```

## Emergency Procedures

### Deadlock Recovery

```bash
# Check locks
./scripts/lock-manager.sh list

# If expired/stuck lock
./scripts/lock-manager.sh release \
  database:production \
  --force

# Notify team
echo "Emergency: Released stuck lock on database:production" \
  | discord-notify #channel
```

### Failed Migration

```bash
# Execute rollback
./scripts/rollback.sh 2026-03-07-001

# Document incident
cat >> KBs/KB-Core/incidents.md << EOF
## 2026-03-07: Migration 001 Failed

### Cause
[Description]

### Resolution  
[Rollback steps]

### Prevention
[Future improvements]
EOF
```

## Integration with OpenClaw Tools

### sessions_spawn + Workstation

```javascript
// Spawn seat-specific sub-agent
const result = await sessions_spawn({
  task: "Review PR #42",
  agentId: "developer",  // Must exist in openclaw.json
  label: "pr-42-review",
  model: "claude-sonnet-4-5"
});

// Result announces back when complete
// Contains: status, runtime, token usage
```

### subagents + Workstation

```bash
# List active sub-agents
/subagents list

# Check status of specific run
/subagents info feature-x-implementation

# Send message to sub-agent
/subagents send feature-x-implementation \
  "Priority changed: need this by EOD"
```

### Agent-to-Agent Messaging

```javascript
// Enable in openclaw.json
tools: {
  agentToAgent: {
    enabled: true,
    allow: ["developer", "architect", "devops"]
  }
}

// Send message to another agent
sessions_send({
  sessionKey: "agent:architect:main",
  message: "Design review complete, ready for implementation"
})
```

## Best Practices

### 1. Always Sync Before Switching

```bash
# Good
workstation seat sync developer
workstation seat activate architect

# Bad (risk losing context)
workstation seat activate architect  # Previous changes lost!
```

### 2. Document State Changes

```bash
# After significant work
echo "## 2026-03-07: Completed auth middleware" >> MEMORY.md
echo "- JWT validation working" >> MEMORY.md
echo "- Tests passing" >> MEMORY.md
workstation seat sync
```

### 3. Use Proposals for Critical Changes

```bash
# Always use propose-change.sh for:
# - Database migrations
# - API breaking changes
# - Infrastructure changes
# - Security modifications

# Never directly modify production without proposal
```

### 4. Keep KBs Updated

```bash
# When you learn something:
echo "## Pattern: [title]" >> KBs/KB-Core/patterns.md
echo "[Description]" >> KBs/KB-Core/patterns.md

# When you find a bug:
echo "## Bug: [description]" >> KBs/KB-Core/bugs.md
echo "Workaround: [steps]" >> KBs/KB-Core/bugs.md

git add KBs/
git commit -m "KB: Add [topic]"
```

## Configuration Example

### openclaw.json for Orchestrator

```json5
{
  agents: {
    list: [
      {
        id: "orchestrator",
        name: "Workstation Orchestrator",
        workspace: "~/.openclaw/workspace-orchestrator",
        default: true,
        tools: {
          allow: [
            "exec",           // For workstation CLI
            "read", "write",  // For file operations
            "sessions_spawn", // For sub-agents
            "subagents",      // For managing sub-agents
            "sessions_list",
            "sessions_history",
            "sessions_send"
          ]
        }
      },
      {
        id: "developer",
        name: "Developer",
        workspace: "~/.openclaw/workspace-developer",
        model: "anthropic/claude-sonnet-4-5"
      },
      {
        id: "architect",
        name: "Architect", 
        workspace: "~/.openclaw/workspace-architect",
        model: "anthropic/claude-opus-4"
      },
      {
        id: "devops",
        name: "DevOps",
        workspace: "~/.openclaw/workspace-devops",
        model: "anthropic/claude-sonnet-4-5"
      }
    ]
  },
  
  bindings: [
    {
      agentId: "orchestrator",
      match: { 
        channel: "discord", 
        peer: { id: "orchestrator-channel" }
      }
    },
    {
      agentId: "developer",
      match: { 
        channel: "discord", 
        peer: { id: "dev-channel" }
      }
    }
  ],
  
  // Allow orchestrator to spawn sub-agents
  agents: {
    defaults: {
      subagents: {
        maxSpawnDepth: 2,
        maxConcurrent: 5,
        maxChildrenPerAgent: 3
      }
    }
  },
  
  // Enable agent-to-agent messaging
  tools: {
    agentToAgent: {
      enabled: true,
      allow: ["*"]
    }
  }
}
```

## Troubleshooting

### "Seat not found"

```bash
# Check if seat exists
workstation seat list

# If not, create it
workstation seat create <id> --role <role>
```

### "Agent ID not found"

```bash
# Check openclaw.json
openclaw agents list

# If missing, add agent
openclaw agents add <id>
```

### "Lock conflict"

```bash
# Check locks
./scripts/lock-manager.sh list

# If stuck, verify and force release
./scripts/lock-manager.sh verify
./scripts/lock-manager.sh release <resource> --force
```

### "Sync failed"

```bash
# Check git status
cd ~/Workstation/MiOrg-SSOT
git status

# Resolve conflicts
git pull origin main
# Fix conflicts
git push origin main
```
