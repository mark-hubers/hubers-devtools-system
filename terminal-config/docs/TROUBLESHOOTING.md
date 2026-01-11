# 🔧 Troubleshooting Guide

Common issues and how to fix them.

---

## 🚨 "Command not found" Errors

### favedit: command not found

**Cause:** The favorites.zsh toolkit isn't loaded yet.

**Fix:**
```bash
# Reload your shell config:
source ~/.zshrc

# Or open a new terminal tab
```

**If still not working:**
```bash
# Check if the file exists:
ls -la ~/.zsh/favorites.zsh

# If missing, reinstall:
cd ~/hubers-devtools-system/terminal-config
./INSTALL.sh
```

---

### bm: command not found

**Cause:** The bookmarks.zsh toolkit isn't loaded.

**Fix:**
```bash
# Reload your shell:
source ~/.zshrc

# Check if file exists:
ls -la ~/.zsh/bookmarks.zsh

# If missing, reinstall:
cd ~/hubers-devtools-system/terminal-config
./INSTALL.sh
```

---

### th: command not found

**Cause:** Your .zshrc isn't loaded or the termhelp function isn't defined.

**Fix:**
```bash
# Reload:
source ~/.zshrc

# Check your .zshrc exists:
ls -la ~/.zshrc

# If missing, reinstall:
cd ~/hubers-devtools-system/terminal-config
./INSTALL.sh
```

---

## 📂 Files Not Found

### ~/.zsh/my-favorites.txt not found

**Cause:** The favorites system hasn't been initialized yet.

**Fix:**
```bash
# Open a new terminal (this triggers initialization)
# Or manually run:
fav

# This will create the file with defaults
```

---

### ~/.zsh/docs/ directory missing

**Cause:** Installation didn't complete.

**Fix:**
```bash
cd ~/hubers-devtools-system/terminal-config
./INSTALL.sh
```

---

## 🎨 Display Issues

### Favorites not showing at startup

**Check if enabled:**
```bash
ls ~/.zsh/.favorites_enabled
```

**If file doesn't exist:**
```bash
favon
```

**Then open a new terminal tab.**

---

### Changes to favorites not appearing

**After editing with `favedit`, changes show in NEW terminals.**

**To preview immediately:**
```bash
fav
```

**Or reload:**
```bash
source ~/.zshrc
```

---

### Special characters look weird

**Your terminal doesn't support Unicode.**

**Fix:**
1. Use iTerm2 on Mac (recommended)
2. Or change your terminal's font to one with Unicode support
3. Or edit `~/.zsh/favorites.zsh` and remove box-drawing characters

---

## ⚙️ Editor Issues

### Editor not working with favedit

**Check your EDITOR variable:**
```bash
echo $EDITOR
```

**If empty, set it:**
```bash
# For vim:
export EDITOR=vim

# For nano:
export EDITOR=nano

# For VSCode:
export EDITOR=code

# Make permanent (add to ~/.zshrc):
echo 'export EDITOR=vim' >> ~/.zshrc
```

---

## 🔍 Help System Issues

### th <TAB> shows nothing

**Cause:** FZF or completion system not working.

**Fix:**
```bash
# Check if fzf is installed:
which fzf

# If not:
brew install fzf

# Then reload:
source ~/.zshrc
```

---

### th favorites shows "file not found"

**Cause:** Documentation file missing.

**Fix:**
```bash
# Check if doc exists:
ls ~/.zsh/docs/UTILITIES/FAVORITES-SYSTEM.md

# If missing, reinstall:
cd ~/hubers-devtools-system/terminal-config
./INSTALL.sh
```

---

## 🔄 Installation Issues

### Installation script fails

**Common reasons:**
1. Not in the correct directory
2. Missing dependencies
3. Permission issues

**Fix:**
```bash
# Make sure you're in the right place:
cd ~/hubers-devtools-system/terminal-config

# Make script executable:
chmod +x INSTALL.sh

# Run with verbose output:
./INSTALL.sh
```

---

### Files installed but nothing works

**Cause:** Shell config not reloaded.

**Fix:**
```bash
# Reload your config:
source ~/.zshrc

# Or open a new terminal
```

---

## 🚀 Performance Issues

### Terminal slow to start

**Likely causes:**
1. Too many plugins
2. Slow network checks
3. Large history file

**Quick fix:**
```bash
# Disable startup favorites temporarily:
favoff

# Check startup time:
time zsh -i -c exit
```

**If still slow, check Oh-My-Zsh plugins.**

---

### fzf tab completion very slow

**Cause:** Preview scripts taking too long.

**Fix:**
```bash
# Disable previews temporarily:
# Edit ~/.zshrc and comment out FZF_TAB_PREVIEW exports
```

---

## 🔐 Permission Issues

### Permission denied errors

**Fix:**
```bash
# Make sure you own the files:
sudo chown -R $USER:staff ~/.zsh
sudo chown $USER:staff ~/.zshrc

# Make scripts executable:
chmod +x ~/.zsh/*.zsh
```

---

## 🧹 Clean Install

**If nothing works, do a clean reinstall:**

```bash
# 1. Backup your customizations:
cp ~/.zsh/my-favorites.txt ~/backup-favorites.txt
cp ~/.zsh-bookmarks ~/backup-bookmarks.txt
cp ~/.zshrc ~/backup-zshrc.txt

# 2. Remove old files:
rm -rf ~/.zsh
rm ~/.zshrc

# 3. Reinstall:
cd ~/hubers-devtools-system/terminal-config
./INSTALL.sh

# 4. Restore your customizations:
cp ~/backup-favorites.txt ~/.zsh/my-favorites.txt
cp ~/backup-bookmarks.txt ~/.zsh-bookmarks

# 5. Open a new terminal
```

---

## 🆘 Still Having Issues?

### Check the basics:

```bash
# 1. Are you using zsh?
echo $SHELL
# Should show: /bin/zsh or similar

# 2. Is Oh-My-Zsh installed?
ls -la ~/.oh-my-zsh

# 3. Is your .zshrc correct?
head -20 ~/.zshrc
# Should show comments about "Ultimate Developer .zshrc"

# 4. Are the toolkits installed?
ls -la ~/.zsh/*.zsh
```

### Get more help:

1. Run the installation with verbose output
2. Check the INSTALLATION.md guide
3. Review the README.md in the project

---

## 💡 Pro Tips

### Prevent issues:

1. **Backup regularly:**
   ```bash
   cp ~/.zsh/my-favorites.txt ~/.dotfiles/
   ```

2. **Test changes:**
   ```bash
   # Test in a new shell without affecting current one:
   zsh
   ```

3. **Keep it updated:**
   ```bash
   cd ~/hubers-devtools-system
   git pull
   cd terminal-config
   ./INSTALL.sh
   ```

4. **Use version control:**
   ```bash
   cd ~
   git init
   git add .zshrc .zsh/my-favorites.txt
   git commit -m "My terminal config"
   ```

---

## 📚 Related Docs

- `th` - Interactive help
- `th favorites` - Favorites system guide
- `th dirs` - Bookmarks guide
- See `~/.zsh/docs/` for all documentation

---

**Most common fix:** Just run `source ~/.zshrc` 😊
