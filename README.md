# Workstation CLI

<p align="center">
  <img src="docs/assets/logo.png" alt="Workstation CLI Logo" width="120">
</p>

<p align="center">
  <strong>Organization Manager for OpenClaw Agents</strong>
</p>

<p align="center">
  <a href="https://github.com/reflecterlabs/workstation-cli/releases">
    <img src="https://img.shields.io/github/v/release/reflecterlabs/workstation-cli?include_prereleases&style=flat-square" alt="Release">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/reflecterlabs/workstation-cli?style=flat-square" alt="License">
  </a>
  <a href="https://github.com/reflecterlabs/workstation-cli/actions">
    <img src="https://img.shields.io/github/workflow/status/reflecterlabs/workstation-cli/CI?style=flat-square" alt="CI">
  </a>
  <a href="https://github.com/reflecterlabs/workstation-cli/stargazers">
    <img src="https://img.shields.io/github/stars/reflecterlabs/workstation-cli?style=flat-square" alt="Stars">
  </a>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> •
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#documentation">Docs</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## 🎯 What is Workstation?

Workstation CLI is a **command-line tool for managing AI agent organizations**. It provides structure for multi-agent setups, knowledge bases, and persistent memory across sessions when using OpenClaw.

### Perfect for:

- 🏢 **Teams** managing multiple AI agents
- 📚 **Organizations** with shared knowledge bases
- 🔄 **Workflows** requiring agent context persistence
- 🤖 **OpenClaw users** wanting better organization

---

## ✨ Features

- 🏗️ **Multi-Organization** - Manage multiple orgs from one CLI
- 👤 **Seat Management** - Create, activate, and switch between agent workspaces
- 📚 **Knowledge Bases** - Share documentation across agents via git
- 🧠 **Memory System** - Two-level memory (curated + daily logs)
- 💾 **Automatic Backup** - Snapshots and archives with configurable retention
- 🎭 **Agent Bootstrap** - Standardized onboarding ritual for new agents
- 🔗 **OpenClaw Native** - Seamless integration with OpenClaw workspaces
- ⚡ **Git-Based** - All state tracked in version control

---

## 🚀 Quick Start

```bash
# Install
sudo curl -fsSL https://raw.githubusercontent.com/reflecterlabs/workstation-cli/main/install.sh | bash

# Initialize organization
workstation init MyCompany
cd ~/Workstation/MyCompany-SSOT

# Create agent seat
workstation seat create developer --role backend

# Activate
workstation seat activate developer
```

---

## 📦 Installation

### Prerequisites

- **bash** 4.0+ (Linux/macOS/WSL)
- **jq** - JSON processor
- **git** - Version control

```bash
# Ubuntu/Debian
sudo apt-get install jq git

# macOS
brew install jq git
```

### Methods

**Via curl (recommended):**
```bash
curl -fsSL https://raw.githubusercontent.com/reflecterlabs/workstation-cli/main/install.sh | bash
```

**Via Homebrew:**
```bash
brew tap reflecterlabs/tap
brew install workstation
```

**From source:**
```bash
git clone https://github.com/reflecterlabs/workstation-cli.git
cd workstation-cli
sudo make install
```

Verify installation:
```bash
workstation version
workstation doctor
```

---

## 📖 Documentation

- [Installation Guide](docs/INSTALL.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Configuration](docs/CONFIG.md)
- [API Reference](docs/API.md)
- [Examples](examples/)

---

## 🏗️ Architecture

```
~/.openclaw/                          # OpenClaw runtime
├── workspace/                        # Symlink to active seat
├── workspace-developer/              # Individual seat workspace
└── openclaw.json                     # OpenClaw config

~/Workstation/
└── MyCompany-SSOT/                   # Organization SSOT
    ├── workstation.json              # Central configuration
    ├── KBs/                          # Knowledge Bases
    ├── _seats/                       # Seat backups
    └── templates/                    # Seat templates
```

[Read more about architecture →](docs/ARCHITECTURE.md)

---

## 🛠️ Commands

### Organization
```bash
workstation init <name>              # Create new organization
```

### Seats (Agents)
```bash
workstation seat create <id>         # Create new agent seat
workstation seat activate <id>       # Switch to seat
workstation seat list                # List all seats
workstation seat sync [id]           # Sync seat(s)
```

### Knowledge Bases
```bash
workstation kb add <name> <repo>     # Add KB from git
workstation kb update                # Update all KBs
workstation kb list                  # List KBs
```

### Maintenance
```bash
workstation backup                   # Full backup
workstation status                   # Show status
workstation doctor                   # Check installation
```

---

## 🎨 Use Cases

### Development Team
```bash
workstation init DevTeam
workstation seat create frontend-dev --role frontend
workstation seat create backend-dev --role backend
workstation seat create devops --role devops
workstation kb add KB-Standards https://github.com/devteam/standards.git
```

### Research Lab
```bash
workstation init ResearchLab
workstation seat create researcher-1 --role data-science
workstation seat create researcher-2 --role bioinformatics
workstation kb add KB-Methods https://github.com/lab/methods.git
```

### Consulting Agency
```bash
workstation init Consultancy
workstation seat create client-a-lead --role account-manager
workstation seat create client-b-lead --role account-manager
workstation seat create analyst --role data-analyst
```

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Quick Links

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Development Setup](docs/DEVELOPMENT.md)
- [Roadmap](ROADMAP.md)

### Contributors

<a href="https://github.com/reflecterlabs/workstation-cli/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=reflecterlabs/workstation-cli" />
</a>

---

## 📜 License

[MIT License](LICENSE) © Reflecter Labs

---

## 🔗 Links

- [Website](https://reflecterlabs.org)
- [Documentation](https://docs.reflecterlabs.org/workstation)
- [OpenClaw](https://github.com/openclaw/openclaw)
- [Twitter](https://twitter.com/reflecterlabs)
- [Discord](https://discord.gg/reflecterlabs)

---

<p align="center">
  <strong>Built for AI-native organizations</strong> 🤖⚡
</p>

<p align="center">
  Made with ❤️ by <a href="https://reflecterlabs.org">Reflecter Labs</a>
</p>
