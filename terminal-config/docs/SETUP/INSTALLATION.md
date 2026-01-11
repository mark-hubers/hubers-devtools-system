# 🔧 Installation Guide

## Quick Install

```bash
# 1. Extract
unzip ULTIMATE-TERMINAL-P10K.zip
cd P10K-ULTIMATE-PACKAGE

# 2. Run installer
./INSTALL.sh

# 3. Reload shell
source ~/.zshrc

# 4. Configure Powerlevel10k
p10k configure
# Say YES to transient prompt!
```

## What Gets Installed

- ✅ `.zshrc` with 70+ functions
- ✅ 3 toolkits (GitHub, Network, AWS)
- ✅ 11 FZF preview files
- ✅ Documentation to `~/.zsh/docs/`
- ✅ Powerlevel10k prompt

## Optional Tools

```bash
# Core (must have)
brew install zsh fzf eza bat ripgrep fd zoxide powerlevel10k

# Markdown viewer (highly recommended!)
brew install glow              # Beautiful markdown in terminal ⭐

# Optional (enhanced features)
brew install k9s lazygit lazydocker httpie tldr jq yq
```

### Why Install glow?

**glow** makes all your documentation beautiful in the terminal!

Without glow:
```
# 📄 Header with markup
**bold text** with asterisks
- bullet with dash
```

With glow:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📄 Header (rendered!)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  bold text (actually bold!)
  • bullet (pretty bullet!)
```

All `th` commands will automatically use glow if installed!

## Verify Installation

```bash
# Test help system
th

# Test bookmarks
bm test ~/Downloads
bms

# Test modern tools
tools
```

See [00-START-HERE.md](../00-START-HERE.md) for complete guide.
