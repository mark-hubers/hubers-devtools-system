#!/bin/zsh
# ============================================================================
# Bookmark System - PRODUCTION VERSION
#
# Main command (bm) with subcommands:
#   bm                - Interactive FZF menu
#   bm <name>         - Jump to bookmark (fuzzy match)
#   bm <name> <path>  - Save bookmark
#   bm <name> .       - Save current directory
#   bm .              - Quick save (uses folder name)
#   bm list | ls      - List bookmarks
#   bm help | -h      - Show help
#   bm stats          - Usage statistics
#   bm check          - Validate paths
#   bm edit           - Edit bookmarks file
#   bm back           - Return to previous location
#   bm prune          - Remove broken bookmarks
#
# Standalone commands:
#   bml               - List bookmarks + recent dirs from zoxide
#   bmrm <name>       - Remove bookmark
#   bmrename old new  - Rename bookmark
#   bmcode <name>     - Open in VS Code
#   bmlist            - Alias for bml
#   bmhelp            - Show help
#
# Critical notes:
#   - Never use 'path' as variable (breaks ZSH $PATH)
#   - Always use 'command' prefix to bypass aliases
# ============================================================================

# Data files
BOOKMARKS_FILE="${HOME}/.zsh/bookmarks.txt"
BOOKMARK_STACK="${HOME}/.zsh/bookmark_stack.txt"

# Initialize data files if they don't exist
[[ -f "$BOOKMARKS_FILE" ]] || command touch "$BOOKMARKS_FILE"
[[ -f "$BOOKMARK_STACK" ]] || command touch "$BOOKMARK_STACK"

# ============================================================================
# Main Command
# ============================================================================

bm() {
  # No arguments - interactive mode
  if [[ -z "$1" ]]; then
    _bm_interactive
    return $?
  fi

  # Single "." - quick save with folder name
  if [[ "$1" == "." && -z "$2" ]]; then
    local auto_name=$(basename "$(pwd)")
    _bm_save "$auto_name" "."
    return $?
  fi

  # Subcommands (when single argument matches a command)
  if [[ -z "$2" ]]; then
    case "$1" in
      list|ls)     bml; return $? ;;
      help|-h)     _bm_help; return $? ;;
      stats)       bmstats; return $? ;;
      check)       bmcheck; return $? ;;
      back)        bmback; return $? ;;
      edit)        bmedit; return $? ;;
      prune)       _bm_prune; return $? ;;
    esac
  fi

  # One argument - jump to bookmark
  if [[ -z "$2" ]]; then
    _bm_jump "$1"
    return $?
  fi

  # Two arguments - save bookmark
  _bm_save "$1" "$2"
  return $?
}

# ============================================================================
# Help
# ============================================================================

_bm_help() {
  cat << 'EOF'
📚 Bookmark System - Quick Reference

USAGE:
  bm                    Interactive FZF menu
  bm <name>             Jump to bookmark (fuzzy match)
  bm <name> <path>      Save bookmark
  bm <name> .           Save current directory
  bm .                  Quick save (uses folder name)

SUBCOMMANDS:
  bm list | ls          List all bookmarks
  bm help | -h          Show this help
  bm stats              Usage statistics
  bm check              Validate paths
  bm edit               Edit bookmarks file
  bm back               Return to previous location
  bm prune              Remove broken bookmarks

OTHER COMMANDS:
  bml                   List bookmarks + zoxide recent
  bmrm <name>           Remove bookmark
  bmrename <old> <new>  Rename bookmark
  bmcode <name>         Open in VS Code

EXAMPLES:
  bm devtools ~/my-tools/hubers-devtools-system
  bm docs .
  bm .                  # saves as current folder name
  bm dev                # fuzzy matches 'devtools'
EOF
}

# ============================================================================
# Prune - Remove broken bookmarks
# ============================================================================

