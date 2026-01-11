# 📖 Vim Reference Guide - Complete Command Reference

Master Vim with this comprehensive guide covering navigation, editing, search, replace, and advanced features.

---

## 🎯 Quick Start

**Enter Vim:**
```bash
vim filename.txt      # Open file
vim +10 file.txt      # Open at line 10
vim +/pattern file    # Open at first match of pattern
```

**Modes:**
- **Normal mode** - Navigate and execute commands (press `ESC`)
- **Insert mode** - Type text (press `i`, `a`, `o`, etc.)
- **Visual mode** - Select text (press `v`, `V`, `Ctrl+v`)
- **Command mode** - Execute commands (press `:`)

---

## 🚀 Navigation

### Basic Movement

```bash
# Character movement
h                # Left
j                # Down
k                # Up
l                # Right

# Word movement
w                # Next word start
W                # Next WORD (ignores punctuation)
b                # Previous word start
B                # Previous WORD
e                # End of word
E                # End of WORD
ge               # End of previous word

# Line movement
0                # Start of line
^                # First non-blank character
$                # End of line
g_               # Last non-blank character
```

### Jump Commands

```bash
# Line jumping
gg               # Go to first line
G                # Go to last line
:123             # Go to line 123
123G             # Go to line 123
:+10             # Jump 10 lines down
:-5              # Jump 5 lines up

# Paragraph jumping
{                # Previous paragraph (blank line)
}                # Next paragraph
```

### Screen Movement

```bash
# Scrolling
Ctrl+f           # Page forward (full screen)
Ctrl+b           # Page backward (full screen)
Ctrl+d           # Half page down
Ctrl+u           # Half page up
Ctrl+e           # Scroll down one line
Ctrl+y           # Scroll up one line

# Screen positioning
zz               # Center current line on screen
zt               # Move current line to top
zb               # Move current line to bottom
H                # Move cursor to top of screen
M                # Move cursor to middle of screen
L                # Move cursor to bottom of screen
```

### Character Finding

```bash
# Find in line
f{char}          # Find next occurrence of {char}
F{char}          # Find previous occurrence
t{char}          # Move before next {char}
T{char}          # Move before previous {char}
;                # Repeat last f/F/t/T
,                # Repeat in opposite direction

# Examples
fa               # Jump to next 'a'
3fa              # Jump to 3rd 'a'
t(               # Jump just before next '('
```

### Matching Brackets/Quotes

```bash
%                # Jump to matching bracket/paren/brace
[(               # Jump to previous unmatched (
])               # Jump to next unmatched )
[{               # Jump to previous unmatched {
]}               # Jump to next unmatched }
```

---

## 🔍 Search & Find

### Basic Search

```bash
/pattern         # Search forward for pattern
?pattern         # Search backward
n                # Next match (same direction)
N                # Previous match (opposite direction)
*                # Search forward for word under cursor
#                # Search backward for word under cursor
g*               # Search forward (partial match)
g#               # Search backward (partial match)
```

### Search Options

```bash
:set hlsearch    # Highlight search results
:set incsearch   # Incremental search (search as you type)
:noh             # Clear search highlighting
:set ignorecase  # Case-insensitive search
:set smartcase   # Smart case (with ignorecase)
```

### Examples

```bash
/TODO            # Find next TODO
/\<word\>        # Find whole word only (not "sword")
/^function       # Find lines starting with "function"
/end$            # Find lines ending with "end"
/\d\+            # Find one or more digits
```

---

## 🔄 Find & Replace - Comprehensive Guide

### Basic Replace Syntax

```
:[range]s/old/new/[flags]
```

### Flags

```bash
g                # Replace all occurrences in line (global)
c                # Confirm each replacement
i                # Case insensitive
I                # Case sensitive (override ignorecase setting)
n                # Report number of matches (don't replace)
```

### Simple Replacements

```bash
# Current line
:s/old/new/           # Replace first occurrence in line
:s/old/new/g          # Replace all in current line

# Entire file
:%s/old/new/          # Replace first occurrence in each line
:%s/old/new/g         # Replace all occurrences in file
:%s/old/new/gc        # Replace all with confirmation
```

### Range Replacements

