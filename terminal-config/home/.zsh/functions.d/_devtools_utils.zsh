#!/bin/zsh
# ============================================================================
# Utility Functions
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# For custom functions, create your own file without _devtools_ prefix
# ============================================================================

# ============================================================================
# Clipboard
# ============================================================================
if command -v pbcopy &> /dev/null; then
  alias clip='pbcopy'
  alias paste='pbpaste'
  alias cb='clip'
elif command -v xclip &> /dev/null; then
  alias clip='xclip -selection clipboard'
  alias paste='xclip -selection clipboard -o'
elif command -v wl-copy &> /dev/null; then
  alias clip='wl-copy'
  alias paste='wl-paste'
fi

# ============================================================================
# Network
# ============================================================================
myip() {
  echo "Your IP Addresses:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  local local_ip
  if command -v ipconfig &> /dev/null; then
    local_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
  else
    local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  fi
  echo "Local IPv4:  ${local_ip:-Not found}"
  local public_ip=$(curl -s -4 --connect-timeout 3 ifconfig.me 2>/dev/null || \
                    curl -s -4 --connect-timeout 3 icanhazip.com 2>/dev/null)
  echo "Public IPv4: ${public_ip:-Not available}"
}

alias ip4='curl -s -4 ifconfig.me; echo'
alias localip='ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1'

# ============================================================================
# Weather
# ============================================================================
weather() {
  local location="${1:-Elgin,IL}"
  curl -s "wttr.in/${location}?format=3"
  echo ""
}

weather-full() {
  local location="${1:-Elgin,IL}"
  curl -s "wttr.in/${location}"
}

# ============================================================================
# Notes
# ============================================================================
note() {
  local notes_file=~/notes.txt
  if [[ -z "$1" ]]; then
    echo "Usage: note \"Your note here\""
    return 1
  fi
  echo "[$(date '+%Y-%m-%d %H:%M')] $*" >> "$notes_file"
  echo "Note saved to $notes_file"
}

notes() {
  local notes_file=~/notes.txt
  if [[ -f "$notes_file" ]]; then
    cat "$notes_file"
  else
    echo "No notes yet. Use: note \"Your first note\""
  fi
}

alias notes-edit='${EDITOR:-vim} ~/notes.txt'

# ============================================================================
# Ports
# ============================================================================
port() {
  if [[ -z "$1" ]]; then
    echo "Usage: port <port-number>"
    return 1
  fi
  lsof -i ":$1" || echo "Port $1 is not in use"
}

killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port-number>"
    return 1
  fi
  lsof -ti ":$1" | xargs kill -9 2>/dev/null
  [[ $? -eq 0 ]] && echo "Killed processes on port $1" || echo "No processes on port $1"
}

alias ports='lsof -i -P -n | grep LISTEN'

# ============================================================================
# Search & Find (ripgrep wrappers)
# ============================================================================
# Sensible defaults: skip .git/node_modules, smart-case, colors

# search - Content search (grep replacement)
# Usage: search "pattern" [path]
search() {
  if [[ -z "$1" ]]; then
    echo "Usage: search \"pattern\" [path]"
    echo "  Search file contents using ripgrep"
    return 1
  fi
  rg --smart-case --hidden --glob '!.git' --glob '!node_modules' --glob '!*.min.*' "$@"
}

# ff - Find files containing pattern (shows filenames only)
# Usage: ff "pattern" [path]
ff() {
  if [[ -z "$1" ]]; then
    echo "Usage: ff \"pattern\" [path]"
    echo "  Find files containing pattern (filenames only)"
    return 1
  fi
  rg --smart-case --hidden --glob '!.git' --glob '!node_modules' --files-with-matches "$@"
}

# fname - Find files by name
# Usage: fname "pattern" [path]
fname() {
  if [[ -z "$1" ]]; then
    echo "Usage: fname \"pattern\" [path]"
    echo "  Find files by name (uses fd if available, falls back to find)"
    return 1
  fi
  local pattern="$1"
  local search_path="${2:-.}"
  if command -v fd &> /dev/null; then
    fd --hidden --exclude .git --exclude node_modules "$pattern" "$search_path"
  else
    find "$search_path" -name "*${pattern}*" \
      -not -path '*/.git/*' \
      -not -path '*/node_modules/*' 2>/dev/null
  fi
}

# Aliases for common search patterns
alias rgh='rg --hidden --glob "!.git"'                    # rg with hidden files
alias rgf='rg --files-with-matches'                       # rg filenames only
alias rgi='rg --ignore-case'                              # rg case insensitive
alias todo='search "TODO|FIXME|XXX|HACK"'                 # Find TODOs in code

# ============================================================================
# File Utilities
# ============================================================================
# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract any archive format
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar e "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *) echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ============================================================================
# Path
# ============================================================================
unalias path 2>/dev/null
path() {
  echo "Your \$PATH:"
  echo $PATH | tr ':' '\n' | nl
}

# ============================================================================
# HTTP Server
# ============================================================================
serve() {
  local port="${1:-8000}"
  echo "Starting HTTP server on port $port..."
  echo "Serving: $(pwd)"
  echo "Open: http://localhost:$port"
  python3 -m http.server "$port"
}

# ============================================================================
# JSON/YAML
# ============================================================================
if command -v jq &> /dev/null; then
  json() {
    if [[ -z "$1" ]]; then
      jq '.'
    else
      jq '.' "$1"
    fi
  }

  json-validate() {
    if [[ -z "$1" ]]; then
      echo "Usage: json-validate <file.json>"
      return 1
    fi
    jq empty "$1" 2>/dev/null && echo "Valid JSON" || { echo "Invalid JSON"; return 1; }
  }

  alias jpretty='jq .'
fi

if command -v yq &> /dev/null; then
  yaml() {
    if [[ -z "$1" ]]; then
      yq eval '.'
    else
      yq eval '.' "$1"
    fi
  }

  yaml-validate() {
    if [[ -z "$1" ]]; then
      echo "Usage: yaml-validate <file.yaml>"
      return 1
    fi
    yq eval '.' "$1" > /dev/null 2>&1 && echo "Valid YAML" || { echo "Invalid YAML"; return 1; }
  }
fi

# ============================================================================
# Process Management
# ============================================================================
alias psa='ps aux | sort -k 3 -r | head -20'
alias psmem='ps aux | sort -k 4 -r | head -20'

# ============================================================================
# Tool Shortcuts
# ============================================================================
if command -v code &> /dev/null; then
  alias c='code .'
  alias codehere='code .'
fi

if command -v lazygit &> /dev/null; then
  alias lg='lazygit'
fi

if command -v lazydocker &> /dev/null; then
  alias lzd='lazydocker'
fi

# ============================================================================
# Self-test
# ============================================================================
_test_devtools_utils() {
  local passed=0 failed=0
  for func in myip weather note notes port killport path serve json yaml; do
    if typeset -f "$func" > /dev/null 2>&1 || alias "$func" > /dev/null 2>&1; then
      ((passed++))
    fi
  done
  echo "Utils: $passed functions/aliases available"
  return 0
}
