# Installation Guide

## Prerequisites

- **bash** 4.0+ (Linux/macOS/WSL)
- **jq** - JSON processor
- **git** - Version control
- **OpenClaw** (optional) - Agent runtime

### Installing Prerequisites

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install jq git curl
```

**macOS:**
```bash
brew install jq git
```

**CentOS/RHEL:**
```bash
sudo yum install jq git
```

---

## Install Workstation

### Option 1: Direct Download

```bash
# Download latest release
curl -L https://github.com/agentzfactory/workstation/releases/latest/download/workstation.tar.gz | tar xz

# Install globally
sudo cp workstation/bin/workstation /usr/local/bin/
sudo chmod +x /usr/local/bin/workstation
```

### Option 2: Clone Repository

```bash
# Clone
git clone https://github.com/agentzfactory/workstation.git

# Add to PATH
echo 'export PATH="$PATH:'$(pwd)'/workstation/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Option 3: Using Make

```bash
git clone https://github.com/agentzfactory/workstation.git
cd workstation
sudo make install
```

---

## Verify Installation

```bash
workstation version
workstation doctor
```

Expected output:
```
Workstation CLI v2.0.0
Organization Manager for OpenClaw

Paths:
  WORKSTATION_ROOT: /home/user/Workstation
  OPENCLAW_HOME: /home/user/.openclaw

=== Workstation Doctor ===

Checking jq... found
Checking git... found
Checking OpenClaw... found
...
All checks passed
```

---

## Configuration

### Environment Variables

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Workstation root directory
export WORKSTATION_ROOT="$HOME/Workstation"

# OpenClaw home (if different from default)
export OPENCLAW_HOME="$HOME/.openclaw"

# Optional: Enable debug output
# export WORKSTATION_DEBUG=1
```

### Shell Completion

**Bash:**
```bash
workstation completion bash > /etc/bash_completion.d/workstation
```

**Zsh:**
```bash
workstation completion zsh > "${fpath[1]}/_workstation"
```

---

## First Organization

```bash
# Create your first organization
workstation init MyOrg

# Navigate to it
cd ~/Workstation/MyOrg-SSOT

# Create a seat
workstation seat create developer --role backend

# Activate it
workstation seat activate developer
```

---

## Troubleshooting

### "jq not found"

Install jq using your package manager (see Prerequisites).

### "Permission denied"

Ensure the binary is executable:
```bash
chmod +x /usr/local/bin/workstation
```

### "No workstation.json found"

Make sure you're in an SSOT directory:
```bash
cd ~/Workstation/MyOrg-SSOT
```

### OpenClaw not detected

Workstation works without OpenClaw, but for full functionality:
```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

---

## Uninstallation

```bash
# Remove binary
sudo rm /usr/local/bin/workstation

# Remove data (optional)
rm -rf ~/Workstation

# Remove from PATH
# Edit ~/.bashrc or ~/.zshrc and remove workstation-related lines
```