```bash
# Specific lines
:10,20s/old/new/g     # Replace in lines 10-20
:10,$s/old/new/g      # Replace from line 10 to end
:1,50s/old/new/g      # Replace in first 50 lines

# Relative ranges
:.,$s/old/new/g       # From current line to end
:.,+10s/old/new/g     # Current line + next 10 lines
:.-5,.+5s/old/new/g   # 5 lines before/after cursor
```

### Pattern-Based Replacements

```bash
# Whole words only
:%s/\<old\>/new/g     # Replace "old" but not "older"

# Case variations
:%s/\cfoo/bar/g       # Case insensitive (foo, Foo, FOO)
:%s/Foo/bar/gi        # Same as above

# Multiple words
:%s/foo\|bar/baz/g    # Replace foo OR bar with baz

# Whitespace
:%s/\s\+$//g          # Remove trailing whitespace
:%s/^\s\+//g          # Remove leading whitespace
:%s/\s\+/ /g          # Replace multiple spaces with single space
```

### Advanced Replacements

```bash
# Using capture groups
:%s/\(.*\)/"\1"/g     # Wrap each line in quotes
:%s/\(\w\+\) \(\w\+\)/\2 \1/g  # Swap first two words

# Conditional replacements
:g/pattern/s/old/new/g    # Replace only in lines matching pattern
:v/pattern/s/old/new/g    # Replace only in lines NOT matching

# Examples
:g/function/s/var/let/g   # Replace var with let only in lines with "function"
:g/TODO/s/foo/bar/g       # Replace foo with bar in TODO lines
```

### Interactive Replacements

```bash
:%s/old/new/gc

# When prompted:
# y - Replace this match
# n - Skip this match
# a - Replace this and all remaining matches
# q - Quit (stop replacing)
# l - Replace this match and quit
# ^E - Scroll up
# ^Y - Scroll down
```

### Count Matches (Don't Replace)

```bash
:%s/pattern//gn       # Count occurrences without replacing
:10,50s/TODO//gn      # Count TODOs in lines 10-50
```

### Special Characters

```bash
# Escaping
:%s/\./,/g            # Replace . with ,
:%s/\//\_/g           # Replace / with _
:%s/\*/star/g         # Replace * with "star"

# Newlines
:%s/foo/bar\r/g       # Replace with newline after
:%s/\n//g             # Join all lines (remove newlines)
:%s/foo\nbar/baz/g    # Replace across lines
```

### Real-World Examples

```bash
# Add semicolons to end of lines
:%s/$/;/g

# Remove // comments
:%s/\/\/.*$//g

# Convert snake_case to camelCase
:%s/_\(\w\)/\u\1/g

# Add quotes around words
:%s/\w\+/"&"/g

# Convert tabs to spaces (4 spaces)
:%s/\t/    /g

# Remove blank lines
:g/^$/d

# Double-quote single-quoted strings
:%s/'\([^']*\)'/"\1"/g

# Add commas between items
:%s/\(\w\+\)/\1,/g
```

---

## ✏️ Editing Commands

### Insert Mode

```bash
i                # Insert before cursor
I                # Insert at start of line
a                # Append after cursor
A                # Append at end of line
o                # Open new line below
O                # Open new line above
s                # Substitute character (delete char and insert)
S                # Substitute line (delete line and insert)
```

### Delete Commands

```bash
# Characters
x                # Delete character under cursor
X                # Delete character before cursor
dl               # Delete character (same as x)
dh               # Delete character before

# Words
dw               # Delete to start of next word
de               # Delete to end of word
db               # Delete to start of previous word
dW / dE / dB     # Same but for WORDS

# Lines
dd               # Delete entire line
D                # Delete from cursor to end of line
d$               # Same as D
d0               # Delete from cursor to start of line
dgg              # Delete from cursor to top of file
dG               # Delete from cursor to end of file

# Examples
d3w              # Delete 3 words
d5j              # Delete 5 lines down
dtx              # Delete until character 'x'
dfx              # Delete including character 'x'
```

### Change Commands

