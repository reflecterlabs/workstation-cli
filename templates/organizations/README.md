# Organization Templates

Pre-configured team templates for common organizational structures.

## Available Templates

### startup-team/

A complete 5-person startup team:

| Role | Purpose | Files |
|------|---------|-------|
| **pm** | Product Manager, coordination | AGENT.md, SOUL.md, TICK.md, TOOLS.md |
| **devops** | Infrastructure, CI/CD, security | AGENT.md, SOUL.md, TICK.md, TOOLS.md |
| **developer** | Software development | AGENT.md, SOUL.md, TICK.md, TOOLS.md |
| **marketing** | Growth, content, brand | AGENT.md, SOUL.md, TICK.md, TOOLS.md |
| **seller** | Business development, sales | AGENT.md, SOUL.md, TICK.md, TOOLS.md |

**Usage:**
```bash
cd templates/organizations/startup-team/
# See README.md for setup instructions
```

## Template Structure

Each role directory contains:

```
{role}/
├── AGENT.md      # Operational manual (rules, boundaries, workflows)
├── SOUL.md       # Personality, values, communication style
├── TICK.md       # Task-specific templates (backlogs, rituals)
└── TOOLS.md      # Role-specific tools and configurations
```

## Creating Custom Templates

### 1. Create Directory

```bash
mkdir templates/organizations/my-template
mkdir templates/organizations/my-template/{role1,role2,role3}
```

### 2. Add Files

For each role, create:
- `AGENT.md` - Role-specific rules and workflows
- `SOUL.md` - Personality and communication style
- `TICK.md` - Task templates and rituals
- `TOOLS.md` - Tool configurations

### 3. Document

Create `README.md` explaining:
- Team structure
- Role interactions
- Setup instructions
- Customization guide

### 4. Submit

Share your template via PR to reflecterlabs/workstation-cli.

## Template Ideas (Community)

- [ ] `agency-team/` - Client services (account manager, designer, developer)
- [ ] `research-lab/` - Scientific research (PI, postdoc, grad student)
- [ ] `content-team/` - Media production (editor, writer, designer, video)
- [ ] `consulting-pod/` - Consulting (partner, consultant, analyst)
- [ ] `open-source/` - OSS project (maintainer, contributor, docs)

## Contributing

Have a template to share?

1. Create your template following the structure above
2. Test with actual agents
3. Document thoroughly
4. Submit PR with description of use case

---

*Templates accelerate setup. Customize for your culture.*
