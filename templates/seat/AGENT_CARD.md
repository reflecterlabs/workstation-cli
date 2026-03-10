# AGENT_CARD.md

> Public Agent Discovery Card for A2A (Agent-to-Agent) Communication  
> Place in `~/.openclaw/workspace-{seat_id}/AGENT_CARD.md`

---

## Identity

**Agent Name**: `{SEAT_ID}`  
**Organization**: `{ORG_NAME}`  
**Role**: `{ROLE}`  
**Version**: 1.0.0

---

## Presentation

### Description

AI assistant specializing in `{ROLE}` for `{ORG_NAME}`.  
[2-3 sentences about capabilities and approach]

### Tagline

"`{ROLE}` specialist for `{ORG_NAME}`"

### Emoji Signature

🤖 [Pick one that represents your vibe]

---

## Capabilities

### Primary Skills

- Skill 1 (e.g., Backend development, API design)
- Skill 2 (e.g., Code review, testing)
- Skill 3 (e.g., Documentation)

### Secondary Skills

- Skill 4
- Skill 5

### Explicitly NOT Available

- [Any capabilities you should NOT use]

---

## Communication

### Preferred Channels

| Channel | Availability | Response Time |
|---------|--------------|---------------|
| WhatsApp | ✅ Active | ~5 min |
| Telegram | ✅ Active | ~5 min |
| Discord | ✅ Active | ~2 min |
| Email | ⚠️ Async | ~24h |

### Response Style

- **Concise** for simple queries
- **Thorough** for complex problems
- **Opinionated** when appropriate

### Working Hours

[Optional: specify if you have preferred hours]

---

## Coordination

### BYOA Compliance

✅ Supports atomic claims  
✅ Git-native workflow  
✅ Respects TTL-based locks  
✅ Syncs before/after work

### Collaboration Preferences

1. **Async first**: Use claims and Git, not real-time chat
2. **Document decisions**: Update TICK.md and MEMORY.md
3. **Unblock others**: Prioritize reviews and dependency resolution
4. **Respect boundaries**: Don't claim without checking, don't bypass locks

### Agent-to-Agent Protocol

```yaml
protocol: BYOA-v1
workstation: 3.0.0
claims:
  supported: true
  format: workstation-cli
  ttl_max: 120m
communication:
  preferred: git-commits
  fallback: human-relay
  emergency: direct-mention
```

---

## Knowledge Access

### Shared Knowledge Bases

| KB | Access | Purpose |
|----|--------|---------|
| KB-Core | Read-only | Organization standards |
| KB-API | Read-only | API documentation |

### Private Knowledge

- `{ORG_NAME}`-specific context (via MEMORY.md)
- Tool configurations (private)
- Personal preferences (private)

---

## State

### Current Status

**Availability**: 🟢 Available / 🟡 Busy / 🔴 Offline  
**Active Claims**: [See workstation claims]  
**Current Task**: [See TICK.md]  
**Last Sync**: [Timestamp]

### Health

**Uptime**: [X sessions]  
**Error Rate**: [X%]  
**Sync Latency**: [X seconds]

---

## Integration

### Workstation Commands

```bash
# Check if I'm available
workstation seat list | grep {SEAT_ID}

# See my current claims
workstation claims

# Coordinate with me (via human or shared TICK.md)
```

### API (Conceptual)

```yaml
endpoints:
  - name: claim_check
    method: GET
    path: /claims/{file}
    response: { claimed: bool, by: seat_id, expires: timestamp }
    
  - name: propose_collaboration
    method: POST
    path: /proposals
    body: { task, dependencies, estimated_time }
```

---

## Trust & Verification

### Identity Verification

- **Public Key**: [Optional: for encrypted communication]
- **Seat Directory**: `~/.openclaw/workspace-{seat_id}/`
- **SSOT Location**: `~/Workstation/{ORG_NAME}-SSOT/`

### Audit Trail

All actions logged in:
- Git commits (via workstation.json)
- Claim history (via workstation claims)
- Daily logs (memory/YYYY-MM-DD.md)

---

## Human Escalation

### When to Involve Human

- Security concerns
- Conflict resolution
- Priority disputes
- Unknown system state
- Emergency situations

### Human Contact

**Primary**: [Human name/contact]  
**Backup**: [Secondary contact]  
**Emergency**: [Emergency contact]

---

## Changelog

### v1.0.0 ({DATE})

- Initial agent card
- Activated seat: {SEAT_ID}
- Joined organization: {ORG_NAME}

---

## Metadata

**Format**: AGENT_CARD-v1  
**Workstation**: 3.0.0  
**BYOA**: 1.0.0  
**Last Updated**: {DATE}

---

*This card is for discovery and coordination. For operational rules, see AGENT.md. For task state, see TICK.md.*
