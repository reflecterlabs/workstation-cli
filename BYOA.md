# BYOA.md - Bring Your Own Agent Protocol

> Workstation CLI Implementation of BYOA (Bring Your Own Agent)

## Concept

**BYOA** allows every participant to bring their own customized AI agent—complete with private prompts, tools, memory, and personality—and connect it to a shared collaborative system without vendor lock-in.

This document specifies how Workstation CLI implements the BYOA protocol.

---

## Core Principles

### 1. Agent Sovereignty

```
┌────────────────────────────────────────────────────────┐
│  PRIVATE (Never leaves your machine)                   │
│  ├── System prompts                                    │
│  ├── Tool configurations                               │
│  ├── API keys (.env)                                   │
│  └── Personal memory                                   │
│                                                        │
│  SHARED (Committed to Git)                             │
│  ├── AGENT.md (operational rules)                      │
│  ├── Work products (code, docs)                        │
│  └── Claims (coordination locks)                       │
└────────────────────────────────────────────────────────┘
```

### 2. Zero Lock-in

Your agent can:
- Join any Workstation organization
- Leave without data loss
- Migrate to other BYOA-compatible systems
- Keep all private prompts and memory

### 3. Git-Native Coordination

No external servers. No databases. No MCP complexity.

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│ Agent A  │────→│  Git     │←────│ Agent B  │
│ (Seat 1) │     │ (SSOT)   │     │ (Seat 2) │
└──────────┘     └──────────┘     └──────────┘
       │                               │
       └──────────┬────────────────────┘
                  ▼
            ┌──────────┐
            │  Human   │
            │ (Referee)│
            └──────────┘
```

---

## The BYOA Handshake

### Step 1: Organization Invitation

```bash
# Human admin creates organization
workstation init CoolStartup
cd ~/Workstation/CoolStartup-SSOT

# Add KBs (shared knowledge)
workstation kb add standards https://github.com/coolstartup/standards.git

# Commit
workstation seat sync
```

### Step 2: Agent Onboarding

```bash
# Agent owner creates seat
workstation seat create my-agent --role "backend-dev"
workstation seat activate my-agent

# Complete bootstrap ritual
cat ~/.openclaw/workspace/BOOTSTRAP.md
# Edit: IDENTITY.md, SOUL.md, AGENT.md
# Delete: BOOTSTRAP.md (when done)
workstation seat sync
```

### Step 3: Collaboration Loop

```bash
# 1. Observe (read shared state)
workstation seat sync
cat imports/CoolStartup/KB-Core/CODING_STANDARDS.md

# 2. Claim (atomic lock)
workstation claim src/api.py --ttl 45m --reason "Add rate limiting"

# 3. Implement (do work)
# ... edit files ...

# 4. Reflect (sync back)
workstation seat sync

# 5. Release (unlock)
workstation release src/api.py
```

---

## State Machine

### Agent States

```
┌─────────┐    init     ┌──────────┐
│  None   │────────────→│ Created  │
└─────────┘             └────┬─────┘
                             │
                    activate │
                             ▼
                    ┌────────────────┐
                    │    Active      │←────┐
                    │ (can claim)    │     │ sync
                    └───────┬────────┘     │
                            │              │
                   deactivate│             │
                            ▼              │
                    ┌────────────────┐     │
                    │   Inactive     │─────┘
                    │ (read-only)    │
                    └────────────────┘
```

### File Claim States

```
┌───────────┐   claim   ┌───────────┐   expire   ┌───────────┐
│ Unclaimed │──────────→│  Claimed  │───────────→│  Expired  │
│           │           │  (active) │            │           │
└───────────┘           └─────┬─────┘            └───────────┘
                              │
                       release│
                              ▼
                        ┌───────────┐
                        │  Released │
                        └───────────┘
```

---

## Protocol Messages

### Claim Request

```json
{
  "protocol": "BYOA-v1",
  "type": "claim",
  "agent": {
    "id": "backend-dev",
    "seat": "workspace-backend-dev"
  },
  "resource": {
    "file": "src/auth.py",
    "type": "source-code"
  },
  "ttl": "45m",
  "reason": "Implementing OAuth2 flow",
  "timestamp": "2026-03-10T10:00:00Z",
  "expires": "2026-03-10T10:45:00Z"
}
```

### Claim Response (Success)

```json
{
  "protocol": "BYOA-v1",
  "type": "claim-ack",
  "status": "granted",
  "resource": "src/auth.py",
  "expires": "2026-03-10T10:45:00Z"
}
```

### Claim Response (Conflict)

```json
{
  "protocol": "BYOA-v1",
  "type": "claim-nack",
  "status": "denied",
  "reason": "already-claimed",
  "claimed_by": "frontend-dev",
  "expires": "2026-03-10T10:30:00Z"
}
```

---

## Conflict Resolution

### Scenario 1: Duplicate Claims

```bash
# Agent A claims file
workstation claim config.yaml --ttl 30m

# Agent B tries to claim same file
workstation claim config.yaml --ttl 30m
# ERROR: File already claimed by: agent-a
# Expires: 2026-03-10T10:30:00Z

# Options for Agent B:
# 1. Wait for expiration
# 2. Negotiate with Agent A (human-in-the-loop)
# 3. Work on different file
```

### Scenario 2: Git Merge Conflict

```bash
# Agent A creates branch, commits
workstation seat sync
git checkout -b feature/agent-a-auth
# ... work ...
git commit -m "Add auth"

# Agent B creates branch, commits
workstation seat sync
git checkout -b feature/agent-b-auth
# ... work ...
git commit -m "Add auth (different approach)"

# Both try to merge
# → Merge conflict detected
# → Human referee decides
```

---

## Security Model

### Threat: Malicious Agent

**Mitigation**: Git as immutable audit log
- Every action committed
- Every claim timestamped
- Every change reviewable

### Threat: Prompt Injection via Shared Files

**Mitigation**: Validation and sandboxing
- KBs are symlinks (read-only)
- AGENT.md is local (write-protected by convention)
- Sensitive data in `.env` (gitignored)

### Threat: Race Conditions

**Mitigation**: Atomic operations
- Claims stored in workstation.json
- Git commits are atomic
- No external state servers

---

## Comparison: BYOA vs Traditional

| Aspect | Traditional (SaaS) | BYOA (Workstation) |
|--------|-------------------|-------------------|
| **Agent Control** | Vendor-owned | You own |
| **Data Privacy** | Cloud-processed | Local-first |
| **Lock-in** | High | Zero |
| **Coordination** | Centralized API | Git (decentralized) |
| **Auditability** | Vendor logs | Git history |
| **Offline Work** | Limited | Full support |

---

## Implementation Checklist

For an agent to be BYOA-compliant with Workstation:

- [ ] Can read `workstation.json` format
- [ ] Can create/parse claim structures
- [ ] Respects TTL-based expirations
- [ ] Syncs before and after work
- [ ] Commits changes via Git
- [ ] Maintains private state separate from shared

---

## References

- [starkclaw/BYOA.md](https://github.com/keep-starknet-strange/starkclaw) - Original BYOA specification
- [tick-md](https://github.com/purple-horizons/tick-md) - Atomic claims inspiration
- [OpenClaw](https://openclaw.ai) - Agent framework

---

## Version

BYOA Protocol Version: 1.0  
Workstation CLI Implementation: 3.0.0
