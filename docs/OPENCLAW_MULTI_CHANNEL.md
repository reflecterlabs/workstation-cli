# OpenClaw Multi-Channel Agent Configuration

> Configuring OpenClaw for multiple agents on a single machine with separate channels

## Understanding OpenClaw Architecture

### The `main:main` Concept

```
main:main
└─┬───┴──┘
  │    │
  │    └── Session (main session of the agent)
  │
  └── Agent (main is the default agent)
```

**Current Status**: You have ONE agent (`main`) with ONE session (`main`).

```
~/.openclaw/
└── agents/
    └── main/                    ← Your current (and only) agent
        ├── sessions/
        │   └── sessions.json    ← Active sessions
        └── config/              ← Agent-specific config
```

---

## Option 1: Single Agent, Multiple Channels (Recommended for Simple Setup)

One agent handles all channels and routes internally.

### Architecture

```
┌─────────────────────────────────────┐
│           Agent: main               │
│         (Single Instance)           │
├─────────────────────────────────────┤
│  Channels:                          │
│    ├── Telegram: @company_pm_bot    │
│    ├── WhatsApp: Design Group       │
│    └── Discord: #dev-channel        │
├─────────────────────────────────────┤
│  Internal Routing:                  │
│    IF telegram → PM personality     │
│    IF whatsapp → Design personality │
│    IF discord → Dev personality     │
└─────────────────────────────────────┘
```

### Configuration

```bash
# ~/.openclaw/config.json
{
  "agents": {
    "main": {
      "model": "kimi-coding/k2p5",
      "channels": {
        "telegram": {
          "enabled": true,
          "bots": [
            {
              "token": "${TELEGRAM_PM_BOT_TOKEN}",
              "personality": "pm",
              "allowed_chats": ["private", "group"]
            },
            {
              "token": "${TELEGRAM_DESIGN_BOT_TOKEN}",
              "personality": "design",
              "allowed_groups": ["design_team"]
            }
          ]
        },
        "whatsapp": {
          "enabled": true,
          "sessions": [
            {
              "name": "design_session",
              "personality": "design",
              "phone": "+1234567890"
            }
          ]
        },
        "discord": {
          "enabled": true,
          "bots": [
            {
              "token": "${DISCORD_BOT_TOKEN}",
              "guilds": [
                {
                  "id": "GUILD_ID",
                  "channels": [
                    {
                      "name": "dev-agent",
                      "personality": "developer"
                    },
                    {
                      "name": "pm-agent",
                      "personality": "pm"
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
  },
  "personalities": {
    "pm": {
      "workspace": "~/.openclaw/workspace-pm",
      "prompt_file": "~/.openclaw/workspace-pm/AGENT.md",
      "soul_file": "~/.openclaw/workspace-pm/SOUL.md"
    },
    "design": {
      "workspace": "~/.openclaw/workspace-design",
      "prompt_file": "~/.openclaw/workspace-design/AGENT.md",
      "soul_file": "~/.openclaw/workspace-design/SOUL.md"
    },
    "developer": {
      "workspace": "~/.openclaw/workspace-developer",
      "prompt_file": "~/.openclaw/workspace-developer/AGENT.md",
      "soul_file": "~/.openclaw/workspace-developer/SOUL.md"
    }
  }
}
```

### How It Works

1. **Single OpenClaw instance** runs all channels
2. **Incoming message** → OpenClaw checks channel + context
3. **Routes to personality** → Loads appropriate AGENT.md + SOUL.md
4. **Switches workspace** → Uses correct `~/.openclaw/workspace-{role}/`
5. **Responds** with appropriate personality

---

## Option 2: Multiple Agents (True Isolation)