```bash
# Change (delete and enter insert mode)
cw               # Change word
cb               # Change word backward
cc               # Change entire line
C                # Change from cursor to end of line
c$               # Same as C
c0               # Change from cursor to start

# Examples
c3w              # Change 3 words
ctx              # Change until 'x'
cfx              # Change including 'x'
```

### Copy (Yank) Commands

```bash
# Yank
yw               # Yank word
yy               # Yank entire line
Y                # Yank entire line (same as yy)
y$               # Yank to end of line
y0               # Yank to start of line

# Examples
y3w              # Yank 3 words
y5j              # Yank 5 lines down
ytx              # Yank until 'x'
```

### Paste Commands

```bash
p                # Paste after cursor
P                # Paste before cursor
gp               # Paste and move cursor after
gP               # Paste before and move cursor
```

### Undo/Redo

```bash
u                # Undo
Ctrl+r           # Redo
U                # Undo all changes on line
.                # Repeat last command
```

---

## 🎨 Text Objects - The Power Feature!

Text objects let you operate on logical units of text.

### Syntax

```
{operator}{a/i}{object}

operator: d (delete), c (change), y (yank), v (visual select)
a: "a" (around - includes delimiter)
i: "i" (inner - excludes delimiter)
```

### Common Text Objects

```bash
# Words
ciw              # Change inner word
caw              # Change around word (includes surrounding space)
diw              # Delete inner word
yiw              # Yank inner word

# Quotes/Brackets
ci"              # Change inside double quotes
ci'              # Change inside single quotes
ci`              # Change inside backticks
ci(              # Change inside parentheses
ci[              # Change inside square brackets
ci{              # Change inside curly braces
ci<              # Change inside angle brackets

# Around (includes delimiters)
da"              # Delete around double quotes (includes quotes)
da(              # Delete around parentheses
da{              # Delete around braces

# Sentences and paragraphs
cis              # Change inner sentence
cas              # Change around sentence
cip              # Change inner paragraph
cap              # Change around paragraph

# Tags (HTML/XML)
cit              # Change inner tag
cat              # Change around tag (includes tags)
dit              # Delete inner tag
dat              # Delete around tag
```

### Real-World Examples

```bash
# In: The "quick" brown fox
ci"              # Changes quick (cursor anywhere in quotes)
ca"              # Changes "quick" (includes quotes)

# In: function(arg1, arg2)
ci(              # Changes arg1, arg2
ca(              # Changes (arg1, arg2)

# In: <div>Content</div>
cit              # Changes Content
cat              # Changes <div>Content</div>

# In: This is a word here
ciw              # Changes the word under cursor
caw              # Changes word and space after

# Multiple changes
ci"Hello<ESC>    # Replace text in quotes with "Hello"
di(              # Delete everything in parentheses
yit              # Yank text inside HTML tag
```

---

## 👁️ Visual Mode

```bash
# Enter visual mode
v                # Character-wise visual mode
V                # Line-wise visual mode
Ctrl+v           # Block visual mode (column selection)

# Select text then:
d                # Delete selection
y                # Yank selection
c                # Change selection
>                # Indent selection
<                # Dedent selection
=                # Auto-indent selection
u                # Lowercase selection
U                # Uppercase selection
~                # Toggle case

# Block mode examples (Ctrl+v)
Ctrl+v, select, I, type, ESC    # Insert at start of multiple lines
Ctrl+v, select, c, type, ESC    # Change block
Ctrl+v, select, d               # Delete column
```

---

## 🔢 Line Numbers & Settings

```bash
:set number          # Show line numbers (absolute)
:set nonumber        # Hide line numbers
:set relativenumber  # Show relative line numbers
:set rnu             # Short form
:set nornu           # Turn off relative numbers

# Combined (absolute + relative)
:set number relativenumber

# Toggle with function key (add to .vimrc)
nnoremap <F3> :set number! relativenumber!<CR>
```

---

## 📁 Working with Multiple Files

```bash
# Opening files
:e filename      # Edit file
:e!              # Reload current file (discard changes)
:w               # Save
:w filename      # Save as
:wq              # Save and quit
:q               # Quit
:q!              # Quit without saving
:qa              # Quit all
:wqa             # Save all and quit

# Buffers
:ls              # List all buffers
:b2              # Switch to buffer 2
:bn              # Next buffer
:bp              # Previous buffer
:bd              # Delete buffer

# Splits
:split           # Horizontal split
:vsplit          # Vertical split
Ctrl+w h/j/k/l   # Navigate between splits
Ctrl+w c         # Close split
Ctrl+w o         # Close all other splits
```

---

## 🎯 Line Operations

```bash
# Delete lines
:10,20d          # Delete lines 10-20
:g/pattern/d     # Delete all lines matching pattern
:v/pattern/d     # Delete all lines NOT matching pattern
:g/^$/d          # Delete all blank lines
:g/TODO/d        # Delete all lines with TODO

# Copy lines
:10,20y          # Yank lines 10-20
:10,20t30        # Copy lines 10-20 to line 30
:10,20co30       # Same as above

# Move lines
:10,20m30        # Move lines 10-20 to line 30

# Sort lines
:10,20sort       # Sort lines 10-20
:%sort           # Sort entire file
:%sort!          # Sort in reverse
:%sort u         # Sort and remove duplicates
```

---

## 🔧 Macros

```bash
# Record macro
q{letter}        # Start recording to register {letter}
q                # Stop recording

# Play macro
@{letter}        # Play macro from register
@@               # Replay last macro
100@{letter}     # Play macro 100 times

# Example workflow
qa               # Start recording to register 'a'
# ... perform actions ...
q                # Stop recording
@a               # Play macro
5@a              # Play macro 5 times
```

---

## 💾 Registers

```bash
# Named registers (a-z)
"ayy             # Yank line to register a
"ap              # Paste from register a

# Special registers
"0               # Last yank
"1-"9            # Last 9 deletes
""               # Unnamed register (default)
"+               # System clipboard
"*               # X11 primary selection
":               # Last command
"/               # Last search
"%               # Current filename

# View registers
:reg             # View all registers
:reg a           # View register a
```

---

## 🎨 Indentation

```bash
>>               # Indent line
<<               # Dedent line
==               # Auto-indent line
gg=G             # Auto-indent entire file

# Visual mode
>                # Indent selection
<                # Dedent selection
=                # Auto-indent selection

# Insert mode
Ctrl+t           # Indent
Ctrl+d           # Dedent

# Settings
:set tabstop=4       # Tab width
:set shiftwidth=4    # Indent width
:set expandtab       # Use spaces instead of tabs
:set autoindent      # Auto-indent new lines
```

---

## 💡 Tips & Tricks

### Repeat Commands

```bash
.                # Repeat last change
;                # Repeat last f/F/t/T
,                # Repeat in opposite direction
n                # Repeat last search
@:               # Repeat last command-line command
```

### Marks

```bash
m{letter}        # Set mark
'{letter}        # Jump to mark
''               # Jump to previous position
'.               # Jump to last change
```

### Command History

```bash
:history         # Show command history
q:               # Open command history window
```

### Help System

```bash
:help            # Open help
:help command    # Help for specific command
:help ciw        # Help for text objects
:help :substitute # Help for substitute command
```

---

## 🚀 Quick Reference

**Most Useful Commands:**
```
Navigation:  gg, G, 0, $, w, b, f{char}, %
Search:      /, n, N, *, #
Replace:     :%s/old/new/gc
Editing:     ciw, ci", di(, dw, dd, yy, p
Text Objects: ciw, ci", ci(, cit, dip
Visual:      v, V, Ctrl+v
Undo:        u, Ctrl+r, .
```

---

## 📚 Next Steps

- Practice the text objects (ciw, ci", etc.) - they're game-changers
- Master the find & replace patterns
- Learn 3-5 new commands per week
- Use `th vim` anytime to reference this guide
- Enable shell vi mode: see `th vimode`

**Pro Tip:** Start with these 10 commands and you'll be 80% more productive:
1. `ciw` - change word
2. `ci"` - change inside quotes
3. `%` - jump to matching bracket
4. `*` - search word under cursor
5. `gg` / `G` - top/bottom of file
6. `:%s/old/new/gc` - find & replace
7. `dd` - delete line
8. `.` - repeat last command
9. `u` / `Ctrl+r` - undo/redo
10. `/pattern` then `n` - search & next

Happy Vimming! 🎉
