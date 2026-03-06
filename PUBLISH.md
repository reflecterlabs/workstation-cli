# Publishing to GitHub

## Repository: https://github.com/reflecterlabs/workstation-cli

---

## 📋 Pre-Publish Checklist

- [x] Code complete and tested
- [x] Documentation written
- [x] License added (MIT)
- [x] README with badges
- [x] Contributing guidelines
- [x] Code of conduct
- [x] Security policy
- [x] Issue templates
- [x] PR template
- [x] CI/CD workflow
- [x] Install script

---

## 🚀 Publish Commands

Run these commands from the workstation-cli directory:

```bash
# Navigate to the repository
cd ~/Workstation/workstation-cli

# 1. Create the repository on GitHub (if not exists)
# Go to: https://github.com/new
# Repository name: workstation-cli
# Owner: reflecterlabs
# Visibility: Public
# ✅ Initialize with README (optional, we already have one)

# 2. Add remote and push
# Rename branch to main (recommended for new repos)
git branch -m main

# Add the remote
git remote add origin https://github.com/reflecterlabs/workstation-cli.git

# Push to GitHub
git push -u origin main

# 3. Create a release tag
git tag -a v2.0.0 -m "Release version 2.0.0"
git push origin v2.0.0

# 4. GitHub Actions will automatically:
#    - Run tests
#    - Create release
#    - Build distribution
```

---

## 🔧 Post-Publish Setup

### 1. Enable GitHub Features

Go to: https://github.com/reflecterlabs/workstation-cli/settings

- ✅ Issues: Enable
- ✅ Discussions: Enable (optional)
- ✅ Projects: Enable (optional)
- ✅ Wiki: Disable (we use docs/)

### 2. Branch Protection

Go to: https://github.com/reflecterlabs/workstation-cli/settings/branches

Add rule for `main`:
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass (CI)
- ✅ Require branches to be up to date before merging

### 3. Secrets (if needed)

Go to: https://github.com/reflecterlabs/workstation-cli/settings/secrets/actions

Add any required secrets for CI/CD.

---

## 📝 Quick Reference

### Update Repository

```bash
git add -A
git commit -m "Your message"
git push origin main
```

### Create Release

```bash
# Tag new version
git tag -a v2.1.0 -m "Release version 2.1.0"
git push origin v2.1.0

# GitHub Actions will create the release automatically
```

---

## 📊 Repository Stats

```
Total Files: $(find ~/Workstation/workstation-cli -type f -not -path '*/.git/*' | wc -l)
Total Lines: $(find ~/Workstation/workstation-cli -type f -not -path '*/.git/*' -exec wc -l {} + | tail -1)
Main Script: bin/workstation ($(wc -l < ~/Workstation/workstation-cli/bin/workstation) lines)
```

---

## 🔗 Important URLs

| Resource | URL |
|----------|-----|
| Repository | https://github.com/reflecterlabs/workstation-cli |
| Issues | https://github.com/reflecterlabs/workstation-cli/issues |
| Releases | https://github.com/reflecterlabs/workstation-cli/releases |
| Actions | https://github.com/reflecterlabs/workstation-cli/actions |

---

## 📦 Installation Commands for Users

Once published, users can install via:

```bash
# Via curl
curl -fsSL https://raw.githubusercontent.com/reflecterlabs/workstation-cli/main/install.sh | bash

# Via wget
wget -qO- https://raw.githubusercontent.com/reflecterlabs/workstation-cli/main/install.sh | bash

# From source
git clone https://github.com/reflecterlabs/workstation-cli.git
cd workstation-cli
sudo make install
```

---

**Ready to publish!** 🚀
