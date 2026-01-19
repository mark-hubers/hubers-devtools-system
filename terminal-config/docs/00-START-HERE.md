# 🚀 Ultimate Terminal Setup - START HERE

Welcome to your legendary terminal! This is your complete guide to everything.

---

## ⚡ Quick Start (2 Minutes)

```bash
# 1. Already installed? Try these:
fav                      # See your customizable command reference
dev-tools                # Same as 'fav'
th                       # Interactive help menu
bms                      # List your bookmarked directories

# 2. Try some shortcuts:
h                        # Search command history (Ctrl+R)
bm proj ~/Projects       # Bookmark a directory
mycd proj                # Jump to it

# 3. Customize your startup display:
favedit                  # Edit your favorites (opens in editor)
dev-tools-edit           # Same as 'favedit'

# 4. View beautiful docs (install glow first!):
brew install glow        # Makes markdown beautiful
md ~/.zsh/docs/00-START-HERE.md
# Or just type: 00-START-HERE.md

# 5. Explore:
th <TAB>                 # See all help topics
```

---

## 📚 Complete Documentation Index

### 🔧 SETUP (Get Started)
- **[INSTALLATION.md](SETUP/INSTALLATION.md)** - Complete installation guide
- **[POWERLEVEL10K.md](SETUP/POWERLEVEL10K.md)** - Configure your prompt
- **[CUSTOMIZATION.md](SETUP/CUSTOMIZATION.md)** - Add your own commands

### 🎯 DAILY-USE (Most Important!)
- **[FZF-FUZZY-FINDING.md](DAILY-USE/FZF-FUZZY-FINDING.md)** - Tab completion, Ctrl+R, file finding
- **[DIRECTORY-JUMPING.md](DAILY-USE/DIRECTORY-JUMPING.md)** - Zoxide bookmarks, never waste time finding folders
- **[COMMAND-HISTORY.md](DAILY-USE/COMMAND-HISTORY.md)** - h, Ctrl+R, search your history
- **[FILE-TOOLS.md](DAILY-USE/FILE-TOOLS.md)** - extract, mkcd, clip, serve
- **[MODERN-CLI-TOOLS.md](DAILY-USE/MODERN-CLI-TOOLS.md)** - eza, bat, ripgrep, fd

### 💻 DEV-TOOLS (Development)
- **[GIT-WORKFLOW.md](DEV-TOOLS/GIT-WORKFLOW.md)** - Git aliases, functions, workflow
- **[DOCKER-KUBERNETES.md](DEV-TOOLS/DOCKER-KUBERNETES.md)** - Docker, k8s, k9s shortcuts
- **[VSCODE-INTEGRATION.md](DEV-TOOLS/VSCODE-INTEGRATION.md)** - VSCode CLI shortcuts
- **[DEV-UTILITIES.md](DEV-TOOLS/DEV-UTILITIES.md)** - lazygit, lazydocker, httpie, tldr

### 🛠️ TOOLKITS (Power Features)
- **[GITHUB-TOOLKIT.md](TOOLKITS/GITHUB-TOOLKIT.md)** - 42 GitHub CLI commands
- **[NETWORK-TOOLKIT.md](TOOLKITS/NETWORK-TOOLKIT.md)** - 24 network debugging commands
- **[AWS-TOOLKIT.md](TOOLKITS/AWS-TOOLKIT.md)** - 10 AWS SSO commands

### 🔌 UTILITIES (Helpful Tools)
- **[FAVORITES-SYSTEM.md](UTILITIES/FAVORITES-SYSTEM.md)** - Customize startup display
- **[CLIPBOARD.md](UTILITIES/CLIPBOARD.md)** - Copy/paste from terminal
- **[NETWORK-UTILS.md](UTILITIES/NETWORK-UTILS.md)** - myip, port, killport
- **[JSON-YAML-TOOLS.md](UTILITIES/JSON-YAML-TOOLS.md)** - jq, yq shortcuts
- **[SYSTEM-MONITOR.md](UTILITIES/SYSTEM-MONITOR.md)** - Process management
- **[MARKDOWN-VIEWING.md](UTILITIES/MARKDOWN-VIEWING.md)** - Beautiful markdown with glow

### 📖 REFERENCE (Look Up Anything)
- **[ALL-COMMANDS.md](REFERENCE/ALL-COMMANDS.md)** - Complete A-Z command list
- **[CHEAT-SHEET.md](REFERENCE/CHEAT-SHEET.md)** - One-page quick reference

