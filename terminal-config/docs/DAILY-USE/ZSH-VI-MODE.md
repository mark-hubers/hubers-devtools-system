# ⌨️ Shell Vi Mode - Vim Keybindings at Your Command Prompt

Use Vim keybindings to edit commands at your shell prompt! This guide shows you how to navigate, edit, and search your command history like a pro.

---

## 🎯 What Is Vi Mode?

Vi mode lets you use Vim keybindings to edit commands in your shell. Instead of using arrow keys and basic editing, you get the full power of Vim's navigation and editing commands.

**Vi mode is ENABLED BY DEFAULT in this terminal setup!**

---

## 🚀 Quick Start

### The Two Modes

**Insert Mode** (default when you open terminal):
- Type normally
- Everything works like a regular shell
- Press `ESC` to switch to Normal mode

**Normal Mode** (press `ESC`):
- Use Vim keybindings to navigate and edit
- Press `i` to go back to Insert mode

### Basic Workflow

```bash
# 1. Type a command (you're in Insert mode)
$ echo "hello world"

# 2. Press ESC (enter Normal mode)
# 3. Use Vim commands (w, b, cw, etc.)
# 4. Press 'i' when done (back to Insert mode)
# 5. Press Enter to execute
```

---

## ⚡ Essential Commands

### Getting Started (Most Useful First!)

```bash
ESC              # Enter Normal mode from anywhere
i                # Enter Insert mode at cursor
A                # Insert at end of line
I                # Insert at beginning of line
a                # Insert after cursor

# Try this workflow:
# Type: echo hello world
# Press ESC
# Press: A (jumps to end)
# Type: " more text"
# Press Enter
```

---

## 🚀 Navigation in Normal Mode

### Character & Word Movement

```bash
h                # Left one character
l                # Right one character
w                # Forward to next word start
b                # Backward to previous word start
e                # Forward to next word end
W / B / E        # Same but treat punctuation as word

# Examples:
# Command: git commit -m "message"
#          ^
# Press: w  →  moves to "commit"
# Press: w  →  moves to "-m"
# Press: w  →  moves to "message"
# Press: b  →  moves back to "-m"
```

### Line Movement

```bash
0                # Jump to start of line
^                # Jump to first non-space character
$                # Jump to end of line

# Example:
# Command:     echo "test"
#          ^
# Press: 0  →  jumps to very beginning
# Press: ^  →  jumps to 'e' in echo
# Press: $  →  jumps to end (after ")
```

### Find in Line

```bash
f{char}          # Find next {char} in line
F{char}          # Find previous {char}
t{char}          # Jump before next {char}
T{char}          # Jump before previous {char}
;                # Repeat last f/F/t/T
,                # Repeat in opposite direction

# Example:
# Command: echo "hello world"
#          ^
# Press: fw  →  jumps to 'w' in world
# Press: f"  →  jumps to closing "
# Press: ;   →  would find next " (none here)
```

---

## ✏️ Editing in Normal Mode

### Delete Commands

```bash
x                # Delete character under cursor
X                # Delete character before cursor
dw               # Delete word
db               # Delete word backward
d$               # Delete to end of line
d0               # Delete to beginning of line
dd               # Delete entire line (clears prompt)

# Examples:
# Command: echo hello world
#               ^
# Press: dw  →  Result: echo world
# 
# Command: git commit -m "wrong message"
#                          ^
# Press: d$  →  Result: git commit -m "
```

### Change Commands

```bash
cw               # Change word (delete and insert)
cb               # Change word backward
c$               # Change to end of line
C                # Same as c$
cc               # Change entire line

# Examples:
# Command: echo hello world
#               ^
# Press: cw  →  Deletes "hello", enters insert mode
# Type: goodbye
# Result: echo goodbye world
```

### Replace

```bash
r{char}          # Replace character under cursor with {char}
R                # Enter replace mode (overwrite)

# Example:
# Command: echo hello
#               ^
# Press: rH  →  Result: echo Hello
```

### Insert Variations

```bash
i                # Insert at cursor
I                # Insert at beginning of line
a                # Append after cursor
A                # Append at end of line
o                # Open new line below (not useful in shell)
O                # Open new line above (not useful in shell)

# Most useful for shell:
A                # Jump to end and start typing
I                # Jump to start and start typing
```