Each agent runs as separate OpenClaw instance with complete isolation.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Machine (Your PC)                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │  OpenClaw PM     │  │  OpenClaw Design │                │
│  │  Port: 18790     │  │  Port: 18791     │                │
│  │  Agent: pm       │  │  Agent: design   │                │
│  ├──────────────────┤  ├──────────────────┤                │
│  │ Channel:         │  │ Channel:         │                │
│  │   Telegram       │  │   WhatsApp       │                │
│  │ Workspace:       │  │ Workspace:       │                │
│  │   workspace-pm/  │  │   workspace-des/ │                │
│  └──────────────────┘  └──────────────────┘                │
│                                                             │
│  ┌──────────────────┐                                      │
│  │  OpenClaw Dev    │                                      │
│  │  Port: 18792     │                                      │
│  │  Agent: dev      │                                      │
│  ├──────────────────┤                                      │
│  │ Channel:         │                                      │
│  │   Discord        │                                      │
│  │ Workspace:       │                                      │
│  │   workspace-dev/ │                                      │
│  └──────────────────┘                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
         │              │              │
         └──────────────┼──────────────┘
                        │
         ┌──────────────▼──────────────┐
         │   Shared Git Repository     │
         │   ~/Workstation/Org-SSOT/   │
         └─────────────────────────────┘
```

### Configuration

#### Agent 1: PM (Telegram)

```bash
# Directory: ~/.openclaw-agents/pm/
mkdir -p ~/.openclaw-agents/pm

# Config: ~/.openclaw-agents/pm/config.json
cat > ~/.openclaw-agents/pm/config.json << 'EOF'
{
  "agents": {
    "pm": {
      "model": "kimi-coding/k2p5",
      "workspace": "~/.openclaw/workspace-pm",
      "gateway": {
        "port": 18790
      },
      "channels": {
        "telegram": {
          "enabled": true,
          "token": "${TELEGRAM_PM_TOKEN}"
        }
      }
    }
  }
}
EOF
```

#### Agent 2: Design (WhatsApp)

```bash
mkdir -p ~/.openclaw-agents/design

cat > ~/.openclaw-agents/design/config.json << 'EOF'
{
  "agents": {
    "design": {
      "model": "kimi-coding/k2p5",
      "workspace": "~/.openclaw/workspace-design",
      "gateway": {
        "port": 18791
      },
      "channels": {
        "whatsapp": {
          "enabled": true,
          "session": "design_session"
        }
      }
    }
  }
}
EOF
```

#### Agent 3: Developer (Discord)

```bash
mkdir -p ~/.openclaw-agents/dev

cat > ~/.openclaw-agents/dev/config.json << 'EOF'
{
  "agents": {
    "developer": {
      "model": "kimi-coding/k2p5",
      "workspace": "~/.openclaw/workspace-developer",
      "gateway": {
        "port": 18792
      },
      "channels": {
        "discord": {
          "enabled": true,
          "token": "${DISCORD_DEV_TOKEN}",
          "channel": "dev-agent"
        }
      }
    }
  }
}
EOF
```

### Running Multiple Agents

```bash
# Terminal 1: PM Agent
export OPENCLAW_HOME=~/.openclaw-agents/pm
openclaw gateway start --port 18790

# Terminal 2: Design Agent
export OPENCLAW_HOME=~/.openclaw-agents/design
openclaw gateway start --port 18791

# Terminal 3: Developer Agent
export OPENCLAW_HOME=~/.openclaw-agents/dev
openclaw gateway start --port 18792
```

---

## Option 3: Hybrid (Recommended for Workstation)

Combine both approaches: One OpenClaw instance, but each channel routes to a different workstation seat.

### Configuration

```json
{
  "agents": {
    "main": {
      "model": "kimi-coding/k2p5",
      "workstation_integration": {
        "enabled": true,
        "organization": "MiEmpresa",
        "ssot_path": "~/Workstation/MiEmpresa-SSOT"
      },
      "channels": {
        "telegram": {
          "enabled": true,
          "routing": {
            "@pm_bot": {
              "seat": "pm",
              "workspace": "~/.openclaw/workspace-pm"
            },
            "@design_bot": {
              "seat": "design",
              "workspace": "~/.openclaw/workspace-design"
            }
          }
        },
        "discord": {
          "enabled": true,
          "routing": {
            "#dev-agent": {
              "seat": "developer",
              "workspace": "~/.openclaw/workspace-developer"
            }
          }
        }
      }
    }
  }
}
```

### How It Works with Workstation

```
User messages @pm_bot on Telegram
         │
         ▼