### 📚 COMPREHENSIVE (Deep Dive Guides)
- **[POWERLEVEL10K-SETUP-GUIDE.md](COMPREHENSIVE/POWERLEVEL10K-SETUP-GUIDE.md)** - Complete P10k setup with wizard walkthrough
- **[FZF-COMPLETE-GUIDE.md](COMPREHENSIVE/FZF-COMPLETE-GUIDE.md)** - Complete FZF guide with 90+ completions, how to add your own
- **[ZOXIDE-BOOKMARKS-GUIDE.md](COMPREHENSIVE/ZOXIDE-BOOKMARKS-GUIDE.md)** - Complete zoxide guide with real-world examples
- **[GITHUB-CLI-COMPLETE-GUIDE.md](COMPREHENSIVE/GITHUB-CLI-COMPLETE-GUIDE.md)** - Complete GitHub CLI with all 42 commands explained
- **[AWS-SSO-COMPLETE-GUIDE.md](COMPREHENSIVE/AWS-SSO-COMPLETE-GUIDE.md)** - Complete AWS SSO setup and management
- **[MODERN-TOOLS-REFERENCE.md](COMPREHENSIVE/MODERN-TOOLS-REFERENCE.md)** - Complete modern tools reference
- **[ITERM2-ACCESSIBILITY-SETTINGS.md](COMPREHENSIVE/ITERM2-ACCESSIBILITY-SETTINGS.md)** - iTerm2 settings for low vision/accessibility
- **[ITERM2-SSH-GUIDE.md](COMPREHENSIVE/ITERM2-SSH-GUIDE.md)** - SSH tunneling, port forwarding, jump hosts
- **[AI-NOTES-PROJECT-SPEC.md](COMPREHENSIVE/AI-NOTES-PROJECT-SPEC.md)** - Future AI features specification

---

## 🎯 Most Useful Commands (Start Here!)

### Directory Navigation
```bash
bm proj ~/Projects/myapp     # Bookmark important directory
bms                          # List all bookmarks
mycd proj                    # Jump to bookmarked directory
z myapp                      # Smart jump (partial match)
d                            # Show jump history
```

### Command History
```bash
h                            # Interactive history search (same as Ctrl+R)
Ctrl+R                       # Search command history
```

### Modern CLI Tools
```bash
ltr                          # List files oldest→newest (ls -ltr)
lsr                          # Real ls -ltr
catp file.txt                # Plain cat (no formatting)
grip "text" file.log         # Case-insensitive grep
```

### File Utilities
```bash
extract file.zip             # Extract any archive
mkcd new-folder              # Create directory and cd into it
clip                         # Copy to clipboard
paste                        # Paste from clipboard
serve                        # Start HTTP server (port 8000)
```

### Network
```bash
myip                         # Show local + public IPv4
port 8080                    # Check what's using port 8080
killport 8080                # Kill process on port 8080
```

### Development
```bash
gs                           # git status
ga .                         # git add .
gc -m "message"              # git commit
gp                           # git push
lg                           # lazygit (if installed)
k                            # k9s (if installed)
c                            # code . (VSCode)
```

---

## 🔧 Required Tools

### Core (Must Have)
```bash
brew install zsh
brew install fzf
brew install eza bat ripgrep fd zoxide
brew install powerlevel10k
```

### Optional (Enhanced Features)
```bash
# Development TUIs
brew install k9s              # Kubernetes TUI
brew install lazygit          # Git TUI
brew install lazydocker       # Docker TUI

# Utilities
brew install httpie           # Better curl
brew install tldr             # Quick command examples
brew install jq yq            # JSON/YAML processors
brew install btop             # Better top
```

**Check what's installed:**
```bash
th tools                      # Shows what modern tools you have
```

---

## 🆘 Help System

### Interactive Menu
```bash
th                           # Opens interactive help menu
th <TAB>                     # See all topics
```

### Quick References
```bash
tools                        # Modern CLI tools reference
bms                          # Directory bookmarks
h                            # Command history search
```

### Documentation
```bash
# All docs are in ~/.zsh/docs/
ls ~/.zsh/docs/

# Read any doc:
cat ~/.zsh/docs/DAILY-USE/FZF-FUZZY-FINDING.md
```

---

## 💡 Pro Tips

### Tip 1: Bookmark Your Important Directories (Do This First!)
```bash
cd ~/Projects/main-project
bm proj

cd ~/Documents/work
bm work

cd ~/Downloads
bm down

# Now jump instantly:
mycd proj
```