---

## 🔍 History Search (Super Useful!)

### Search Backward in History

```bash
# In Normal mode (after ESC):
/text            # Search backward for "text"
?text            # Search forward (less common)
n                # Next match (same direction)
N                # Previous match (opposite direction)

# Example workflow:
# 1. Press ESC
# 2. Type: /docker
# 3. Press Enter → finds last command with "docker"
# 4. Press: n → finds next older match
# 5. Press Enter to execute command
```

### Quick History Access

```bash
k                # Previous command in history
j                # Next command in history
G                # Go to oldest command
gg               # Go to newest command

# Still works everywhere:
Ctrl+R           # Reverse search (always available)
```

---

## 🎨 Advanced Editing

### Visual Selection

```bash
v                # Enter visual mode
# Move cursor to select text
d                # Delete selection
y                # Yank (copy) selection
c                # Change selection
```

### Yank & Paste

```bash
yw               # Yank word
yy               # Yank entire line
y$               # Yank to end of line
p                # Paste after cursor
P                # Paste before cursor

# Example:
# Command: echo hello world
#               ^
# Press: yw  →  Yanks "hello"
# Press: $   →  Jump to end
# Press: P   →  Result: echo hello world hello
```

### Undo/Redo

```bash
u                # Undo last change
Ctrl+r           # Redo
.                # Repeat last command (limited in shell)
```

---

## 🎯 Text Objects (Advanced but Powerful!)

```bash
ciw              # Change inner word
caw              # Change around word
diw              # Delete inner word
ci"              # Change inside quotes
ci'              # Change inside single quotes
ci(              # Change inside parentheses

# Examples:
# Command: echo "hello world"
#                     ^
# Press: ci"  →  Deletes text in quotes, enters insert mode
#
# Command: git commit -m "message"
#                          ^
# Press: ci"  →  Changes just "message" part
```

---

## ⚙️ Configuration & Toggles

### Check if Vi Mode is Active

```bash
# Your prompt shows [NORMAL] in yellow when in Normal mode
# If you don't see this, vi mode might be disabled
```

### Toggle Vi Mode On/Off

```bash
vimode           # Enable vi mode
emacsmode        # Disable vi mode (back to default)

# Vi mode is enabled by default in this setup!
```

### Alternative to ESC

```bash
# Type 'jk' quickly instead of pressing ESC
# (This is configured in your .zshrc)

# Example:
# Type: echo hello
# Type: jk (quickly)  →  Enters Normal mode
# Much faster than reaching for ESC!
```

---

## 💡 Common Workflows

### Workflow 1: Fix Typo at Start

```bash
# You typed: ehco hello world
#                ^
# Press: ESC
# Press: 0 (jump to start)
# Press: fc (find 'c')
# Press: xp (delete 'c' and paste after)
# Result: echo hello world
# Press: i (back to insert mode)
```

### Workflow 2: Change a Word

```bash
# You typed: git commit -m "wrong message"
#                             ^
# Press: ESC
# Press: cw (change word)
# Type: correct
# Press: ESC
# Result: git commit -m "correct message"
```

### Workflow 3: Delete to End

```bash
# You typed: npm install package1 package2 package3
#                                 ^
# Press: ESC
# Press: f2 (find '2')
# Press: d$ (delete to end)
# Result: npm install package1 package
# Press: A (append at end)
# Type: 2
```

### Workflow 4: Search & Execute

```bash
# Press: ESC
# Type: /docker
# Press: Enter → finds "docker ps -a"
# Press: cw → change first word
# Type: container
# Result: container ps -a
# Press: Enter to execute
```

### Workflow 5: Repeat Previous Command with Modification

```bash
# Previous command: git add file1.txt
# Press: ESC
# Press: k (previous command)
# Press: cw (at "add")
# Type: commit
# Press: ESC, $, a (append at end)
# Type:  -m "message"
# Result: git commit file1.txt -m "message"
```

---

## 🎓 Learning Path

### Week 1: The Essentials
Learn these 5 commands first:
1. `ESC` - Enter Normal mode
2. `i` - Back to Insert mode
3. `A` - Jump to end and insert
4. `cw` - Change word
5. `dd` - Delete line

