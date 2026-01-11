# 🚀 Powerlevel10k Setup Guide

## Why Powerlevel10k?

**Transient Prompt Works Perfectly!** No fighting with broken implementations.

### Features You'll Love:
- ✅ **Transient Prompt** - Old prompts compress to `❯` (ACTUALLY WORKS!)
- ✅ **Instant Prompt** - Terminal loads immediately, no lag
- ✅ **Interactive Configuration** - Beautiful `p10k configure` wizard
- ✅ **Fast** - Written in C, optimized for speed
- ✅ **Customizable** - Hundreds of options via wizard
- ✅ **Git Status** - Fast, detailed, beautiful
- ✅ **256+ Themes** - Via configuration wizard

---

## 📦 Installation

### Option 1: Homebrew (Recommended for macOS)
```bash
brew install powerlevel10k
```

### Option 2: Manual Install
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
```

### Option 3: Oh-My-Zsh Plugin
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc
```

---

## 🎨 First-Time Configuration

After installation, the configuration wizard will run automatically:

```bash
# Or run manually:
p10k configure
```

### The Wizard Will Ask:

1. **Diamond icons?** → Yes (if you have a Nerd Font)
2. **Lock icon?** → Yes
3. **Debian icon?** → Yes  
4. **Prompt style?** → Rainbow, Lean, Classic, or Pure (your choice!)
5. **Character set?** → Unicode
6. **Show current time?** → 24-hour or 12-hour
7. **Prompt separators?** → Angled, Vertical, Slanted, Round
8. **Prompt heads?** → Sharp, Blurred, Slanted, Round
9. **Prompt tails?** → Flat, Blurred, Sharp, Slanted, Round
10. **Prompt height?** → One line or Two lines
11. **Prompt connection?** → Disconnected, Dotted, Solid
12. **Prompt frame?** → No frame, Left, Right, Full
13. **Connection & frame color?** → Lightest, Light, Dark, Darkest
14. **Prompt spacing?** → Compact, Sparse
15. **Icons?** → Many icons, Few icons, No icons
16. **Prompt flow?** → Concise, Fluent
17. **Enable transient prompt?** → **YES!** ✅
18. **Instant prompt mode?** → Verbose, Quiet, Off (choose Quiet)

**My Recommendations:**
- **Style:** Lean or Rainbow
- **Separators:** Angled (clean look)
- **Transient prompt:** **YES** (this is what you want!)
- **Instant prompt:** Quiet (fast startup)

---

## ⚙️ Configuration File

After configuration, settings are saved to `~/.p10k.zsh`

### Customize Later:
```bash
# Re-run configuration wizard
p10k configure

# Or edit config directly
nano ~/.p10k.zsh

# Changes take effect immediately
source ~/.p10k.zsh
```

---

## 🎯 Key Features

### Transient Prompt
**This is why we switched!**

Shows full prompt while typing:
```
~/Projects/myapp main ⇡1 !1 +2 ?3 ❯
```

After command execution, old prompts compress to:
```
❯ echo "test"
test
❯ ls
file1.txt file2.txt
~/Projects/myapp main ⇡1 !1 +2 ?3 ❯ _
```

**It just works!** No configuration needed beyond saying "yes" in the wizard.

### Instant Prompt
Terminal opens immediately, loads config in background. No more waiting!

### Git Status
Shows detailed git information:
- `main` - current branch
- `⇡1` - 1 commit ahead
- `⇣2` - 2 commits behind  
- `!1` - 1 modified file
- `+2` - 2 staged files
- `?3` - 3 untracked files

All color-coded and fast!

---

## 🔧 Common Customizations

### Show/Hide Elements

Edit `~/.p10k.zsh` and find the `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS` array:

```bash
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  os_icon                 # OS icon
  dir                     # Current directory
  vcs                     # Git status
  prompt_char             # Prompt character (❯)
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status                  # Exit code
  command_execution_time  # How long command took
  background_jobs         # Background jobs
  time                    # Current time
)
```

### Change Colors