### Tip 2: Use h for Command History
```bash
h                    # Opens interactive search
# Type keywords, see matching commands, run them!
```

### Tip 3: Tab Completion Everywhere
```bash
ssh <TAB>            # Shows hosts with previews
docker ps <TAB>      # Shows containers with details
kubectl get <TAB>    # Shows resources with status
mycd <TAB>           # Shows your bookmarks
```

### Tip 4: Extract Anything
```bash
extract file.zip
extract file.tar.gz
extract file.rar
# It just works!
```

### Tip 5: Explore the Help System
```bash
th <TAB>             # See all topics
th fzf               # Learn about fuzzy finding
th git               # Git workflow guide
```

---

## 🎓 Learning Path

### Day 1: Navigation & History
1. Read: [DIRECTORY-JUMPING.md](DAILY-USE/DIRECTORY-JUMPING.md)
2. Read: [COMMAND-HISTORY.md](DAILY-USE/COMMAND-HISTORY.md)
3. Practice: Bookmark 5 directories, use `h` to search history

### Day 2: Modern Tools
1. Read: [MODERN-CLI-TOOLS.md](DAILY-USE/MODERN-CLI-TOOLS.md)
2. Practice: Use `ltr`, `catp`, `grip` instead of old commands

### Day 3: FZF Power
1. Read: [FZF-FUZZY-FINDING.md](DAILY-USE/FZF-FUZZY-FINDING.md)
2. Practice: Use Tab completion everywhere, try Ctrl+R

### Day 4: File Utilities
1. Read: [FILE-TOOLS.md](DAILY-USE/FILE-TOOLS.md)
2. Practice: Use `extract`, `mkcd`, `clip`, `serve`

### Week 2: Specialized Tools
1. Read toolkit guides (GitHub, Network, AWS)
2. Read dev tools guides (Git, Docker, VSCode)

---

## 🔍 Finding What You Need

### By Task
- "I want to jump to directories" → [DIRECTORY-JUMPING.md](DAILY-USE/DIRECTORY-JUMPING.md)
- "I want to search history" → [COMMAND-HISTORY.md](DAILY-USE/COMMAND-HISTORY.md)
- "I want better ls/cat/grep" → [MODERN-CLI-TOOLS.md](DAILY-USE/MODERN-CLI-TOOLS.md)
- "I want Git shortcuts" → [GIT-WORKFLOW.md](DEV-TOOLS/GIT-WORKFLOW.md)
- "I want to work with GitHub" → [GITHUB-TOOLKIT.md](TOOLKITS/GITHUB-TOOLKIT.md)

### By Tool
- **eza** (ls) → [MODERN-CLI-TOOLS.md](DAILY-USE/MODERN-CLI-TOOLS.md)
- **bat** (cat) → [MODERN-CLI-TOOLS.md](DAILY-USE/MODERN-CLI-TOOLS.md)
- **zoxide** (cd) → [DIRECTORY-JUMPING.md](DAILY-USE/DIRECTORY-JUMPING.md)
- **fzf** → [FZF-FUZZY-FINDING.md](DAILY-USE/FZF-FUZZY-FINDING.md)
- **k9s** → [DOCKER-KUBERNETES.md](DEV-TOOLS/DOCKER-KUBERNETES.md)
- **lazygit** → [DEV-UTILITIES.md](DEV-TOOLS/DEV-UTILITIES.md)

---

## 📊 What's Included

- ✅ **70+ Functions** (GitHub, Network, AWS toolkits)
- ✅ **90+ FZF Completions** (with previews!)
- ✅ **100+ Aliases** (Git, Docker, K8s, etc.)
- ✅ **17 Documentation Files** (this is one of them!)
- ✅ **Powerlevel10k** (perfect transient prompt)
- ✅ **Modern CLI Tools** (eza, bat, ripgrep, fd, zoxide)
- ✅ **Interactive Help System** (th command)

---

## 🚀 Next Steps

1. **Bookmark your directories:**
   ```bash
   bm proj ~/Projects/main
   bm work ~/Documents/work
   ```

2. **Try the help system:**
   ```bash
   th <TAB>
   ```

3. **Read a guide:**
   ```bash
   cat ~/.zsh/docs/DAILY-USE/DIRECTORY-JUMPING.md
   ```

4. **Enjoy your legendary terminal!** 🎉

---

**Questions? Type `th` for interactive help or explore the docs!**
