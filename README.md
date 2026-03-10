# Workstation CLI

> **BYOA-Native Organization Manager for OpenClaw Agents**

Workstation CLI implements a **BYOA (Bring Your Own Agent)** protocol for managing AI agent organizations. It provides isolated workspaces, shared knowledge bases, and atomic file locking for multi-agent coordination—all backed by Git as the single source of truth.

---

## 🎯 Core Concept: BYOA (Bring Your Own Agent)

**BYOA** means every person/team brings their own customized agent (prompts, tools, memory, personality) and connects it to a collaborative system without vendor lock-in.

### Analogy
- **BYOD** (Bring Your Own Device) → **BYOA** (Bring Your Own Agent)
- Just as BYOD let employees use personal devices securely, BYOA lets agents maintain sovereignty while collaborating

### Workstation's BYOA Implementation

```
┌─────────────────────────────────────────────────────────────┐
│                    YOUR AGENT                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Prompts   │  │    Tools    │  │   Memory    │         │
│  │  (Private)  │  │  (Private)  │  │  (Private)  │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              WORKSTATION SEAT                        │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │    │
│  │  │AGENT.md  │  │SOUL.md   │  │MEMORY.md │  (Shared) │    │
│  │  │(Config)  │  │(Persona) │  │(Context) │            │    │
│  │  └──────────┘ └──────────┘ └──────────┘            │    │
│  │           │                                         │    │
│  │           ▼                                         │    │
│  │  ┌────────────────────────────────────────────┐    │    │
│  │  │  imports/KB-Core (Knowledge Base Symlink)  │    │    │
│  │  └────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────┘    │
│           │                                                  │
│           ▼                                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              ORGANIZATION SSOT                       │    │
│  │         (Git Repository - Shared)                    │    │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐    │    │
│  │  │ workstation│  │    KBs     │  │   Claims   │    │    │
│  │  │   .json    │  │ (Shared)   │  │ (Locks)    │    │    │
│  │  └────────────┘  └────────────┘  └────────────┘    │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Sovereignty**: Your agent keeps its prompts, tools, and sensitive data private
2. **Interoperability**: Standardized protocols for cross-agent collaboration
3. **Auditability**: Everything tracked in Git—no black boxes
4. **No Lock-in**: Switch organizations, keep your agent

---

## 📁 Markdown as "Living Contracts"

Workstation uses Markdown files as lightweight, human-readable contracts between agents and humans.

### File Structure per Seat

```
~/.openclaw/workspace-{seat_id}/
├── AGENT.md          # Operational manual (rules, guardrails)
├── SOUL.md           # Personality, tone, values
├── IDENTITY.md       # Public identity, presentation
├── MEMORY.md         # Curated long-term memory
├── TOOLS.md          # Environment-specific tools/config
├── HEARTBEAT.md      # Cyclic behavior loop (observe → act → reflect)
├── BOOTSTRAP.md      # Onboarding ritual (delete after setup)
├── imports/          # KB symlinks (read-only shared knowledge)
└── memory/           # Daily logs (YYYY-MM-DD.md)
```

### Recommended Combinations

| Combination | Use Case | Strength |
|-------------|----------|----------|
| **AGENTS.md + SKILL.md** | Modular capabilities with clear rules | ⭐⭐⭐⭐⭐ |
| **AGENTS.md + TICK.md** | Real-time task coordination | ⭐⭐⭐⭐⭐ |
| **BYOA.md + AGENTS.md** | Sovereignty + internal rules | ⭐⭐⭐⭐ |
| **HEARTBEAT.md + TICK.md** | Autonomous loops + persistent state | ⭐⭐⭐⭐ |

### Anti-patterns to Avoid

❌ **Multiple state files**: `TICK.md` + `plan.md` + `tasks.md` → confusion about source of truth  
❌ **Duplicated configs**: `CLAUDE.md` + `AGENTS.md` → priority conflicts  
✅ **One source of truth**: `workstation.json` for machine state, `AGENT.md` for rules

---

## 🔒 Alignment Mechanisms (Preventing Drift)

### 1. Single Source of Truth

**`workstation.json`** is the only mutable machine-readable state:

```json
{
  "organization": { "name": "MyOrg", ... },
  "seats": [
    {
      "id": "backend-dev",
      "role": "developer",
      "status": "active",
      "last_sync": "2026-03-10T10:00:00Z"
    }
  ],
  "kbs": [...],
  "claims": [
    {
      "file": "src/main.py",
      "seat": "backend-dev",
      "expires": "2026-03-10T10:30:00Z",
      "reason": "Refactoring authentication"
    }
  ]
}
```

### 2. Atomic Claims (Exclusive Locks)

Prevent race conditions with time-bounded file locks:

```bash
# Claim exclusive editing rights
workstation claim src/main.py --ttl 45m --reason "Refactoring auth"

