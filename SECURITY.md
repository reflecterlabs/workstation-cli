# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.0.x   | :white_check_mark: |
| 1.0.x   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in Workstation CLI, please report it to us responsibly.

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please send an email to: **security@reflecterlabs.org**

Include the following information:
- Type of vulnerability
- Full paths of source file(s) related to the vulnerability
- Location of affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

We will acknowledge receipt of your report within 48 hours and will strive to keep you informed throughout the process.

## Security Best Practices

When using Workstation CLI:

1. **Never commit secrets** - Keep API keys and tokens in environment variables
2. **Use private repositories** for your SSOT if it contains sensitive information
3. **Review templates** before using them in production
4. **Keep Workstation CLI updated** to receive security patches
5. **Audit your seats** regularly for unexpected changes

## Security Features

- All state changes are tracked in git
- No credentials stored in configuration files
- Symlinks prevent accidental modification of KBs
- Automatic backups provide recovery options
