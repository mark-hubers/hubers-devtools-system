# 🆘 Recovery Guide

How to fix problems and undo bad installations.

---

## 🔥 Quick Fixes

### "devsetup: command not found"

```bash
# Add to PATH manually
export PATH="$HOME/hubers-devtools/bin:$PATH"

# Make it permanent
echo 'export PATH="$HOME/hubers-devtools/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### "asdf: no such file or directory" Error

The .zshrc tries to load asdf but it's not installed:

```bash
# Option 1: Install asdf
brew install asdf

# Option 2: Comment out the line (if you don't want asdf)
# The new version already checks if asdf exists, but if you have old .zshrc:
sed -i '' 's|^\. .*/asdf|# &|' ~/.zshrc
source ~/.zshrc
```

### Shell Looks Broken / No Prompt

```bash
# Reset to basic prompt temporarily
export PS1="%~ $ "

# Check if .zshrc has errors
zsh -n ~/.zshrc

# If errors, restore backup
ls ~/.zshrc.backup.*           # Find backups
cp ~/.zshrc.backup.XXXXX ~/.zshrc
source ~/.zshrc
```

### Powerlevel10k Not Loading

```bash
# Check if installed
ls /opt/homebrew/share/powerlevel10k/  # Mac Apple Silicon
ls /usr/local/share/powerlevel10k/     # Mac Intel
ls ~/powerlevel10k/                     # Manual install

# If not found, install it
brew install powerlevel10k

# Then ensure .zshrc sources it (should be automatic)
```

---

## 🔄 Re-Running Bootstrap Safely

The bootstrap script is **safe to run multiple times**:

```bash
cd ~/hubers-devtools
./bootstrap.sh
```

It will:
- Skip things already installed
- Backup existing files before overwriting
- Only add PATH entries if not already there

---

## 🗑️ Complete Uninstall

If you want to remove everything and start fresh:

### 1. Remove Framework

```bash
rm -rf ~/hubers-devtools
```

### 2. Remove Shell Config

```bash
# Restore your old .zshrc (if you have backup)
ls ~/.zshrc.backup.*
cp ~/.zshrc.backup.XXXXXXXX ~/.zshrc

# Or create minimal .zshrc
cat > ~/.zshrc << 'EOF'
# Minimal .zshrc
export PATH="/opt/homebrew/bin:$PATH"
EOF
```

### 3. Remove Toolkit Files

```bash
rm -rf ~/.zsh/
```

### 4. Clean PATH

Edit `~/.zshrc` and remove these lines if present:
```bash
# Remove these lines:
export PATH="$HOME/hubers-devtools/bin:$PATH"
# Hubers Dev Tools
```

### 5. Optional: Remove Installed Tools

```bash
# See what brew installed
brew list

# Remove specific tools
brew uninstall <tool>

# Nuclear option: remove all brew packages (CAREFUL!)
# brew list | xargs brew uninstall
```

---

## 📁 Restore From Git

If your local files are messed up but Git repo is fine:

```bash
# Discard all local changes
cd ~/hubers-devtools-system
git checkout -- .
git clean -fd

# Or re-clone completely
rm -rf ~/hubers-devtools-system
git clone git@github.com:mhubers/hubers-devtools-system.git ~/hubers-devtools-system
cd ~/hubers-devtools-system
./bootstrap.sh
```

---

## 🐛 Debugging

### Check What's Loaded

```bash
# See current PATH
echo $PATH | tr ':' '\n'

# See what zsh is loading
zsh -x 2>&1 | head -100

# Check for syntax errors
zsh -n ~/.zshrc
```

### Check Tool Status

```bash
# What does devsetup think is installed?
devsetup check

# What does brew have?
brew list
brew list --cask

# What asdf plugins?
asdf plugin list
asdf current
```

### Verbose Bootstrap

```bash
# Run bootstrap with debug output
bash -x ./bootstrap.sh 2>&1 | tee bootstrap.log
```

---

## 🔧 Common Problems

### Problem: Tool Won't Install

```bash
# Check the entry in tools.yaml
devsetup search <tool>

# Try installing manually
brew install <tool>        # If it's a brew tool
brew install --cask <tool> # If it's a cask

# Check brew for errors
brew doctor
```

### Problem: asdf Plugin Won't Install

```bash
# List available plugins
asdf plugin list all | grep <name>

# Add manually
asdf plugin add <name>

# If that fails, use explicit URL
asdf plugin add <name> https://github.com/asdf-community/asdf-<name>.git
```

### Problem: Wrong Tool Version

```bash
# See what versions are installed
asdf list <tool>

# See what's set
asdf current <tool>

# Fix it
asdf set --home <tool> <correct-version>

# Or for current directory only
asdf set <tool> <correct-version>
```

### Problem: Favorites Not Showing

```bash
# Check if file exists
cat ~/.zsh/my-favorites.txt

# Check if favorites.zsh is loaded
grep favorites ~/.zshrc

# Re-enable
favon
source ~/.zshrc
```

### Problem: iTerm2 Integration Warning

This is just informational, not an error:

```bash
# Install it (optional)
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh

# Or suppress the message by creating empty file
touch ~/.iterm2_shell_integration.zsh
```

---

## 🆘 Nuclear Options

### Reset Shell to Defaults

```bash
# Backup current
cp ~/.zshrc ~/.zshrc.broken

# Create minimal working config
cat > ~/.zshrc << 'EOF'
# Minimal zshrc
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
autoload -Uz compinit && compinit
PS1="%~ %# "
EOF

source ~/.zshrc
```

### Start Completely Fresh

```bash
# Remove everything
rm -rf ~/hubers-devtools
rm -rf ~/.zsh
rm ~/.zshrc

# Re-clone and install
git clone git@github.com:YOU/hubers-devtools.git ~/hubers-devtools
cd ~/hubers-devtools
./bootstrap.sh
```

---

## 📞 Getting Help

### From Sonnet

Paste to Claude Sonnet:
1. The error message
2. The relevant file (tools.yaml, .zshrc, etc.)
3. What you were trying to do

### Check the Docs

```bash
ls ~/hubers-devtools/docs/
cat ~/hubers-devtools/docs/MAINTENANCE.md
```

### Check Logs

```bash
cat ~/.config/mac-dev-setup/install.log
```
