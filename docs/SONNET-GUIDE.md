# 🤖 Working with Claude Sonnet - Maintenance Guide

This guide explains how to use Claude Sonnet to maintain and extend this framework.

---

## 🔄 The Workflow

### Adding/Changing Tools

```
1. Edit ~/hubers-devtools/config/tools.yaml    ← Define the tool
2. Run: devsetup add <tool-name>               ← Install it
3. Git commit and push                          ← Save to repo
```

### On a New Machine

```
1. git clone <your-repo> ~/hubers-devtools     ← Get the repo
2. cd ~/hubers-devtools && ./bootstrap.sh      ← Set everything up
3. devsetup install                            ← Install all required tools
```

---

## 📋 Quick Reference: What to Paste for Each Task

### Adding a New Tool

**Paste to Sonnet:**
1. `~/hubers-devtools/config/tools.yaml` (or just the relevant category)
2. This guide (SONNET-GUIDE.md)

**Say:**
> "Add [tool-name] to my dev setup. It's installed via [brew/npm/asdf]. Here's my tools.yaml."

**After Sonnet gives you the YAML:**
```bash
# 1. Edit the file (add what Sonnet gave you)
vim ~/hubers-devtools/config/tools.yaml

# 2. Install it
devsetup add <tool-name>

# 3. Commit
cd ~/hubers-devtools
git add config/tools.yaml
git commit -m "Add <tool-name>"
git push
```

---

### Updating Tool Versions (asdf tools)

**Paste to Sonnet:**
1. The `asdf_tools` section from `tools.yaml`

**Say:**
> "Update the default_version for terraform to 1.6.0"

**After Sonnet gives you the update:**
```bash
# 1. Edit
vim ~/hubers-devtools/config/tools.yaml

# 2. Install new version
asdf install terraform 1.6.0
asdf set --home terraform 1.6.0

# 3. Commit
git add config/tools.yaml
git commit -m "Update terraform to 1.6.0"
git push
```

---

### Adding a New Shell Function

**Paste to Sonnet:**
1. The relevant `.zsh` file from `~/hubers-devtools/terminal-config/home/.zsh/`

**Say:**
> "Add a function called `docker-clean` that removes stopped containers"

**After Sonnet gives you the code:**
```bash
# 1. Edit the source file
vim ~/hubers-devtools/terminal-config/home/.zsh/some-toolkit.zsh

# 2. Copy to active location
cp ~/hubers-devtools/terminal-config/home/.zsh/some-toolkit.zsh ~/.zsh/

# 3. Reload shell
source ~/.zshrc

# 4. Commit
git add terminal-config/
git commit -m "Add docker-clean function"
git push
```

---

## 📁 File Locations

| What | Repo Location | Active Location |
|------|---------------|-----------------|
| Tool definitions | `config/tools.yaml` | Same (in repo) |
| devsetup command | `bin/devsetup` | Same (in repo) |
| Bootstrap script | `bootstrap.sh` | Same (in repo) |
| Shell config | `terminal-config/home/.zshrc` | `~/.zshrc` |
| Toolkits | `terminal-config/home/.zsh/*.zsh` | `~/.zsh/*.zsh` |
| Your favorites | N/A (personal) | `~/.zsh/my-favorites.txt` |

**Note:** Files in `terminal-config/` are the SOURCE. They get copied to `~/` and `~/.zsh/` during install.

---

## 🔧 Common Tasks

### Task 1: Add a Homebrew Tool

**Tell Sonnet:**
> Add `htop` to my tools.yaml. Process viewer, brew install, check with `htop --version`, optional.

**Sonnet provides:**
```yaml
dev_tools:
  - name: htop
    brew: htop
    description: "Interactive process viewer"
    check: "htop --version"
    required: false
```

**You do:**
```bash
vim ~/hubers-devtools/config/tools.yaml   # Add the YAML
devsetup add htop                          # Install it
git add -A && git commit -m "Add htop" && git push
```

---

### Task 2: Add an asdf Tool (version-managed)

**Tell Sonnet:**
> Add `erlang` as an asdf-managed tool.

**Sonnet provides:**
```yaml
asdf_tools:
  - name: erlang
    asdf_plugin: erlang
    description: "Erlang programming language"
    check: "erl -version"
    required: false
    default_version: "latest"
```

**You do:**
```bash
vim ~/hubers-devtools/config/tools.yaml   # Add the YAML
devsetup add erlang                        # Installs plugin + version
git add -A && git commit -m "Add erlang" && git push
```

---

### Task 3: Add a GUI App (Cask)

**Tell Sonnet:**
> Add Obsidian as a GUI app.

**Sonnet provides:**
```yaml
apps:
  - name: obsidian
    brew: obsidian
    cask: true
    description: "Knowledge base and note-taking"
    check: "test -d '/Applications/Obsidian.app'"
    required: false
```

---

### Task 4: Add Tool Requiring a Tap

**Tell Sonnet:**
> Add `gh-dash`, needs tap `dlvhdr/formulae`.

**Sonnet provides:**
```yaml
git_workflow:
  - name: gh-dash
    brew: gh-dash
    tap: "dlvhdr/formulae"
    description: "GitHub dashboard in terminal"
    check: "gh dash --help"
    required: false
```

---

### Task 5: Mark a Tool as Required

**Tell Sonnet:**
> Make k9s required instead of optional.

**Sonnet says:** Change `required: false` to `required: true` for k9s.

Then run `devsetup install` to install all required tools.

---

## 📝 tools.yaml Field Reference

```yaml
category_name:
  - name: tool-name           # Required: unique ID
    brew: formula-name        # Homebrew formula
    cask: true               # If GUI app
    tap: "owner/repo"        # If custom tap needed
    description: "text"      # Required: what it does
    check: "cmd --version"   # Required: verify install
    required: true/false     # Install by default?
    default_version: "x.y"   # For asdf tools
    asdf_plugin: plugin-name # For asdf tools
    post_install:            # Commands after install
      - "some command"
    install_manual: |        # If not via brew
      curl ... | sh
    docs: "https://..."      # Documentation URL
```

---

## 🆘 Troubleshooting with Sonnet

**Paste to Sonnet:**
1. The error message
2. The relevant file
3. What you were trying to do

**Example:**
> I ran `devsetup add foo` and got this error: [error message]. Here's my tools.yaml entry for foo. What's wrong?

---

## 📚 Key Files for Sonnet Sessions

Depending on the task, paste these:

| Task | Files to Paste |
|------|----------------|
| Add brew tool | `config/tools.yaml` (relevant section) |
| Add asdf tool | `config/tools.yaml` (asdf_tools section) |
| Add shell function | The `.zsh` toolkit file |
| Fix devsetup bug | `bin/devsetup` + error |
| Fix install bug | `bootstrap.sh` or `INSTALL.sh` + error |
| Update .zshrc | `terminal-config/home/.zshrc` (relevant section) |
