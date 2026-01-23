# 📦 Git Repository Workflow

This framework is designed to live in a Git repository. Here's how to set it up and use it.

**Your repo:** `git@github.com:mhubers/hubers-devtools-system.git`
**Recommended local path:** `~/hubers-devtools-system`

**Note:** Scripts auto-detect their location, so you can clone anywhere. The recommended path just keeps things simple.

---

## 🚀 Initial Setup (One Time)

### If You Have an Empty GitHub Repo

```bash
# 1. Set minimal git config (needed to clone)
git config --global user.name "mark-hubers"
git config --global user.email "mhubers@gmail.com"
git config --global core.sshCommand "ssh -i ~/.ssh/git_personal.pem"

# 2. Clone the empty repo
git clone git@github.com:mhubers/hubers-devtools-system.git ~/hubers-devtools-system

# 3. Unzip package contents into repo
cd ~/hubers-devtools-system
unzip ~/Downloads/mac-dev-setup.zip
mv mac-dev-setup/* .
mv mac-dev-setup/.gitignore .
rmdir mac-dev-setup

# 4. Commit and push
git add -A
git commit -m "Initial commit: hubers-devtools framework"
git push

# 5. Run bootstrap
./bootstrap.sh
```

---

## 💻 New Machine Setup

```bash
# 1. Set minimal git config (needed to clone)
git config --global user.name "mark-hubers"
git config --global user.email "mhubers@gmail.com"
git config --global core.sshCommand "ssh -i ~/.ssh/git_personal.pem"

# 2. Clone your repo
git clone git@github.com:mhubers/hubers-devtools-system.git ~/hubers-devtools-system

# 3. Run bootstrap
cd ~/hubers-devtools-system
./bootstrap.sh

# 4. Install all your tools (in new terminal)
devsetup install
```

**That's it!** Your new machine has everything.

---

## 🔧 Daily Workflow

### Adding a New Tool

```bash
# 1. Edit tools.yaml
vim ~/hubers-devtools-system/config/tools.yaml

# 2. Install the tool
devsetup add <tool-name>

# 3. Commit and push
cd ~/hubers-devtools-system
git add config/tools.yaml
git commit -m "Add <tool-name>"
git push
```

### Updating a Tool Version (asdf)

```bash
# 1. Edit tools.yaml (change default_version)
vim ~/hubers-devtools-system/config/tools.yaml

# 2. Install new version
asdf install <tool> <version>
asdf set --home <tool> <version>

# 3. Commit and push
cd ~/hubers-devtools-system
git add config/tools.yaml
git commit -m "Update <tool> to <version>"
git push
```

### Syncing Changes to Another Machine

```bash
cd ~/hubers-devtools-system
git pull

# If tools.yaml changed, install new tools:
devsetup install

# If terminal-config changed, re-run install:
cd terminal-config && ./INSTALL.sh
```

---

## 📁 Repository Structure

```
hubers-devtools-system/          ← Git repo root
├── .gitignore
├── README.md                    ← Start here
├── bootstrap.sh                 ← Run on new machines
│
├── bin/
│   └── devsetup                 ← Tool manager CLI
│
├── config/
│   └── tools.yaml               ← YOUR TOOLS - edit this!
│
├── docs/
│   ├── ADDING-TOOLS.md
│   ├── ASDF-GUIDE.md
│   ├── FAVORITES-SYSTEM.md
│   ├── GIT-WORKFLOW.md          ← This file
│   ├── MAINTENANCE.md
│   ├── MARKDOWN-TOOLKIT.md
│   ├── QUICK-REFERENCE.md
│   ├── RECOVERY.md
│   └── SONNET-GUIDE.md          ← For Claude Sonnet sessions
│
└── terminal-config/             ← Shell configuration
    ├── INSTALL.sh
    ├── home/
    │   ├── .zshrc
    │   └── .zsh/
    │       ├── bookmarks.zsh
    │       ├── favorites.zsh
    │       ├── markdown-toolkit.zsh
    │       └── ...
    └── docs/
```

---

## 🔄 What Gets Committed

**DO commit:**
- `config/tools.yaml` - Your tool definitions
- `bin/devsetup` - Only if you modify it
- `terminal-config/` - Shell config changes
- `docs/` - Documentation updates

**DON'T commit (in .gitignore):**
- `.DS_Store`
- `*.log`
- `*.backup.*`
- Editor files

**NOT in repo (personal/local):**
- `~/.zsh/my-favorites.txt` - Your personal favorites
- `~/.p10k.zsh` - Your Powerlevel10k config
- Tool installations themselves (they're installed via brew/asdf)

---

## 🌐 Multiple Machines

The beauty of this system:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Work Mac      │     │   Home Mac      │     │  Linux Server   │
│                 │     │                 │     │                 │
│  git clone      │     │  git clone      │     │  git clone      │
│  ./bootstrap.sh │     │  ./bootstrap.sh │     │  ./bootstrap.sh │
│  devsetup       │     │  devsetup       │     │  devsetup       │
│   install       │     │   install       │     │   install       │
└────────┬────────┘     └────────┬────────┘     └────────┬────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │     Git Repository      │
                    │  github.com/mhubers/    │
                    │ hubers-devtools-system  │
                    └─────────────────────────┘
```

**Add tool on Work Mac:**
```bash
# On Work Mac
vim config/tools.yaml
devsetup add newtool
git commit -am "Add newtool" && git push

# On Home Mac (later)
git pull
devsetup add newtool  # Or: devsetup install
```

---

## 💡 Tips

### Keep tools.yaml Clean
- Remove tools you don't use
- Keep descriptions accurate
- Group related tools in same category

### Use Branches for Experiments
```bash
git checkout -b try-new-tool
# Make changes, test
git checkout main  # Abandon if didn't work
# OR
git merge try-new-tool  # Keep if it worked
```

### Tag Stable Versions
```bash
git tag -a v1.0 -m "Stable setup as of Jan 2025"
git push --tags
```

### Machine-Specific Tools
If one machine needs different tools, you can:
1. Just not run `devsetup add` for that tool on that machine
2. Or create a `tools.local.yaml` (not committed) for overrides

---

## 📋 Quick Commands

```bash
# Add tool and commit
devsetup add <tool> && git add -A && git commit -m "Add <tool>" && git push

# Sync from repo
git pull && devsetup install

# See what's different from repo
git status
git diff config/tools.yaml
```
