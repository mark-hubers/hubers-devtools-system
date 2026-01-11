# ➕ Adding Tools Guide

Quick reference for adding new tools to your setup.

---

## 🚀 Quick Add (3 Steps)

### 1. Find the brew formula name
```bash
brew search <tool>
```

### 2. Add to `config/tools.yaml`
```yaml
dev_tools:  # or appropriate category
  - name: my-tool
    brew: my-tool
    description: "What it does"
    check: "my-tool --version"
```

### 3. Install it
```bash
devsetup add my-tool
```

---

## 📋 Examples by Type

### Standard Homebrew Formula

```yaml
  - name: wget
    brew: wget
    description: "Download files from the web"
    check: "wget --version"
    required: false
```

### Homebrew Cask (GUI App)

```yaml
  - name: spotify
    brew: spotify
    cask: true
    description: "Music streaming"
    check: "test -d '/Applications/Spotify.app'"
    required: false
```

### Tool Requiring a Tap

```yaml
  - name: infracost
    brew: infracost
    tap: "infracost/infracost"
    description: "Cloud cost estimates for Terraform"
    check: "infracost --version"
    required: false
```

### Tool with Post-Install Commands

```yaml
  - name: fzf
    brew: fzf
    description: "Fuzzy finder"
    check: "fzf --version"
    required: true
    post_install:
      - "$(brew --prefix)/opt/fzf/install --all"
```

### Tool Installed via Script (not brew)

```yaml
  - name: rust
    description: "Rust programming language"
    check: "rustc --version"
    install_manual: |
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    required: false
```

### Tool Installed via npm

```yaml
  - name: claude-code
    description: "Claude Code CLI"
    check: "claude --version"
    install_manual: |
      npm install -g @anthropic-ai/claude-code
    required: true
```

### Tool via asdf Version Manager

```yaml
  - name: nodejs
    asdf_plugin: nodejs
    description: "Node.js runtime"
    check: "node --version"
    install_via_asdf: true
    required: true
```

---

## 🏷 Available Categories

| Category | For | Examples |
|----------|-----|----------|
| `core` | Essential foundation | git, zsh |
| `shell` | Terminal enhancement | oh-my-zsh, p10k, fzf |
| `modern_cli` | Better CLI tools | eza, bat, ripgrep |
| `dev_tools` | Dev utilities | jq, yq, lazygit |
| `containers` | Docker/K8s | docker, kubectl, k9s |
| `iac` | Infrastructure as Code | terraform, ansible |
| `cloud` | Cloud CLIs | awscli, gcloud |
| `languages` | Programming languages | node, python, go |
| `ai_tools` | AI assistants | claude-code |
| `security` | Secrets/encryption | 1password-cli, sops |
| `apps` | GUI applications | vscode, iterm2 |
| `fonts` | Terminal fonts | nerd-fonts |

### Creating a New Category

Just add a new section:

```yaml
databases:
  - name: postgresql
    brew: postgresql@16
    description: "PostgreSQL database"
    check: "psql --version"
    required: false
    
  - name: redis
    brew: redis
    description: "In-memory data store"
    check: "redis-cli --version"
    required: false
```

---

## ✅ Check Commands

The `check` field tells devsetup how to verify a tool is installed.

### Common patterns:

```yaml
# Version command
check: "tool --version"
check: "tool -v"
check: "tool version"

# Help command (some tools don't have --version)
check: "tool --help"

# Check if command exists
check: "command -v tool"
check: "which tool"

# Check if app bundle exists (macOS GUI apps)
check: "test -d '/Applications/App Name.app'"

# Check if directory exists
check: "test -d ~/.some-tool"

# Check if file exists
check: "test -f ~/.config/tool/config"

# Multiple checks (all must pass)
check: "tool --version && test -f ~/.toolrc"
```

---

## 🔄 Workflow: Adding Your Personal Tools

### 1. List what you have installed

```bash
# See what brew has
brew list
brew list --cask

# What's in your PATH
echo $PATH | tr ':' '\n'
```

### 2. For each tool you want tracked:

**Find the brew formula:**
```bash
brew search <name>
brew info <formula>
```

**Add to tools.yaml with proper check command:**
```bash
# Test the check command first
<tool> --version
```

**Verify it works:**
```bash
devsetup search <name>
devsetup check
```

### 3. Export your list for backup

```bash
devsetup export
```

---

## 💡 Tips

### Tool has weird version output?
Some tools output to stderr or have non-standard flags:
```yaml
check: "tool --version 2>&1 | head -1"
check: "tool -V"
```

### Tool needs environment variables?
Add setup to post_install:
```yaml
post_install:
  - "echo 'export TOOL_HOME=/path' >> ~/.zshrc"
```

### Tool conflicts with another?
Document it in the description:
```yaml
description: "Alternative to tool-x (don't install both)"
```

### Making your own required list
Mark your essentials with `required: true`:
```yaml
  - name: my-must-have
    required: true  # Will be installed with 'devsetup install'
```
