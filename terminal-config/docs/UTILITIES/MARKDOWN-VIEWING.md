# 📄 Markdown Viewing with glow

Beautiful markdown in your terminal!

## Quick Start

```bash
# Install glow
brew install glow

# View any markdown file
mdview README.md
md README.md           # md is alias for mdview
glow README.md

# Magic: Just type the filename!
README.md              # Opens in glow automatically! ✨
```

## Commands

```bash
mdview <file>          # View markdown (uses glow or cat)
md <file>              # Alias for mdview
markdown <file>        # Alias for mdview
glow <file>            # Direct glow command

# Just type filename
README.md              # Auto-opens in glow!
CHANGELOG.md           # Auto-opens in glow!
```

## How It Works

### With glow installed:
- `th` commands show beautiful formatted docs
- `mdview file.md` or `md file.md` shows formatted markdown
- Just typing `file.md` opens in glow
- All headers, bold, bullets render properly

### Without glow:
- Everything falls back to `less` or `cat`
- Still works, just shows raw markdown
- Install glow anytime: `brew install glow`

## Examples

### View Documentation
```bash
# Quick reference
th cheat              # Beautiful formatted output!

# Comprehensive guide
mdview ~/.zsh/docs/COMPREHENSIVE/FZF-COMPLETE-GUIDE.md
# or just:
md ~/.zsh/docs/COMPREHENSIVE/FZF-COMPLETE-GUIDE.md

# Just type filename
cd ~/.zsh/docs
FZF-COMPLETE-GUIDE.md
```

### Navigate in glow
```bash
# Open a file
mdview README.md

# Navigate:
↓ or j                # Scroll down
↑ or k                # Scroll up
Space                 # Page down
b                     # Page up
g                     # Go to top
G                     # Go to bottom
q                     # Quit

# Mouse scrolling works too!
```

### View Any Project README
```bash
cd ~/Projects/myproject
README.md             # Just type it! Opens in glow
```

## Raw Markdown When Needed

Sometimes you need raw markdown (for piping, scripts):

```bash
# Raw markdown
cat README.md

# Pipe to grep
cat README.md | grep "installation"

# Edit in vim
vim README.md
```

## glow Features

### Beautiful Formatting
- ✅ Rendered headers (not just # symbols)
- ✅ Bold/italic/code formatting
- ✅ Proper bullet points
- ✅ Syntax-highlighted code blocks
- ✅ Tables rendered nicely
- ✅ Links shown but not clickable

### Dark/Light Theme
```bash
# glow auto-detects your terminal theme
# Dark terminal → dark theme
# Light terminal → light theme
```

### Word Wrapping
- Content wraps to your terminal width
- No horizontal scrolling needed

## Comparison

### Raw markdown (cat):
```
# Header
**bold** text
- bullet 1
- bullet 2
[link](url)
```

### Formatted (glow):
```
━━━━━━━━━━━━━━━━━━━━━
  Header
━━━━━━━━━━━━━━━━━━━━━
  bold text
  • bullet 1
  • bullet 2
  link (url)
```

## Tips

### Tip 1: View Documentation Anywhere
```bash
# Your setup
th <TAB>              # All docs use glow
th cheat              # Beautiful!

# Any project
cd ~/Projects/anyproject
README.md             # Instant beautiful view
```

### Tip 2: Compare with Raw
```bash
# Formatted
mdview file.md
md file.md

# Raw
cat file.md
```

### Tip 3: Quick Help
```bash
mdview                # Shows usage + status
md                    # Shows usage + status
```

### Tip 4: Works Everywhere
```bash
# GitHub repos
cd ~/Projects/some-repo
README.md             # Just works!

# Your notes
cd ~/Documents/notes
notes.md              # Beautiful!

# Any .md file
cd /any/directory
*.md<TAB>             # Tab complete and view
```

## Installation Check

```bash
# Check if glow is installed
command -v glow
# If installed: /opt/homebrew/bin/glow
# If not: (empty)

# Install if needed
brew install glow

# Verify
glow --version
```

## Troubleshooting

### glow not found
```bash
# Install
brew install glow

# Reload shell
source ~/.zshrc

# Try again
mdview README.md
md README.md
```

### Colors look wrong
```bash
# glow auto-detects terminal theme
# Try switching your terminal's theme
# Or use plain less:
cat file.md | less
```

### Prefer less?
```bash
# Temporarily use less
cat file.md | less

# Disable auto-open
# Edit ~/.zshrc and comment out:
# alias -s md='glow'
```

## Integration with th

All `th` commands automatically use glow:

```bash
th cheat              # Beautiful!
th fzf                # Beautiful!
th git                # Beautiful!
th all                # Beautiful!

# Without glow: falls back to less
# Nothing breaks!
```

## See Also

- [00-START-HERE.md](../00-START-HERE.md) - Main documentation
- [INSTALLATION.md](../SETUP/INSTALLATION.md) - Setup guide

---

**Install glow for beautiful docs!**
```bash
brew install glow
```