### Week 2: Navigation
Add these to your toolbelt:
1. `w` / `b` - Word movement
2. `0` / `$` - Line start/end
3. `f{char}` - Find character
4. `/text` - Search history
5. `n` - Next search match

### Week 3: Advanced Editing
Master these power moves:
1. `ciw` - Change inner word
2. `ci"` - Change inside quotes
3. `d$` - Delete to end
4. `yw` - Yank word
5. `p` - Paste

---

## 🔥 Pro Tips

### Tip 1: Use 'jk' Instead of ESC
```bash
# Configured in your .zshrc:
# Type 'jk' quickly → enters Normal mode
# Much faster than ESC key!
```

### Tip 2: Ctrl+R Always Works
```bash
# Even in vi mode, Ctrl+R still works for reverse search
# Use it when you forget the exact command
Ctrl+R → type part of command → Enter
```

### Tip 3: Visual Indicator
```bash
# Watch your prompt!
# When in Normal mode: [NORMAL] appears in yellow
# No indicator = Insert mode (normal typing)
```

### Tip 4: Practice on Long Commands
```bash
# Vi mode shines with long commands
# Example: docker commands, git commands with many args
docker run -d --name mycontainer --network mynet --env KEY=value image:tag
# Use: w, b, cw, d$, etc. to edit efficiently
```

### Tip 5: Combine with Shell Features
```bash
# Tab completion still works in Insert mode
# History expansion (!! , !$) still works
# Ctrl+C still cancels command
```

---

## 🚫 What Doesn't Work

These Vim features don't apply to shell:
- `o` / `O` (new lines) - shell is single-line
- `:w` / `:q` - no files to save/quit
- Multiple windows/splits
- Most `:` commands

---

## 📋 Quick Reference Card

### Mode Switching
```
i, a, A, I     → Insert mode
ESC or jk      → Normal mode
```

### Navigation (Normal mode)
```
h, l           ← → (left, right)
w, b           word forward/back
0, $           start/end of line
f{char}        find character
/text          search history
```

### Editing (Normal mode)
```
x              delete character
dw, db         delete word
d$             delete to end
cw             change word
ciw            change inner word
ci"            change inside quotes
```

### History (Normal mode)
```
k, j           previous/next command
/text          search backward
n, N           next/previous match
```

### Always Available
```
Ctrl+R         reverse search
Ctrl+C         cancel
Tab            completion
Enter          execute
```

---

## 🆘 Troubleshooting

### "I'm stuck in Normal mode!"
```bash
# Just press: i
# You're back in Insert mode
```

### "Commands aren't working!"
```bash
# Make sure you pressed ESC first
# Check for [NORMAL] indicator
# If not there, press ESC again
```

### "I want to disable vi mode"
```bash
emacsmode      # Switches back to default shell editing
vimode         # Re-enables it
```

### "ESC is too far away!"
```bash
# Use 'jk' instead - it's configured!
# Type j and k quickly together
# Much more comfortable for touch typists
```

---

## 🎯 Challenge Yourself

Try editing these commands using only vi mode:

```bash
# Challenge 1: Change "world" to "universe"
echo "hello world"
# Solution: ESC, fw, cw, type "universe", ESC

# Challenge 2: Delete everything after "install"
npm install package1 package2 package3
# Solution: ESC, fin, $, d0

# Challenge 3: Swap first two words
git commit -m "message"
# Solution: ESC, w, dw, 0, P
```

---

## 📚 Related Docs

- `th vim` - Complete Vim reference
- `fav` - Your command favorites (includes vi mode commands)
- Full Vim docs: `:help` inside Vim

---

## 🎉 Final Thoughts

Vi mode makes shell editing **dramatically faster** once you get used to it. The learning curve is real, but worth it!

**Start small:**
1. Use `ESC` + `A` to jump to end
2. Use `ESC` + `cw` to fix words
3. Use `ESC` + `/text` to search history

Within a week, it'll feel natural. Within a month, you won't want to go back!

**Remember:** You can always type `emacsmode` if you need a break. Vi mode will be here when you're ready! 🚀
