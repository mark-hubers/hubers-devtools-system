# Python Version Management with asdf

Manage multiple Python versions easily with asdf. Perfect for AWS Lambda development where you need specific Python versions per project.

---

## Why asdf for Python?

| Problem | asdf Solution |
|---------|---------------|
| Different projects need different Python versions | `.tool-versions` file per project |
| Lambda requires Python 3.11, other project needs 3.12 | Auto-switches when you `cd` into folder |
| Team members have different versions | Commit `.tool-versions` to git |
| pyenv + nvm + tfenv = too many tools | One tool manages everything |

---

## Quick Start

```bash
# 1. Add Python plugin (one-time)
asdf plugin add python

# 2. See available versions
asdf list all python

# 3. Install versions you need
asdf install python 3.12.1      # Latest stable
asdf install python 3.11.7      # For AWS Lambda
asdf install python 3.10.13     # Legacy projects

# 4. Set your default
asdf set --home python 3.12.1

# 5. Verify
python --version
which python    # Shows: ~/.asdf/shims/python
```

---

## Per-Project Versions (The Magic!)

This is the killer feature - automatic version switching per project.

### Set Up a Project

```bash
# Go to your project
cd ~/repos/my-lambda-function

# Set Python version for THIS project
asdf set python 3.11.7

# This creates .tool-versions file
cat .tool-versions
# python 3.11.7
```

### How It Works

```bash
cd ~/repos/my-lambda-function
python --version
# Python 3.11.7  <-- Auto-switched!

cd ~/repos/other-project
python --version
# Python 3.12.1  <-- Back to global default

cd ~/repos/my-lambda-function
python --version
# Python 3.11.7  <-- Auto-switched again!
```

### Commit to Git!

```bash
# Add .tool-versions to your repo
git add .tool-versions
git commit -m "Pin Python 3.11.7 for Lambda compatibility"
```

Now everyone on your team gets the same Python version automatically.

---

## The .tool-versions File

This file tells asdf which versions to use. Can include multiple tools!

### Single Tool
```
python 3.11.7
```

### Multiple Tools (common for projects)
```
python 3.11.7
nodejs 18.19.0
terraform 1.5.7
```

### Where to Put It

| Location | Effect |
|----------|--------|
| `~/.tool-versions` | Global default (fallback) |
| `~/repos/myproject/.tool-versions` | Project-specific |
| Any parent directory | Inherited by subdirectories |

---

## Common Commands

### Managing Versions

```bash
# List installed versions
asdf list python

# List ALL available versions
asdf list all python

# Install specific version
asdf install python 3.11.7

# Uninstall a version
asdf uninstall python 3.10.13

# See current version
asdf current python
```

### Setting Versions

```bash
# Set global default (used everywhere unless overridden)
asdf set --home python 3.12.1

# Set for current project (creates .tool-versions)
asdf set python 3.11.7
```

> **Note:** `asdf shell` was removed in asdf 0.18.0. Use environment variables if needed.

### Useful Shortcuts

```bash
# Install latest stable
asdf install python latest

# Set global to latest
asdf set --home python latest

# Update plugin (get new version list)
asdf plugin update python

# Show where Python is installed
asdf where python 3.11.7
```

---

## AWS Lambda Python Versions

AWS Lambda supports specific Python versions. Match them exactly!

| Lambda Runtime | Python Version | Install Command |
|----------------|----------------|-----------------|
| python3.12 | 3.12.x | `asdf install python 3.12.1` |
| python3.11 | 3.11.x | `asdf install python 3.11.7` |
| python3.10 | 3.10.x | `asdf install python 3.10.13` |
| python3.9 | 3.9.x | `asdf install python 3.9.18` |

### Lambda Project Setup

```bash
# Create Lambda project
mkdir my-lambda && cd my-lambda

# Pin to Lambda's Python version
asdf set python 3.11.7

# Create requirements.txt
echo "boto3" > requirements.txt

# Create virtual environment (optional but recommended)
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Your .tool-versions ensures correct Python version
# Your .venv keeps packages isolated
```

---

## Virtual Environments

asdf handles Python versions, but you still want virtual environments for package isolation.

### Option 1: venv (Built-in, Recommended)

```bash
cd my-project

# Create venv
python -m venv .venv

# Activate
source .venv/bin/activate

# Install packages
pip install boto3 requests

# Deactivate when done
deactivate
```

### Option 2: pipx (For CLI Tools)

```bash
# Install pipx
pip install pipx

# Install CLI tools in isolation
pipx install black
pipx install flake8
pipx install awscli-local
```

### Best Practice Setup

```
my-project/
├── .tool-versions      # Python version (asdf)
├── .venv/              # Virtual environment (packages)
├── requirements.txt    # Package list
├── requirements-dev.txt # Dev dependencies
└── src/
    └── lambda_function.py
```

---

## Troubleshooting

### "python: command not found"

```bash
# Reshim after installing
asdf reshim python

# Or reload shell
source ~/.zshrc
```

### "No version set for python"

```bash
# Set a global default
asdf set --home python 3.12.1

# Or check if plugin is installed
asdf plugin list
```

### Version Not Switching

```bash
# Check what version asdf sees
asdf current

# Check for .tool-versions in parent directories
cat .tool-versions
cat ../.tool-versions

# Force reshim
asdf reshim
```

### Build Errors During Install

```bash
# macOS: Install build dependencies
xcode-select --install
brew install openssl readline sqlite3 xz zlib

# Set build flags
export LDFLAGS="-L$(brew --prefix openssl)/lib"
export CPPFLAGS="-I$(brew --prefix openssl)/include"

# Try install again
asdf install python 3.11.7
```

---

## Other Tools with asdf

asdf isn't just for Python! Your setup includes:

```bash
# See all available plugins
asdf plugin list all

# Common ones already in your tools.yaml:
asdf plugin add nodejs
asdf plugin add terraform
asdf plugin add kubectl
asdf plugin add golang
asdf plugin add ruby

# Install and use same way as Python
asdf install nodejs 18.19.0
asdf set --home nodejs 18.19.0
```

### Multi-Tool .tool-versions

```
# .tool-versions for a full-stack project
python 3.11.7
nodejs 18.19.0
terraform 1.5.7
```

---

## Quick Reference

```bash
# INSTALL
asdf plugin add python          # Add plugin
asdf install python 3.11.7      # Install version
asdf install python latest      # Install latest

# SET VERSION
asdf set --home python 3.12.1   # Set global default
asdf set python 3.11.7          # Set for project (.tool-versions)

# CHECK
asdf current                    # Show current versions
asdf list python                # Show installed versions
asdf list all python            # Show available versions

# MANAGE
asdf reshim python              # Refresh shims
asdf plugin update python       # Update version list
asdf uninstall python 3.10.13   # Remove version
```

---

## See Also

- `th terraform` - Terraform version management (also uses asdf)
- `th nodejs` - Node.js version management (also uses asdf)
- `devsetup check` - See all installed tools