# Check active claims
workstation claims
# Output:
#   src/main.py | claimed by: backend-dev | expires: 2026-03-10T10:30:00Z

# Release when done
workstation release src/main.py
```

**Git as Arbiter**: Every claim is a Git commit—immutable, timestamped, auditable.

### 3. Sync Protocol

```bash
# Before starting work
workstation seat sync

# Reads: MEMORY.md, HEARTBEAT.md, latest daily log
# Updates: KB symlinks, checks claim expirations

# After finishing work
workstation seat sync

# Backs up: AGENT.md, SOUL.md, MEMORY.md, memory/
# Commits: workstation.json with updated timestamps
```

### 4. Strict Rules (AGENTS.md)

```markdown
## Coordination Rules

1. **Always read TICK.md/HEARTBEAT.md first** before acting
2. **Never create tasks without proposing** in _proposals/
3. **Check claims before editing** any shared file
4. **Prioritize unblocking others** over new work
5. **Sync before and after** every session
```

---

## 🌿 Git for Multi-Agent Coordination

### Branch Strategy

| Pattern | Use Case | Example |
|---------|----------|---------|
| `feature/TASK-042` | tick-md style tasks | `feature/add-oauth` |
| `agent/{id}/{issue}-desc` | starkclaw style | `agent/dev-1/42-auth-refactor` |
| `{seat}/{role}` | workstation style | `backend/api-redesign` |

### Conflict Resolution

1. **Claims + short branches** → conflicts are rare
2. **If conflict occurs**:
   ```bash
   git fetch origin
   git rebase origin/main
   # If complex: abort, notify, human-in-the-loop
   ```
3. **Critical merges**: Require human review
4. **Emergency revert**: Immediate PR revert if main breaks

### Worktrees for Parallelism

```bash
# Enable true parallel work without repo cloning
git worktree add ../workspace-frontend-task-042 feature/TASK-042
git worktree add ../workspace-backend-task-043 feature/TASK-043

# Each agent works in isolation
# Merge back via PR when complete
```

---

## 🛠️ Tooling Ecosystem

| Tool | Role | Integration with Workstation |
|------|------|------------------------------|
| **tick-md** | Atomic claims + Git orchestration | Workstation's `claim` command implements similar logic |
| **starkclaw/BYOA.md** | GitHub-first decentralized protocol | Workstation adapts BYOA for local-first use |
| **CodeRabbit** | Quality gate / review | Run pre-sync: `coderabbit review --diff` |
| **OpenClaw** | Multi-channel agent framework | Workstation manages OpenClaw workspaces |

### Comparison Matrix

| Feature | Workstation CLI | starkclaw/BYOA | tick-md |
|---------|-----------------|----------------|---------|
| **Focus** | Local-first org management | GitHub-first decentralized | Task coordination |
| **Coordination** | File claims in JSON | GitHub issues/comments | TICK.md YAML |
| **Storage** | Git repo (SSOT) | GitHub as message bus | Git repo |
| **Multi-agent** | Yes (seats) | Yes (BYOA) | Yes |
| **Installation** | CLI tool | Protocol/spec | Convention |
| **Best for** | Persistent orgs | Open communities | Task queues |

---

## 🚀 Quick Start

```bash
# Install
sudo cp bin/workstation /usr/local/bin/
workstation doctor

# 1. Initialize organization (BYOA entry point)
workstation init MyCompany
cd ~/Workstation/MyCompany-SSOT

# 2. Create your agent seat
workstation seat create backend-dev --role developer
workstation seat activate backend-dev

# 3. Complete BOOTSTRAP.md ritual
# (Edit IDENTITY.md, SOUL.md, then rm BOOTSTRAP.md)

# 4. Claim work (atomic coordination)
workstation claim src/auth.py --ttl 60m --reason "Add OAuth2"

# 5. Do work... then sync
workstation seat sync

# 6. Release claim
workstation release src/auth.py
```

---

## 📊 Architecture

See [workstation-architecture.puml](docs/workstation-architecture.puml) for full PlantUML diagrams.

```
User → CLI → workstation.json → Git
                ↓
            KBs (git repos)
                ↓
            Seats (isolated workspaces)
                ↓
            Claims (coordination locks)
```

---

## 📚 Further Reading

- [BYOA.md](BYOA.md) - BYOA protocol specification
- [AGENTS.md](AGENTS.md) - Agent operational manual template
- [TICK.md](TICK.md) - Task coordination (adapted for workstation)
- [AGENT_CARD.md](AGENT_CARD.md) - Public agent discovery format
- [HEARTBEAT.md](HEARTBEAT.md) - Cyclic behavior loop
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development guide

---

## 📝 License

MIT License © 2026 Reflecter Labs

---

*Built for AI-native organizations. Bring your own agent. 🤖⚡*
