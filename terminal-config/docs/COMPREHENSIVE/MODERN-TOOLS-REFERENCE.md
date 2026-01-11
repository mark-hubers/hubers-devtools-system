# 🚀 Modern CLI Tools Reference Card

Quick lookup for command replacements in your terminal setup.

---

## 📋 Quick Commands

Type these in your terminal:

```bash
modern          # Show complete reference
th              # Help menu (includes modern)
moderntools     # Same as modern
```

---

## 🔄 Command Replacements

### File Listing: `eza` replaces `ls`

| Old Command | New Command | Description |
|------------|-------------|-------------|
| `ls` | `ls` | List files (with icons!) |
| `ls -la` | `ll` | Long list with all details |
| `ls -ltr` | `ltr` ✨ | Oldest files first |
| `ls -a` | `la` | Show hidden files |
| `tree` | `lt` | Tree view (2 levels) |

**What eza adds:**
- 🎨 Icons for file types
- 📊 Git status indicators  
- 🌈 Better colors
- ⚡ Faster performance

**Need original?** Use `/bin/ls -la`

---

### File Viewing: `bat` replaces `cat`

| Old Command | New Command | Description |
|------------|-------------|-------------|
| `cat file.txt` | `cat file.txt` | View with syntax highlighting |
| `cat file.txt` | `rawcat file.txt` ✨ | Original cat, no formatting |
| `cat file.txt` | `plaincat file.txt` ✨ | bat without line numbers |

**What bat adds:**
- 🎨 Syntax highlighting for 100+ languages
- 🔢 Line numbers
- 📊 Git diff integration
- 📄 Automatic paging for long files

**For piping:** Use `rawcat` or `/bin/cat`

**Example:**
```bash
cat script.py           # Beautiful syntax highlighted view
rawcat script.py        # Plain text, no formatting
plaincat script.py      # bat without line numbers
```

---

### Directory Navigation: `zoxide` (smart cd)

| Old Command | New Command | Description |
|------------|-------------|-------------|
| `cd ~/long/path/to/project` | `z project` | Smart jump |
| `cd -` | `z -` | Previous directory |
| (none) | `zi` | Interactive picker |
| (none) | `d` ✨ | Show directory history |

**How zoxide works:**
- Learns your most-visited directories
- Jump using ANY part of the path
- Gets smarter as you use it

**Examples:**
```bash
z down        # Jumps to ~/Downloads
z proj        # Jumps to ~/Projects/myproject
z doc         # Jumps to ~/Documents
zi            # Pick from list interactively
d             # Show your jump history
```

**Note:** Regular `cd` still works normally!

---

### File Searching: `fd` replaces `find`

| Old Command | New Command |
|------------|-------------|
| `find . -name "*.txt"` | `fd txt` |
| `find . -type f -name "*.js"` | `fd -e js` |
| `find . -name "test*"` | `fd "^test"` |

**What fd adds:**
- ⚡ Much faster
- 🎯 Simpler syntax
- 🚫 Respects .gitignore
- 🎨 Colored output

---

### Text Searching: `ripgrep` (rg)

| Old Command | New Command |
|------------|-------------|
| `grep -r "text" .` | `rg text` |
| `grep -i "pattern" file` | `rg -i pattern file` |
| `grep -A 3 "text" file` | `rg -A 3 text file` |

**What ripgrep adds:**
- ⚡ 10-100x faster
- 🚫 Respects .gitignore
- 🎨 Colored output
- 📊 Better formatting

---

### Git Diffs: `delta` enhances `git diff`

Automatically enabled! No command changes needed.

```bash
git diff              # Now shows side-by-side with colors
git log -p            # Beautiful commit diffs
```

**What delta adds:**
- 📊 Side-by-side diffs
- 🎨 Syntax highlighting in diffs
- 🔍 Better line highlighting
- 📝 Improved readability

---

## 📚 Cheat Sheets

### eza Quick Reference

```bash
# Basic
ls              # List with icons
ll              # Long detailed list
ltr             # Oldest first (like ls -ltr) ✨
la              # Show hidden files
lt              # Tree view
l               # Long list, human readable

# Advanced
eza --sort modified      # Sort by modification time
eza --sort oldest        # Oldest first
eza --sort size          # Sort by size
eza --tree --level=3     # Tree view, 3 levels
eza --git-ignore         # Hide gitignored files
```

### bat Quick Reference

```bash
# Basic
cat file        # View with formatting
rawcat file     # Original cat ✨
plaincat file   # bat without line numbers ✨

# Advanced
bat -l python file.txt   # Force Python syntax
bat --style=plain        # No decorations
bat -p file.txt          # Plain (for piping)
bat -A file.txt          # Show all characters
bat --theme=list         # List available themes
```

### zoxide Quick Reference

```bash
# Basic
z myproject     # Jump to matching directory
zi              # Interactive picker
d               # Show history ✨
z -             # Previous directory

# Advanced
z foo bar       # Jump to dir matching both
zoxide query    # Show what would be jumped to
zoxide remove   # Remove directory from database
```

---

## 🔧 Customization

### Change bat Theme

```bash
# Edit ~/.zshrc, find:
export BAT_THEME="Catppuccin Mocha"

# Change to:
export BAT_THEME="GitHub"  # or Nord, Dracula, etc.

# See available themes:
bat --theme=list
```

### Disable Modern Tools

If you want original commands back:

```bash
# Edit ~/.zshrc and comment out:
# alias cat='bat --style=auto'

# Or use:
alias cat='/bin/cat'

# Then reload:
source ~/.zshrc
```

---

## 💡 Pro Tips

### 1. Use ltr Instead of ls -ltr
```bash
ltr            # Oldest files first (your new favorite!) ✨
```

### 2. Use rawcat for Piping
```bash
rawcat file.txt | grep pattern    # Works perfectly
cat file.txt | grep pattern       # Might have formatting issues
```

### 3. Let zoxide Learn
```bash
# Just cd around normally for a few days
cd ~/Projects/myapp
cd ~/Documents/reports

# Then use z:
z myapp        # Jumps right there!
z reports      # Jumps right there!
```

### 4. Use d to See Where You've Been
```bash
d              # Shows your directory history
# Pick from the list or use z with the index
```

### 5. Original Commands Still Available
```bash
/bin/ls -la          # Original ls
/bin/cat file.txt    # Original cat
/usr/bin/find        # Original find
```

---

## 🆘 Troubleshooting

### Icons Not Showing?
Install a Nerd Font:
```bash
brew tap homebrew/cask-fonts
brew install font-meslo-lg-nerd-font
```
Then set in Terminal preferences.

### bat Theme Issues?
```bash
bat --theme=list           # See available themes
export BAT_THEME="GitHub"  # Change theme
```

### zoxide Not Working?
```bash
# Check if installed
command -v zoxide

# Reinstall if needed
brew install zoxide
```

---

## 📖 More Info

- **eza:** https://github.com/eza-community/eza
- **bat:** https://github.com/sharkdp/bat  
- **zoxide:** https://github.com/ajeetdsouza/zoxide
- **fd:** https://github.com/sharkdp/fd
- **ripgrep:** https://github.com/BurntSushi/ripgrep
- **delta:** https://github.com/dandavison/delta

---

**Type `modern` in your terminal anytime to see the reference!** ✨