_bm_prune() {
  if [[ ! -s "$BOOKMARKS_FILE" ]]; then
    echo "📚 No bookmarks to prune"
    return 0
  fi

  echo "🔍 Scanning for broken bookmarks..."
  echo ""

  local broken_names=()
  while IFS=: read -r name bookmark_path count timestamp; do
    if [[ ! -d "$bookmark_path" ]]; then
      broken_names+=("$name")
      echo "❌ $name → $bookmark_path"
    fi
  done < "$BOOKMARKS_FILE"

  if [[ ${#broken_names[@]} -eq 0 ]]; then
    echo "✅ All bookmarks valid - nothing to prune"
    return 0
  fi

  echo ""
  echo "Found ${#broken_names[@]} broken bookmark(s)"
  read -q "REPLY?Remove all broken bookmarks? (y/n) "
  echo ""

  if [[ "$REPLY" != "y" ]]; then
    echo "❌ Cancelled"
    return 1
  fi

  for name in "${broken_names[@]}"; do
    command sed -i.bak "/^${name}:/d" "$BOOKMARKS_FILE"
  done
  command rm -f "${BOOKMARKS_FILE}.bak"

  echo "✅ Removed ${#broken_names[@]} broken bookmark(s)"
}

# ============================================================================
# Save Bookmark
# ============================================================================

_bm_save() {
  local name="$1"
  local bookmark_path="$2"

  # Warn if name conflicts with a subcommand
  local reserved=(list ls help -h stats check back edit prune)
  if (( ${reserved[(I)$name]} )); then
    echo "⚠️  Warning: '$name' is a subcommand"
    echo "   You won't be able to jump with 'bm $name' (it will run the command instead)"
    echo "   Workaround: use 'bm' menu or rename later with 'bmrename $name newname'"
    echo ""
    read -q "REPLY?Continue anyway? (y/n) "
    echo ""
    [[ "$REPLY" != "y" ]] && return 1
  fi

  # Resolve path
  if [[ "$bookmark_path" == "." ]]; then
    bookmark_path="$(pwd)"
  else
    # Expand ~ to $HOME
    bookmark_path="${bookmark_path/#\~/$HOME}"
    # Resolve to absolute path
    bookmark_path="$(cd "$bookmark_path" 2>/dev/null && pwd || echo "$bookmark_path")"
  fi
  
  # Validate directory exists
  if [[ ! -d "$bookmark_path" ]]; then
    echo "❌ Directory not found: $bookmark_path"
    return 1
  fi
  
  # Check if bookmark already exists
  if command grep -q "^${name}:" "$BOOKMARKS_FILE" 2>/dev/null; then
    local old_path=$(command grep "^${name}:" "$BOOKMARKS_FILE" | command head -1 | command cut -d: -f2)
    echo "⚠️  Bookmark '$name' already exists:"
    echo "   Current: $old_path"
    echo "   New:     $bookmark_path"
    echo ""
    read -q "REPLY?   Update? (y/n) "
    echo ""
    
    if [[ "$REPLY" != "y" ]]; then
      echo "❌ Cancelled"
      return 1
    fi
    
    # Remove old entry
    command sed -i.bak "/^${name}:/d" "$BOOKMARKS_FILE"
    command rm -f "${BOOKMARKS_FILE}.bak"
  fi
  
  # Add new bookmark
  local timestamp=$(command date +%s 2>/dev/null || python3 -c "import time; print(int(time.time()))")
  echo "${name}:${bookmark_path}:0:${timestamp}" >> "$BOOKMARKS_FILE"
  
  echo "✅ Bookmarked: $name → $bookmark_path"
  echo "   Jump with: bm $name"
}

# ============================================================================
# Jump to Bookmark (with fuzzy matching)
# ============================================================================

_bm_jump() {
  local name="$1"
  
  # Try exact match first
  local bookmark=$(command grep "^${name}:" "$BOOKMARKS_FILE" 2>/dev/null | command head -1)
  
  # If no exact match, try fuzzy match (contains)
  if [[ -z "$bookmark" ]]; then
    local fuzzy_matches=$(command grep -i "${name}" "$BOOKMARKS_FILE" 2>/dev/null)
    local match_count=$(echo "$fuzzy_matches" | command grep -c ":" 2>/dev/null || echo "0")
    
    if [[ "$match_count" -eq 1 ]]; then
      # Single fuzzy match - use it
      bookmark="$fuzzy_matches"
      local matched_name=$(echo "$bookmark" | command cut -d: -f1)
      echo "🔍 Fuzzy matched: '$name' → '$matched_name'"
    elif [[ "$match_count" -gt 1 ]]; then
      # Multiple matches - show them
      echo "🔍 Multiple matches for '$name':"
      echo "$fuzzy_matches" | while IFS=: read -r n p rest; do
        echo "   • $n → $p"
      done
      echo ""
      echo "💡 Be more specific or use: bm <TAB>"
      return 1
    fi
  fi
  
  if [[ -z "$bookmark" ]]; then
    echo "❌ Bookmark '$name' not found"
    echo ""
    echo "💡 Create it with: bm $name /path/to/directory"
    echo "💡 Or save current dir: bm $name ."
    echo "💡 See all bookmarks: bml"
    return 1
  fi
  
  local bookmark_path=$(echo "$bookmark" | command cut -d: -f2)
  local matched_name=$(echo "$bookmark" | command cut -d: -f1)
  local jump_count=$(echo "$bookmark" | command cut -d: -f3)
  
  if [[ ! -d "$bookmark_path" ]]; then
    echo "❌ Path no longer exists: $bookmark_path"
    echo "💡 Remove with: bmrm $matched_name"
    return 1
  fi
  
  # Save current location for bmback
  pwd > "$BOOKMARK_STACK"
  
  # Update usage count
  local timestamp=$(command date +%s 2>/dev/null || python3 -c "import time; print(int(time.time()))")
  ((jump_count++))
  command sed -i.bak "s|^${matched_name}:.*|${matched_name}:${bookmark_path}:${jump_count}:${timestamp}|" "$BOOKMARKS_FILE"
  command rm -f "${BOOKMARKS_FILE}.bak"
  
  echo "📂 Jumping to: $bookmark_path"
  cd "$bookmark_path"
}

# ============================================================================
# Interactive FZF Menu
# ============================================================================

_bm_interactive() {
  if ! command -v fzf &> /dev/null; then
    echo "💡 Install fzf for interactive bookmark selection"
    echo ""
    bml
    return 1
  fi
  
  if [[ ! -s "$BOOKMARKS_FILE" ]]; then
    echo "📚 No bookmarks yet!"
    echo ""
    echo "💡 Create one with: bm name /path/to/directory"
    echo "💡 Or save current dir: bm name ."
    return 1
  fi
  
  local bookmarks=$(command awk -F: '{printf "%-20s → %s\n", $1, $2}' "$BOOKMARKS_FILE")
  local selection=$(echo "$bookmarks" | fzf --height=60% --prompt="📚 Bookmark> " --reverse)
  
  if [[ -z "$selection" ]]; then
    return 1
  fi
  
  local name=$(echo "$selection" | command awk '{print $1}')
  _bm_jump "$name"
}

# ============================================================================
# List Bookmarks + Recent Directories
# ============================================================================

bml() {
  echo "📚 Your Bookmarks"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if [[ ! -s "$BOOKMARKS_FILE" ]]; then
    echo ""
    echo "  (no bookmarks yet)"
    echo ""
    echo "💡 Create one with: bm name /path"
    echo "💡 Or quick save: bm .  (uses folder name)"
  else
    echo ""
    # Sort by usage count (most used first)
    command sort -t: -k3 -nr "$BOOKMARKS_FILE" | while IFS=: read -r name bookmark_path count timestamp; do
      if [[ -d "$bookmark_path" ]]; then
        printf "  %-20s → %s\n" "$name" "$bookmark_path"
        if [[ "$count" -gt 0 ]]; then
          printf "  %20s   (used %d times)\n" "" "$count"
        fi
      else
        printf "  %-20s → %s ❌ (missing)\n" "$name" "$bookmark_path"
      fi
    done
    echo ""
    echo "💡 Jump: bm <name>  |  Remove: bmrm <name>  |  Rename: bmrename <old> <new>"
  fi
  
  # Show recent directories from zoxide if available
  if command -v zoxide &> /dev/null; then
    echo ""
    echo "🕐 Recent Directories (from zoxide)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    zoxide query -l 2>/dev/null | command head -15 | while read -r dir; do
      if [[ -d "$dir" ]]; then
        printf "  %s\n" "$dir"
      fi
    done
    echo ""
    echo "💡 Jump: z <partial-path>  |  Add to bookmarks: bm name <path>"
  fi
}

# ============================================================================
# Remove Bookmark
# ============================================================================

bmrm() {
  if [[ -z "$1" ]]; then
    echo "Usage: bmrm <name>"
    return 1
  fi
  
  local name="$1"
  
  if ! command grep -q "^${name}:" "$BOOKMARKS_FILE" 2>/dev/null; then
    echo "❌ Bookmark '$name' not found"
    echo "💡 See all bookmarks: bml"
    return 1
  fi
  
  local bookmark_path=$(command grep "^${name}:" "$BOOKMARKS_FILE" | command cut -d: -f2)
  
  echo "🗑️  Remove bookmark '$name'?"
  echo "   Path: $bookmark_path"
  read -q "REPLY?   Confirm? (y/n) "
  echo ""
  
  if [[ "$REPLY" != "y" ]]; then
    echo "❌ Cancelled"
    return 1
  fi
  
  command sed -i.bak "/^${name}:/d" "$BOOKMARKS_FILE"
  command rm -f "${BOOKMARKS_FILE}.bak"
  
  echo "✅ Removed: $name"
}

# ============================================================================
# Rename Bookmark
# ============================================================================

bmrename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: bmrename <old-name> <new-name>"
    return 1
  fi
  
  local old_name="$1"
  local new_name="$2"
  
  # Check old exists
  if ! command grep -q "^${old_name}:" "$BOOKMARKS_FILE" 2>/dev/null; then
    echo "❌ Bookmark '$old_name' not found"
    return 1
  fi
  
  # Check new doesn't exist
  if command grep -q "^${new_name}:" "$BOOKMARKS_FILE" 2>/dev/null; then
    echo "❌ Bookmark '$new_name' already exists"
    return 1
  fi
  
  # Get the full line
  local bookmark_line=$(command grep "^${old_name}:" "$BOOKMARKS_FILE")
  local bookmark_path=$(echo "$bookmark_line" | command cut -d: -f2)
  local count=$(echo "$bookmark_line" | command cut -d: -f3)
  local timestamp=$(echo "$bookmark_line" | command cut -d: -f4)
  
  # Remove old, add new
  command sed -i.bak "/^${old_name}:/d" "$BOOKMARKS_FILE"
  echo "${new_name}:${bookmark_path}:${count}:${timestamp}" >> "$BOOKMARKS_FILE"
  command rm -f "${BOOKMARKS_FILE}.bak"
  
  echo "✅ Renamed: $old_name → $new_name"
}

# ============================================================================
# Edit Bookmarks File
# ============================================================================

bmedit() {
  local editor="${EDITOR:-vim}"
  
  echo "📝 Opening bookmarks in $editor..."
  echo "   Format: name:path:count:timestamp"
  echo ""
  
  $editor "$BOOKMARKS_FILE"
  
  echo "✅ Done. Run 'bml' to see changes."
}

# ============================================================================
# Check/Validate Bookmarks
# ============================================================================

bmcheck() {
  if [[ ! -s "$BOOKMARKS_FILE" ]]; then
    echo "📚 No bookmarks to check"
    return 0
  fi
  
  echo "🔍 Checking bookmark paths..."
  echo ""
  
  local broken=0 valid=0
  
  while IFS=: read -r name bookmark_path count timestamp; do
    if [[ -d "$bookmark_path" ]]; then
      echo "✅ $name → $bookmark_path"
      ((valid++))
    else
      echo "❌ $name → $bookmark_path (missing!)"
      ((broken++))
    fi
  done < "$BOOKMARKS_FILE"
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 Results: $valid valid, $broken broken"
  
  if [[ $broken -gt 0 ]]; then
    echo ""
    echo "💡 Remove broken bookmarks with: bmrm <name>"
  fi
}

# ============================================================================
# Statistics
# ============================================================================

bmstats() {
  if [[ ! -s "$BOOKMARKS_FILE" ]]; then
    echo "📚 No bookmarks yet"
    return 0
  fi
  
  echo "📊 Bookmark Statistics"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  local total=$(command wc -l < "$BOOKMARKS_FILE" | command tr -d ' ')
  local total_jumps=0
  
  # Calculate total jumps
  while IFS=: read -r name bookmark_path count timestamp; do
    ((total_jumps += count))
  done < "$BOOKMARKS_FILE"
  
  echo "📚 Total bookmarks: $total"
  echo "🚀 Total jumps: $total_jumps"
  echo ""
  
  echo "🏆 Most Used:"
  command sort -t: -k3 -nr "$BOOKMARKS_FILE" | command head -5 | while IFS=: read -r name bookmark_path count timestamp; do
    if [[ "$count" -gt 0 ]]; then
      printf "   %-20s %d jumps\n" "$name" "$count"
    fi
  done
  
  echo ""
  echo "🕐 Recently Added:"
  command sort -t: -k4 -nr "$BOOKMARKS_FILE" | command head -5 | while IFS=: read -r name bookmark_path count timestamp; do
    if [[ -n "$timestamp" ]] && [[ "$timestamp" =~ ^[0-9]+$ ]]; then
      local date_str=$(command date -r "$timestamp" "+%Y-%m-%d" 2>/dev/null || command date -d "@$timestamp" "+%Y-%m-%d" 2>/dev/null || echo "unknown")
      printf "   %-20s %s\n" "$name" "$date_str"
    else
      printf "   %-20s\n" "$name"
    fi
  done
}

# ============================================================================
# Go Back
# ============================================================================

bmback() {
  if [[ ! -s "$BOOKMARK_STACK" ]]; then
    echo "❌ No previous location saved"
    echo "💡 Use 'bm <name>' to jump somewhere first"
    return 1
  fi
  
  local prev=$(command cat "$BOOKMARK_STACK")
  
  if [[ ! -d "$prev" ]]; then
    echo "❌ Previous directory no longer exists: $prev"
    return 1
  fi
  
  echo "⬅️  Returning to: $prev"
  cd "$prev"
}

# ============================================================================
# VS Code Integration
# ============================================================================

bmcode() {
  if ! command -v code &> /dev/null; then
    echo "❌ VS Code 'code' command not found"
    echo "💡 Install VS Code and add 'code' to PATH"
    return 1
  fi
  
  if [[ -z "$1" ]]; then
    echo "Usage: bmcode <name>"
    echo "💡 Opens bookmarked directory in VS Code"
    return 1
  fi
  
  local bookmark=$(command grep "^${1}:" "$BOOKMARKS_FILE" 2>/dev/null | command head -1)
  
  if [[ -z "$bookmark" ]]; then
    echo "❌ Bookmark '$1' not found"
    echo "💡 See all bookmarks: bml"
    return 1
  fi
  
  local bookmark_path=$(echo "$bookmark" | command cut -d: -f2)
  
  if [[ ! -d "$bookmark_path" ]]; then
    echo "❌ Path no longer exists: $bookmark_path"
    return 1
  fi
  
  echo "📂 Opening in VS Code: $bookmark_path"
  code "$bookmark_path"
}

# ============================================================================
# Tab Completion
# ============================================================================

_bm_completion() {
  local -a bookmark_desc
  
  if [[ -f "$BOOKMARKS_FILE" ]] && [[ -s "$BOOKMARKS_FILE" ]]; then
    while IFS=: read -r name bookmark_path rest; do
      bookmark_desc+=("${name}:${bookmark_path}")
    done < "$BOOKMARKS_FILE"
  fi
  
  _describe 'bookmarks' bookmark_desc
  _files -/
}

compdef _bm_completion bm

_bmrm_completion() {
  local -a bookmark_desc
  
  if [[ -f "$BOOKMARKS_FILE" ]] && [[ -s "$BOOKMARKS_FILE" ]]; then
    while IFS=: read -r name bookmark_path rest; do
      bookmark_desc+=("${name}:Remove ${bookmark_path}")
    done < "$BOOKMARKS_FILE"
  fi
  
  _describe 'bookmarks to remove' bookmark_desc
}

compdef _bmrm_completion bmrm

_bmcode_completion() {
  local -a bookmark_desc
  
  if [[ -f "$BOOKMARKS_FILE" ]] && [[ -s "$BOOKMARKS_FILE" ]]; then
    while IFS=: read -r name bookmark_path rest; do
      bookmark_desc+=("${name}:Open ${bookmark_path} in VS Code")
    done < "$BOOKMARKS_FILE"
  fi
  
  _describe 'bookmarks' bookmark_desc
}

compdef _bmcode_completion bmcode

_bmrename_completion() {
  local -a bookmark_desc
  
  if [[ -f "$BOOKMARKS_FILE" ]] && [[ -s "$BOOKMARKS_FILE" ]]; then
    while IFS=: read -r name bookmark_path rest; do
      bookmark_desc+=("${name}:Rename ${name}")
    done < "$BOOKMARKS_FILE"
  fi
  
  _describe 'bookmarks' bookmark_desc
}

compdef _bmrename_completion bmrename

# ============================================================================
# Convenience Aliases
# ============================================================================

alias bookmarks='bml'
alias bookmark='bm'
alias bmlist='bml'
alias bmhelp='_bm_help'

# ============================================================================
# Init Guard (prevent double-loading)
# ============================================================================

if [[ -z "$_BOOKMARKS_LOADED" ]]; then
  export _BOOKMARKS_LOADED=1
fi
