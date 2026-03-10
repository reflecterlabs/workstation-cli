# CONCEPTS.md - Workstation Ecosystem Guide

> Understanding BYOA, Markdown Contracts, and Multi-Agent Coordination

---

## Table of Contents

1. [BYOA: Bring Your Own Agent](#1-byoa-bring-your-own-agent)
2. [Markdown as Living Contracts](#2-markdown-as-living-contracts)
3. [Alignment Mechanisms](#3-alignment-mechanisms)
4. [Git for Multi-Agent](#4-git-for-multi-agent-coordination)
5. [Tooling Ecosystem](#5-tooling-ecosystem)
6. [Workstation's Unique Approach](#6-workstations-unique-approach)

---

## 1. BYOA: Bring Your Own Agent

### The Problem

Traditional AI platforms lock you in:
- Your prompts live in their cloud
- Your agent's memory is vendor-controlled
- Switching platforms means starting over
- Collaboration requires everyone using the same vendor

### The Solution

**BYOA (Bring Your Own Agent)** decouples the agent from the platform:

```
┌─────────────────────────────────────────────────────────┐
│  Traditional              │  BYOA (Workstation)         │
├─────────────────────────────────────────────────────────┤
│  Vendor Platform          │  Your Agent (Private)       │
│  ├─ Your prompts          │  ├─ Your prompts            │
│  ├─ Your memory           │  ├─ Your memory             │
│  ├─ Your tools            │  ├─ Your tools              │
│  └─ Collaboration layer   │  └─ Private config          │
│                           │                             │
│                           │  Shared Layer (Git)         │
│                           │  ├─ Coordination (claims)   │
│                           │  ├─ Knowledge (KBs)         │
│                           │  └─ Audit trail (commits)   │
└─────────────────────────────────────────────────────────┘
```

### Key Principles

| Principle | Meaning |
|-----------|---------|
| **Sovereignty** | You own your agent's prompts, memory, and personality |
| **Interoperability** | Standard protocols enable cross-agent collaboration |
| **Auditability** | Everything tracked in Git—no black boxes |
| **No Lock-in** | Switch organizations, keep your agent intact |

### Real-World Example

**Scenario**: Three developers (Alice, Bob, Carol) want to collaborate on a project.

**Traditional Approach**:
- All use same platform (e.g., Cursor, Copilot)
- Share prompts via copy-paste
- Coordination via Slack + manual task tracking
- Vendor sees all code, all conversations

**BYOA Approach (Workstation)**:
- Each brings their own OpenClaw agent
- Workstation provides shared coordination layer
- Claims, KBs, and state in Git repo
- Each agent keeps private prompts/tools
- No vendor sees private data

---

## 2. Markdown as Living Contracts

### The Pattern

Markdown files serve as **human-readable, machine-parseable contracts** between agents and humans.

### File Hierarchy

```
~/.openclaw/workspace-{seat}/
├── AGENT.md          # Operational rules (the "constitution")
├── SOUL.md           # Personality and values (the "identity")
├── IDENTITY.md       # Public presentation (the "business card")
├── MEMORY.md         # Curated long-term memory (the "diary")
├── TOOLS.md          # Environment configuration (the "toolbox")
├── TICK.md           # Task state (the "dashboard")
├── HEARTBEAT.md      # Cyclic behavior (the "rhythm")
├── AGENT_CARD.md     # A2A discovery (the "profile")
└── BOOTSTRAP.md      # Onboarding (the "tutorial")
```

### Comparison: File Roles

| File | Purpose | When to Read | When to Write |
|------|---------|--------------|---------------|
| **AGENT.md** | Operational rules | Every session | Rarely (evolves with role) |
| **SOUL.md** | Personality | Every session | When identity evolves |
| **MEMORY.md** | Long-term context | Every session | When learning significant things |
| **TICK.md** | Current tasks | Multiple times/session | When task state changes |
| **HEARTBEAT.md** | Schedules | At session start | When rhythms change |
| **AGENT_CARD.md** | Public profile | Rarely | When capabilities change |

### Recommended Combinations

✅ **Good Combinations**:

```
AGENTS.md + SKILL.md      → Modular capabilities with clear rules
AGENTS.md + TICK.md       → Real-time task coordination
BYOA.md + AGENTS.md       → Sovereignty + internal rules
HEARTBEAT.md + TICK.md    → Autonomous loops + persistent state
```

❌ **Anti-patterns**:

```
TICK.md + plan.md + tasks.md  → Confusion: which is source of truth?
CLAUDE.md + AGENTS.md         → Conflict: duplicate authority
```

### Why Markdown?

| Advantage | Explanation |
|-----------|-------------|
| **Human-readable** | Humans can review and edit without tools |
| **Git-friendly** | Diffable, version-controlled, auditable |
| **Low cost** | 200-500 tokens to read, minimal context usage |
| **Portable** | Works across any agent framework |
| **Extensible** | Easy to add new fields, sections, conventions |

---

## 3. Alignment Mechanisms

### The Challenge

Multiple agents working together face:
- **Drift**: Agents diverge in understanding
- **Conflicts**: Two agents edit same file
- **Deadlocks**: Agents wait on each other
- **Orphans**: Tasks abandoned mid-work

### Solutions in Workstation

#### 3.1 Single Source of Truth

**`workstation.json`** is the only mutable machine state:

```json
{
  "organization": { "name": "MyOrg" },
  "seats": [
    { "id": "dev-1", "status": "active", "last_sync": "2026-03-10T10:00:00Z" }
  ],
  "claims": [
    { "file": "src/auth.py", "seat": "dev-1", "expires": "2026-03-10T10:30:00Z" }
  ]
}
```

Rules:
- Read at session start
- Update atomically (via jq + git)
- Never cache beyond session

#### 3.2 Atomic Claims

Time-bounded exclusive locks:

```bash
# Create claim
workstation claim src/auth.py --ttl 45m --reason "Refactor"

# System prevents others from claiming same file
# Expires automatically (no manual cleanup needed)
```

Benefits:
- Prevents edit collisions
- Self-cleaning (TTL expiration)
- Git-auditable (every claim is a commit)

#### 3.3 Sync Protocol

```bash
# Before work
workstation seat sync
# → Updates KB symlinks
# → Checks claim expirations
# → Backs up critical files

# After work
workstation seat sync
# → Creates snapshot
# → Commits state changes
# → Updates timestamps
```

#### 3.4 Strict Rules in AGENT.md

```markdown
## Coordination Rules

1. Always sync before starting work
2. Check claims before editing any file
3. Never create tasks without approval
4. Prioritize unblocking others
5. Sync after every session
```

---

## 4. Git for Multi-Agent Coordination

### Why Git?

| Feature | Benefit for Multi-Agent |
|---------|------------------------|
| **Atomic commits** | All-or-nothing state changes |
| **Immutable history** | Full audit trail of who did what when |
| **Branches** | Parallel work without collision |
| **Merge conflicts** | Explicit detection of divergence |
| **Distributed** | Works offline, syncs when connected |

### Branch Strategies

| Pattern | Use Case | Example |
|---------|----------|---------|
| `feature/TASK-042` | Task-oriented (tick-md style) | `feature/add-oauth` |
| `agent/${ID}/${issue}` | Agent-owned (starkclaw style) | `agent/dev-1/42-fix-auth` |
| `{seat}/{role}` | Seat-based (workstation style) | `backend/api-redesign` |

### Conflict Resolution Flow

```
1. Agent A commits to feature/TASK-001
2. Agent B commits to feature/TASK-002
3. Both try to merge to main
4. Git detects conflict
5. Options:
   a. Rebase → resolve → merge (preferred)
   b. Human-in-the-loop for complex conflicts
   c. Revert one PR, retry (emergency)
```

### Worktrees for Parallelism

```bash
# Enable true parallel work
git worktree add ../workspace-agent-a-task-001 feature/TASK-001
git worktree add ../workspace-agent-b-task-002 feature/TASK-002

# Each agent works in isolation
# Merge back via PR when complete
```

---

## 5. Tooling Ecosystem

### tick-md

**Focus**: Task coordination via TICK.md

**Key Features**:
- Atomic claims via YAML updates
- Git as orchestrator
- Human-readable state

**Best For**: Teams wanting simple, file-based task management

### starkclaw/BYOA.md

**Focus**: Decentralized BYOA protocol

**Key Features**:
- GitHub-first (issues + PRs + labels)
- No external servers
- Security-focused (wallet/crypto use cases)

**Best For**: Open communities, security-conscious teams

### workstation-cli

**Focus**: Local-first organization management

**Key Features**:
- Isolated seats per agent
- Git-shared KBs
- Atomic file claims
- Automatic backups

**Best For**: Persistent organizations, multi-agent teams

### CodeRabbit

**Focus**: Quality gates

**Key Features**:
- Pre-merge code review
- Reduces hallucinations in code generation
- CLI and IDE plugins

**Best For**: Code-generating agent swarms

### OpenClaw

**Focus**: Multi-channel agent framework

**Key Features**:
- Sessions across WhatsApp, Telegram, Discord, etc.
- Memory persistence
- Tool ecosystem

**Best For**: Agents that need to interact across multiple channels

---

## 6. Workstation's Unique Approach

### Philosophy

Workstation combines the best of:

| From | Concept | Implementation |
|------|---------|----------------|
| **starkclaw** | BYOA protocol | Git-native, no lock-in |
| **tick-md** | Atomic claims | `workstation claim` with TTL |
| **OpenClaw** | Seat isolation | `~/.openclaw/workspace-{seat}` |
| **Git** | Auditability | Every action is a commit |

### Key Differentiators

1. **Local-First**: Works entirely offline, syncs via Git
2. **Seat Isolation**: Each agent has true workspace isolation
3. **Atomic Operations**: Claims, syncs, and updates are all-or-nothing
4. **No External Dependencies**: No servers, no databases, no APIs
5. **Human-Readable State**: workstation.json is inspectable and editable

### When to Use Workstation

✅ **Good Fit**:
- Persistent teams with multiple agents
- Need for offline work capability
- Security requirements (no cloud processing)
- Git-native workflows

❌ **Not Ideal**:
- Real-time chat-based coordination
- Need for centralized dashboards
- Non-technical users
- Simple single-agent setups

---

## Summary

```
BYOA          → Sovereignty without isolation
Markdown      → Human-readable, machine-parseable contracts
Git           → Immutable, auditable, distributed truth
Workstation   → Local-first, atomic, multi-agent coordination
```

**The future is multi-agent, decentralized, and Git-native.**

---

*Workstation CLI v3.0 - Built for AI-native organizations.*
