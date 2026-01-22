# Search & Find Tools

Smart wrappers around `ripgrep` and `fd` with sensible defaults.

## TL;DR

| Command | Purpose | Example |
|---------|---------|---------|
| `search` | Content search (grep replacement) | `search "TODO"` |
| `ff` | Find files containing pattern | `ff "import"` |
| `fname` | Find files by name | `fname "*.ts"` |
| `todo` | Find TODO/FIXME/HACK comments | `todo` |

All commands skip `.git/`, `node_modules/`, and minified files automatically.

---

## search - Content Search

Search inside files (like grep, but better).

```bash
# Basic search
search "function"              # Find "function" in all files
search "TODO"                  # Find TODOs
search "error" src/            # Search only in src/

# Case variations (smart-case: case-insensitive unless you use caps)
search "error"                 # Matches error, Error, ERROR
search "Error"                 # Matches only Error (has capital)

# With context
search -C 3 "function"         # Show 3 lines before/after
search -A 5 "import"           # Show 5 lines after match

# File type filtering
search -t py "def "            # Search only Python files
search -t js "function"        # Search only JavaScript files
search -t md "TODO"            # Search only Markdown files

# Regex patterns
search "log\.(info|error)"     # Find log.info or log.error
search "^import"               # Lines starting with import
search "TODO.*fix"             # TODO followed by fix
```

---

## ff - Find Files Containing Pattern

Like `search` but shows only filenames, not content.

```bash
# Which files contain this pattern?
ff "import React"              # Files that import React
ff "TODO"                      # Files with TODOs
ff "class User"                # Files defining User class

# Useful for getting a list to process
ff "deprecated" | wc -l        # Count files with deprecated code
ff "console.log" | xargs code  # Open all files with console.log in VS Code
```

---

## fname - Find Files by Name

Find files by their name (not content).

```bash
# Basic name search
fname "config"                 # Files with "config" in name
fname "test"                   # All test files
fname ".env"                   # Find .env files

# Glob patterns (uses fd if installed)
fname "*.ts"                   # All TypeScript files
fname "*.test.js"              # All JS test files
fname "Dockerfile"             # Find Dockerfiles

# In specific directory
fname "*.md" docs/             # Markdown files in docs/
fname "index" src/             # Index files in src/
```

---

## todo - Find Code Comments

Quick alias to find TODO, FIXME, XXX, HACK comments.

```bash
todo                           # Find all in current directory
todo src/                      # Find in src/ only
```

---

## Raw ripgrep (rg) Commands

When you need more control:

```bash
# Basic ripgrep
rg "pattern"                   # Search (default excludes .git)
rg -i "pattern"                # Case insensitive
rg -l "pattern"                # List matching files only
rg -c "pattern"                # Count matches per file

# File type filters
rg -t py "import"              # Python files only
rg -t js -t ts "function"      # JS and TS files
rg --type-list                 # See all file types

# Include/exclude
rg --hidden "pattern"          # Include hidden files
rg -g "*.log" "error"          # Only .log files
rg -g "!*.min.js" "function"   # Exclude minified JS

# Context
rg -C 2 "pattern"              # 2 lines before and after
rg -B 3 "pattern"              # 3 lines before
rg -A 3 "pattern"              # 3 lines after

# Output formats
rg --json "pattern"            # JSON output
rg --vimgrep "pattern"         # Vim-friendly output
```

---

## Tips

**Combine with other tools:**
```bash
# Open all matching files
search "FIXME" | cut -d: -f1 | sort -u | xargs code

# Count occurrences
search "console.log" | wc -l

# Find and replace prep
ff "oldFunction" | xargs sed -i '' 's/oldFunction/newFunction/g'
```

**Use in scripts:**
```bash
# Check for debug code before commit
if search -q "console.log" src/; then
  echo "Warning: console.log found!"
fi
```

---

## Installation

These tools require `ripgrep`. For `fname`, `fd` is optional but faster.

```bash
brew install ripgrep fd
```

---

*Run `th search` or `fav search` to see quick reference*
