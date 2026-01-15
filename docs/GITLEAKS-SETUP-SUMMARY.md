# Gitleaks - Pre-Commit Secret Scanning

**Setup Date:** January 15, 2026
**Purpose:** Automatically scan for secrets/keys/passwords before every git commit

---

## TL;DR

Gitleaks runs automatically on every `git commit` across all repos on this Mac. If it finds secrets, the commit is blocked. No manual scanning needed.

---

## Why This Exists

- Prevents accidentally committing API keys, passwords, tokens, SSNs
- Catches mistakes BEFORE they enter git history
- Free, fast (milliseconds), runs automatically
- Better than relying on manual AI scans

---

## What Was Installed

| Component | Location |
|-----------|----------|
| gitleaks binary | `/opt/homebrew/bin/gitleaks` (via Homebrew) |
| Global pre-commit hook | `~/.git-hooks/pre-commit` |
| Git config | `core.hooksPath = ~/.git-hooks` |

---

## What It Catches

- AWS keys (access key ID, secret key)
- Azure/GCP credentials
- GitHub/GitLab tokens
- Slack/Discord tokens
- Private keys (RSA, SSH, PGP)
- Passwords in config files
- Generic high-entropy secrets
- API keys (generic patterns)

---

## How It Works

```
git add <files>
git commit -m "message"
    │
    ▼
┌─────────────────────────┐
│  pre-commit hook runs   │
│  gitleaks protect       │
└─────────────────────────┘
    │
    ├── No secrets found → Commit proceeds
    │
    └── Secrets found → Commit BLOCKED
                        Shows what was found
                        Shows file and line number
```

---

## Installation Steps (For Reference)

These steps were already completed on this Mac:

```bash
# 1. Install gitleaks
brew install gitleaks

# 2. Create global hooks directory
mkdir -p ~/.git-hooks

# 3. Create pre-commit hook (see content below)
# 4. Make executable
chmod +x ~/.git-hooks/pre-commit

# 5. Configure git to use global hooks
git config --global core.hooksPath ~/.git-hooks
```

---

## Pre-Commit Hook Content

File: `~/.git-hooks/pre-commit`

```bash
#!/bin/bash
# Global pre-commit hook - scans for secrets before allowing commit
# Installed: January 2026

# Run gitleaks on staged changes
gitleaks protect --staged --exit-code 1

if [ $? -ne 0 ]; then
    echo ""
    echo "========================================"
    echo "  COMMIT BLOCKED - Secrets detected!"
    echo "========================================"
    echo ""
    echo "Review the findings above and either:"
    echo "  1. Remove the secret from the file"
    echo "  2. Add to .gitleaksignore if false positive"
    echo ""
    echo "To bypass (use with caution):"
    echo "  git commit --no-verify"
    echo ""
    exit 1
fi
```

---

## Commands Reference

| Command | What It Does |
|---------|--------------|
| `gitleaks version` | Check installed version |
| `gitleaks detect --source .` | Scan entire repo (including history) |
| `gitleaks detect --source . -v` | Verbose scan with details |
| `gitleaks protect --staged` | Scan only staged files (what hook uses) |
| `git commit --no-verify` | Bypass hook (use carefully) |

---

## Handling False Positives

If gitleaks flags something that's NOT a secret:

1. Note the **fingerprint** from the output (long hash string)
2. Create `.gitleaksignore` in that repo
3. Add the fingerprint

Example `.gitleaksignore`:
```
# Gitleaks ignore file - false positives
# Format: fingerprint (from gitleaks output)

# "K8s+NetApp+RDS" is just text, not a secret
2742373383da85eb32a766d8fec75cb496d26790:ANALYSIS-TRACKER.md:generic-api-key:271
```

---

## If You Need to Commit a Real Secret (Rare)

**Don't.** But if absolutely necessary:

1. Use environment variables instead
2. Use 1Password CLI (`op`) to inject at runtime
3. Use `.env` files that are in `.gitignore`

If you MUST bypass:
```bash
git commit --no-verify -m "message"
```

**Warning:** This disables ALL pre-commit hooks, not just gitleaks.

---

## Verify Setup Is Working

```bash
# Check git config
git config --global core.hooksPath
# Should show: /Users/markhubers/.git-hooks

# Check hook exists and is executable
ls -la ~/.git-hooks/pre-commit
# Should show: -rwxr-xr-x

# Test scan on a repo
cd /path/to/any/repo
gitleaks detect --source . -v
```

---

## Troubleshooting

**Hook not running:**
```bash
# Check config is set
git config --global core.hooksPath

# If empty, re-run:
git config --global core.hooksPath ~/.git-hooks
```

**gitleaks command not found:**
```bash
brew install gitleaks
```

**Too many false positives:**
- Add fingerprints to `.gitleaksignore` in each repo
- Or create custom rules in `.gitleaks.toml`

---

## Custom Rules (Advanced)

Create `.gitleaks.toml` in a repo for custom patterns:

```toml
# Example: Also scan for SSN patterns
[[rules]]
id = "ssn"
description = "Social Security Number"
regex = '''\b\d{3}-\d{2}-\d{4}\b'''
tags = ["pii", "ssn"]
```

---

## Resources

- Gitleaks GitHub: https://github.com/gitleaks/gitleaks
- Default rules: https://github.com/gitleaks/gitleaks/blob/master/config/gitleaks.toml
- Config documentation: https://github.com/gitleaks/gitleaks#configuration

---

*This setup applies globally to all git repos on this Mac.*
