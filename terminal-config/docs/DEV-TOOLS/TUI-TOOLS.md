# TUI Tools - Terminal User Interface Apps

Beautiful interactive terminal applications that make command-line work enjoyable.

---

## What Are TUI Apps?

TUI (Terminal User Interface) apps are interactive programs that run in your terminal with rich visual interfaces - menus, panels, colors, and mouse support.

**Already installed (core):**
- `lazygit` - Git interface
- `k9s` - Kubernetes dashboard
- `lazydocker` - Docker dashboard
- `btop` - System monitor
- `glow` - Markdown viewer
- `gum` - Interactive prompts

**Optional (install with devsetup):**
- `superfile` - File manager
- `posting` - API testing
- `lazysql` - Database browser
- `harlequin` - SQL IDE

---

## Core TUI Apps

### lazygit - Git Made Easy

```bash
lazygit        # Or just: lg

# Keyboard shortcuts:
# Space     = Stage/unstage file
# c         = Commit
# P         = Push
# p         = Pull
# ?         = Help
# q         = Quit
```

### k9s - Kubernetes Dashboard

```bash
k9s            # Or just: k9

# Keyboard shortcuts:
# :pod      = View pods
# :svc      = View services
# :deploy   = View deployments
# /         = Filter
# d         = Describe
# l         = Logs
# s         = Shell into pod
# Ctrl+d    = Delete
# ?         = Help
```

### lazydocker - Docker Dashboard

```bash
lazydocker     # Or just: lzd

# Shows:
# - Running containers
# - Images
# - Volumes
# - Networks
# - Logs in real-time
```

### btop - Beautiful System Monitor

```bash
btop           # Replaces htop/top

# Features:
# - CPU, memory, disk, network graphs
# - Process tree view
# - Mouse support
# - Customizable themes
```

### glow - Markdown Viewer

```bash
glow README.md           # View single file
glow .                   # Browse directory
glow                     # Stash (bookmark markdowns)

# Keyboard:
# j/k       = Scroll
# /         = Search
# q         = Quit
```

### gum - Interactive Prompts

```bash
# Choose from options
gum choose "Option 1" "Option 2" "Option 3"

# Multi-select
gum choose --no-limit "a" "b" "c"

# Text input
gum input --placeholder "Enter name"

# Confirmation
gum confirm "Delete file?"

# Spinner for long operations
gum spin --spinner dot --title "Loading..." -- sleep 3

# Styled output
gum style --foreground 212 --bold "Hello World"
```

---

## Optional TUI Apps

Install with: `devsetup add <tool>`

### superfile - Modern File Manager

```bash
devsetup add superfile
spf            # Launch

# Features:
# - Dual-pane file browser
# - Vim keybindings
# - File preview
# - Bulk operations
```

### posting - API Testing (like Postman)

```bash
devsetup add posting
posting        # Launch

# Features:
# - HTTP requests (GET, POST, PUT, DELETE)
# - Headers, body, auth
# - Response viewer
# - Request history
# - Collections
```

### lazysql - Database Browser

```bash
devsetup add lazysql
lazysql        # Launch

# Features:
# - Browse tables
# - Run queries
# - Edit data inline
# - Multiple connections
```

### harlequin - SQL IDE

```bash
devsetup add harlequin
harlequin      # Launch

# Features:
# - Full SQL editor
# - Syntax highlighting
# - Auto-complete
# - Results viewer
# - Multiple databases
```

---

## Charm.sh Ecosystem

Many TUI tools are built by [Charm.sh](https://charm.sh) using their Bubble Tea framework.

**Already have:**
- `glow` - Markdown viewer
- `gum` - Shell script prompts

**Optional:**
```bash
devsetup add vhs        # Record terminal to GIF
devsetup add mods       # AI in terminal
devsetup add soft-serve # Git server TUI
```

### vhs - Terminal Recorder

```bash
# Create recording script
cat > demo.tape << 'EOF'
Output demo.gif
Set FontSize 14
Set Width 800
Set Height 600

Type "echo Hello World"
Sleep 500ms
Enter
Sleep 2s
EOF

# Record it
vhs demo.tape
# Creates demo.gif
```

### mods - AI in Terminal

```bash
# Pipe command output to AI
cat error.log | mods "explain this error"

# Generate code
mods "write a bash function to parse JSON"

# Requires: OPENAI_API_KEY or ANTHROPIC_API_KEY
```

---

## Quick Install Commands

```bash
# Core TUI tools (already installed via bootstrap)
# lazygit, k9s, lazydocker, btop, glow, gum

# Optional TUI tools
devsetup add superfile    # File manager
devsetup add posting      # API testing
devsetup add lazysql      # Database browser
devsetup add harlequin    # SQL IDE
devsetup add vhs          # Terminal recorder
devsetup add mods         # AI in terminal

# Check what's installed
devsetup check | grep -i tui
```

---

## Aliases Reference

```bash
# Already configured in your .zshrc:
lg             # lazygit
k9             # k9s
lzd            # lazydocker

# Standard commands:
btop           # System monitor
glow           # Markdown viewer
gum            # Interactive prompts
spf            # superfile (if installed)
```

---

## See Also

- `th python` - Python version management
- `th docker` - Docker & Kubernetes guide
- `th git` - Git workflow
- `devsetup list` - See all available tools
