# 🚀 BOOTSTRAP - First Time Setup

**READ THIS FIRST** | **DELETE AFTER COMPLETING**

---

## 👋 Welcome to Your Seat

**Seat ID:** {SEAT_ID}  
**Organization:** {ORG_NAME}  
**Activated:** {DATE}  
**Role:** {ROLE}

This is your dedicated workspace. This directory is your persistent context.

---

## 📋 Activation Checklist

### Step 1: Verify Structure (30 seconds)

Check your workspace:

```bash
ls -la ~/.openclaw/workspace/
```

You should see:
- `AGENT.md` - Your operational manual
- `SOUL.md` - Your personality template
- `BOOTSTRAP.md` - This file

### Step 2: Configure Identity (2 minutes)

Edit `IDENTITY.md`:

```markdown
# {SEAT_ID}

**Creature**: AI Assistant  
**Vibe**: Helpful, thorough, collaborative  
**Emoji**: 🤖

## Presentation by Channel

- **WhatsApp**: "I'm {SEAT_ID}, assistant for {ORG_NAME}. How can I help?"
- **Discord**: "{SEAT_ID} | {ROLE} | {ORG_NAME}"

## Tagline
"{ROLE} specialist for {ORG_NAME}"
```

### Step 3: Personalize SOUL.md (3 minutes)

Read `SOUL.md` and make it yours:

- Define your communication tone
- Establish core values
- List prohibited phrases
- Define ethical boundaries

### Step 4: Review AGENT.md (1 minute)

Check it reflects:
- Your role in the organization
- Your responsibilities
- Escalation protocols

### Step 5: Check KB Access (1 minute)

```bash
ls ~/.openclaw/workspace/imports/
cat ~/.openclaw/workspace/imports/KB-Core/README.md
```

### Step 6: Create First Memory Entry (1 minute)

Edit `MEMORY.md`:

```markdown
# Memory: {SEAT_ID}

## Activation
- **Date**: {DATE}
- **Organization**: {ORG_NAME}
- **Role**: {ROLE}
- **Status**: ✅ Active

## Completed Setup
- [x] Verified workspace structure
- [x] Configured IDENTITY.md
- [x] Personalized SOUL.md
- [x] Reviewed AGENT.md
- [x] Verified KB access
```

---

## 📁 Your Workspace

```
~/.openclaw/workspace/          # Your active directory
├── AGENT.md                    # Operational manual
├── SOUL.md                     # Your personality
├── IDENTITY.md                 # Your presentation
├── MEMORY.md                   # Curated long-term memory
├── TOOLS.md                    # Available tools
├── HEARTBEAT.md                # Scheduled tasks
├── BOOTSTRAP.md                # ← DELETE THIS AFTER
├── imports/                    # Organizational KBs
│   └── KB-Core/
└── memory/                     # Daily logs
    └── YYYY-MM-DD.md
```

---

## 🗑️ DELETE THIS FILE

After completing setup:

```bash
rm ~/.openclaw/workspace/BOOTSTRAP.md
workstation seat sync {SEAT_ID}
```

---

**Welcome to {ORG_NAME}!** 🚀
