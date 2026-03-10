# Startup Team Template

Complete organizational template for a 5-person startup team.

## Structure

```
startup-team/
├── pm/              # Product Manager
│   ├── AGENT.md     # Coordination rules, escalation matrix
│   ├── SOUL.md      # Personality: orchestrator, service-oriented
│   ├── TICK.md      # Sprint planning, team coordination
│   └── TOOLS.md     # Project management tools
├── devops/          # DevOps Engineer
│   ├── AGENT.md     # Infrastructure, CI/CD, security
│   ├── SOUL.md      # Personality: calm during incidents, proactive
│   ├── TICK.md      # Pipeline setup, monitoring, security
│   └── TOOLS.md     # Terraform, Docker, K8s
├── developer/       # Software Developer
│   ├── AGENT.md     # Development workflow, code standards
│   ├── SOUL.md      # Personality: craftsman, curious
│   ├── TICK.md      # Feature implementation, code reviews
│   └── TOOLS.md     # IDE, testing frameworks
├── marketing/       # Marketing Lead
│   ├── AGENT.md     # Content strategy, campaign planning
│   ├── SOUL.md      # Personality: creative, analytical
│   ├── TICK.md      # Content calendar, campaigns, analytics
│   └── TOOLS.md     # Analytics, social media, design
└── seller/          # Sales Lead
    ├── AGENT.md     # Sales process, pipeline management
    ├── SOUL.md      # Personality: empathetic, persistent
    ├── TICK.md      # Prospects, demos, closing
    └── TOOLS.md     # CRM, outreach, proposals
```

## Usage

### Initialize Organization

```bash
# Create organization
workstation init StartupCo
cd ~/Workstation/StartupCo-SSOT

# Create seats from template
workstation seat create pm --role "product-manager"
workstation seat create devops --role "devops-engineer"
workstation seat create developer --role "software-developer"
workstation seat create marketing --role "marketing-lead"
workstation seat create seller --role "sales-lead"

# Copy role-specific templates
cp templates/organizations/startup-team/pm/* ~/.openclaw/workspace-pm/
cp templates/organizations/startup-team/devops/* ~/.openclaw/workspace-devops/
cp templates/organizations/startup-team/developer/* ~/.openclaw/workspace-developer/
cp templates/organizations/startup-team/marketing/* ~/.openclaw/workspace-marketing/
cp templates/organizations/startup-team/seller/* ~/.openclaw/workspace-seller/

# Activate and customize
workstation seat activate pm
# Edit IDENTITY.md, SOUL.md, then rm BOOTSTRAP.md
```

## Role Interactions

```
PM (Orchestrator)
├── Coordinates: developer, devops, marketing, seller
├── Escalates to: human stakeholders
└── Manages: TICK.md priorities, _proposals/

devops ←→ developer
├── DevOps provides: infrastructure, CI/CD
├── Developer uses: provided tools
└── Both coordinate on: deployments, incidents

marketing ←→ seller
├── Marketing provides: leads, collateral
├── Seller provides: feedback, market intel
└── Both coordinate on: campaigns, messaging

PM ←→ All
├── Provides: priorities, roadmap
├── Receives: status updates, blockers
└── Coordinates: cross-team dependencies
```

## Customization

### Adapt to Your Team

1. **Modify AGENT.md** - Update responsibilities, escalation paths
2. **Adjust SOUL.md** - Match personality to your culture
3. **Update TICK.md** - Set initial tasks and priorities
4. **Edit TOOLS.md** - List your actual tools

### Add Roles

To add a new role (e.g., Designer):

```bash
mkdir templates/organizations/startup-team/designer
cp templates/organizations/startup-team/developer/* designer/
# Edit files to match designer role
```

### Remove Roles

Simply don't create seats for roles you don't need.

## Best Practices

1. **PM activates first** - Sets up coordination
2. **Each agent customizes their files** - Don't use templates verbatim
3. **First sync within 1 hour** - Establish working rhythm
4. **Daily standup via TICK.md** - Async status updates
5. **Weekly PM review** - Coordination, unblocking, priorities

## Integration

This template works seamlessly with:

- **BYOA protocol** - Each agent maintains sovereignty
- **workstation-cli** - Coordination via claims and sync
- **Git** - All state tracked, auditable
- **tick-md patterns** - Task coordination

---

*Ready to start your startup? Initialize, customize, coordinate.*