┌──────────────────────┐
│   OpenClaw Gateway   │
│   (Single Instance)  │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Routes to "pm" seat │
│  Loads workspace-pm/ │
│  AGENT.md (PM rules) │
│  SOUL.md (PM persona)│
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Can use workstation │
│  commands:           │
│  - seat sync         │
│  - claims            │
│  - etc               │
└──────────────────────┘
```

---

## Quick Setup Script

```bash
#!/bin/bash
# setup-openclaw-multi.sh

echo "Setting up OpenClaw for multi-channel agents..."

# 1. Create agent workspaces
workstation init MiEmpresa
workstation seat create pm --role "product-manager"
workstation seat create design --role "designer"
workstation seat create developer --role "developer"

# 2. Create OpenClaw config for multi-channel
cat > ~/.openclaw/config.json << 'EOF'
{
  "agents": {
    "main": {
      "channels": {
        "telegram": {
          "enabled": true,
          "bots": [
            {
              "id": "pm_bot",
              "token": "${TELEGRAM_PM_TOKEN}",
              "seat": "pm",
              "workspace": "~/.openclaw/workspace-pm"
            }
          ]
        },
        "whatsapp": {
          "enabled": true,
          "sessions": [
            {
              "id": "design_session",
              "seat": "design",
              "workspace": "~/.openclaw/workspace-design"
            }
          ]
        },
        "discord": {
          "enabled": true,
          "bots": [
            {
              "id": "dev_bot",
              "token": "${DISCORD_DEV_TOKEN}",
              "seat": "developer",
              "workspace": "~/.openclaw/workspace-developer"
            }
          ]
        }
      }
    }
  }
}
EOF

echo "✓ Configuration created at ~/.openclaw/config.json"
echo ""
echo "Next steps:"
echo "1. Set environment variables:"
echo "   export TELEGRAM_PM_TOKEN=your_token"
echo "   export DISCORD_DEV_TOKEN=your_token"
echo ""
echo "2. Pair WhatsApp:"
echo "   openclaw channel whatsapp pair"
echo ""
echo "3. Start OpenClaw:"
echo "   openclaw gateway start"
```

---

## Current State Analysis

Based on `openclaw status` output:

```
Agents: 1 · 1 bootstrap file present · sessions 2 · default main active just now
```

**What you have**:
- ✅ One agent (`main`) configured
- ✅ Gateway running on port 18789
- ⚠️ Agent shows as `configured: false` (needs channel setup)
- ⚠️ No channels currently configured

**What's missing**:
- Channel configurations (Telegram, WhatsApp, Discord)
- Workspace-to-channel mappings
- Personality/seat routing

---

## Recommendation

For your use case (multiple agents, same PC, different channels):

**Use Option 1 (Single Agent, Multi-Channel)** because:

1. ✅ Simpler to manage
2. ✅ One OpenClaw instance
3. ✅ Workstation handles the multi-seat coordination
4. ✅ Each channel can still have distinct personality via AGENT.md

**Configuration needed**:

```bash
# 1. Set up workstation seats
workstation seat create pm
workstation seat create design
workstation seat create developer

# 2. Configure OpenClaw with multi-channel routing
# (Use config example from Option 1 above)

# 3. Each channel will automatically:
#    - Load correct AGENT.md
#    - Use correct workspace
#    - Have access to workstation commands
```

---

## Next Steps

1. **Decide architecture**: Single agent with routing vs multiple agents
2. **Configure channels**: Add Telegram/WhatsApp/Discord tokens
3. **Set up routing**: Map channels to workstation seats
4. **Test**: Send message to each channel, verify correct personality

Would you like me to create the specific configuration files for your setup?