```bash
# In ~/.p10k.zsh
typeset -g POWERLEVEL9K_DIR_BACKGROUND=4      # Blue
typeset -g POWERLEVEL9K_DIR_FOREGROUND=0      # Black
```

### Change Icons

```bash
# In ~/.p10k.zsh
typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='⚡'
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
```

---

## 📊 Comparison: P10k vs Starship

| Feature | Powerlevel10k | Starship |
|---------|--------------|----------|
| **Transient Prompt** | ✅ Works perfectly | ❌ Broken in zsh |
| **Speed** | ⚡ Instant | ⚡ Very fast |
| **Configuration** | 🎨 Interactive wizard | 📝 TOML file |
| **Customization** | 🔧 Hundreds of options | 🔧 Many modules |
| **Shell Support** | Zsh only | All shells |
| **Git Status** | ✅ Detailed & fast | ✅ Good |
| **Setup Time** | 2 minutes (wizard) | 10+ minutes (config) |

---

## 🚀 Quick Start After Installation

```bash
# 1. Install (if not done)
brew install powerlevel10k

# 2. Our .zshrc already configured to use it!
source ~/.zshrc

# 3. Run configuration wizard (if it doesn't auto-run)
p10k configure

# 4. Choose your preferences
# IMPORTANT: Say YES to transient prompt!

# 5. Done! Enjoy your perfect terminal
echo "test1"
echo "test2"
# Old prompts show only ❯
```

---

## 🆘 Troubleshooting

### P10k not loading?
```bash
# Check if installed
brew list powerlevel10k

# Check if sourced in .zshrc
grep "powerlevel10k" ~/.zshrc

# Try manual path
ls /opt/homebrew/share/powerlevel10k/
```

### Icons not showing?
Install a Nerd Font:
```bash
brew tap homebrew/cask-fonts
brew install font-meslo-lg-nerd-font

# Set in Terminal preferences:
# iTerm2: Preferences → Profiles → Text → Font → MesloLGS NF
# Terminal.app: Preferences → Profiles → Font → MesloLGS NF
```

### Transient prompt not working?
```bash
# Check your config
grep "POWERLEVEL9K_TRANSIENT_PROMPT" ~/.p10k.zsh

# Should be:
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always

# If not, re-run wizard:
p10k configure
# Say YES to transient prompt
```

### Want to change settings?
```bash
# Re-run wizard (non-destructive, can exit anytime)
p10k configure

# Or edit directly
code ~/.p10k.zsh

# Apply changes
source ~/.p10k.zsh
```

---

## 💡 Pro Tips

### Tip 1: Keep It Simple
Start with default settings from wizard. You can customize later.

### Tip 2: Use Transient Prompt
This is THE killer feature. Old prompts compress to `❯` and save screen space.

### Tip 3: Try Different Styles
Run `p10k configure` multiple times to try different looks. It's fun!

### Tip 4: Instant Prompt = Fast
Choose "Quiet" instant prompt mode for fastest terminal startup.

### Tip 5: Update Regularly
```bash
brew upgrade powerlevel10k
```

---

## 🎯 Recommended Settings

My personal recommendations for the wizard:

```
Diamond icons: YES
Prompt style: Lean (or Rainbow if you want colorful)
Show current time: 24-hour
Separators: Angled  
Heads: Sharp
Tails: Flat
Height: One line
Spacing: Compact
Icons: Many icons
Flow: Concise
Transient prompt: YES ✅
Instant prompt: Quiet ✅
```

This gives you a clean, fast, functional prompt with transient support.

---

## 📚 More Info

- **Official Docs:** https://github.com/romkatv/powerlevel10k
- **Configuration Reference:** `~/.p10k.zsh` (heavily commented)
- **Show Segments:** `p10k segment` - See available segments
- **Debug:** `p10k debug` - Troubleshooting info

---

## ✅ Summary

Powerlevel10k is the BEST choice if you want:
- ✅ Transient prompts that actually work
- ✅ Fast, instant terminal startup
- ✅ Easy configuration via wizard
- ✅ Beautiful, customizable prompt

**Your terminal will be perfect after running `p10k configure` once!** 🎉
