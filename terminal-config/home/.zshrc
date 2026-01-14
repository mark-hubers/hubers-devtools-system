# ============================================================================
# Ultimate Developer .zshrc - Custom for Your Setup
# December 2025 - With SCP/rsync helpers + iTerm2 integration
# ============================================================================

# ============================================================================
# Completion System — MUST LOAD BEFORE OH-MY-ZSH
# ============================================================================

# Add custom completions to fpath
fpath=("$HOME/.zsh" $fpath)

# Ensure completion system is initialized early and only once
autoload -Uz compinit
compinit

# Prevent any previously injected dynamic function from shadowing static completion
unset -f _kubectl 2>/dev/null
unset -f _microk8s_kubectl_completion 2>/dev/null

# Disable kubectl dynamic completion
export KUBECTL_ENABLE_DYNAMIC_COMPLETION=false

# Source the static completion so it's registered with compinit
source "$HOME/.zsh/_kubectl_static"

# ============================================================================
# Oh-My-Zsh Core Setup
# ============================================================================
export ZSH="$HOME/.oh-my-zsh"

# No theme - Starship handles the prompt now
ZSH_THEME=""

CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
HIST_STAMPS="mm/dd/yyyy"

plugins=(
  git
  terraform
  asdf
  docker
  kubectl
  helm
  npm
  node
  python
  rust
  golang
  fzf
  fzf-tab
  zsh-autosuggestions
  fast-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Unalias commands that oh-my-zsh adds which can break scripts
# (e.g., grep --color --exclude-dir breaks 'grep -q' in functions)
unalias grep 2>/dev/null
unalias cat 2>/dev/null
unalias ls 2>/dev/null  
unalias find 2>/dev/null

# ============================================================================
# Homebrew Environment
# ============================================================================
eval "$(/opt/homebrew/bin/brew shellenv)"

# ============================================================================
# PATH Configuration
# ============================================================================

# VSCode CLI (if installed)
if [ -d "/Applications/Visual Studio Code.app" ]; then
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

# User's personal bin directory
if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

# Claude Code CLI (installed via: curl -fsSL https://claude.ai/install.sh | sh)
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Auto-detect Hubers Dev Tools framework location
# Checks common locations in order of preference
for possible_location in \
  "$HOME/my-tools/hubers-devtools-system" \
  "$HOME/hubers-devtools-system" \
  "$HOME/Projects/hubers-devtools-system" \
  "$HOME/repos/hubers-devtools-system" \
  "$HOME/mac-dev-setup" \
  "$HOME/Projects/mac-dev-setup"; do
  
  if [ -f "$possible_location/bin/devsetup" ]; then
    export PATH="$possible_location/bin:$PATH"
    export HUBERS_DEVTOOLS_HOME="$possible_location"
    break
  fi
done

# ============================================================================
# Modern CLI Tools Configuration
# ============================================================================

# eza (modern ls) - ENHANCED VERSION
if command -v eza &> /dev/null; then
  # Your original ll alias behavior, but with eza power
  alias ls='eza --icons --git'
  alias ll='eza --icons --git -lah --sort=modified --reverse'
  alias dir='eza --icons --git -lah --sort=modified --reverse'
  alias la='eza --icons --git -a'
  alias lt='eza --icons --git --tree --level=2'
  alias l='eza --icons --git -lh'
  alias ltr='eza --icons --git -la --sort modified'  # Like 'ls -ltr' (oldest first, newest last)
  
  # Original ls behavior (for when you need the real thing)
  alias lsr='/bin/ls -ltr'           # Real ls -ltr ✨
  alias llr='/bin/ls -la'            # Real ls -la ✨
else
  # Fallback to your original aliases if eza not installed yet
  alias ll='ls -latro'
  alias dir='ls -latro'
  alias ltr='ls -ltr'
  alias lsr='ls -ltr'
  alias llr='ls -la'
fi

# bat (modern cat with syntax highlighting)
if command -v bat &> /dev/null; then
  alias cat='bat --style=auto'
  alias rawcat='/bin/cat'           # Original cat without formatting
  alias plaincat='bat --plain'      # bat without line numbers
  alias catp='/bin/cat'              # cat plain (original cat) ✨
  export BAT_THEME="Catppuccin Mocha"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
else
  alias catp='/bin/cat'
fi

# ripgrep (modern grep)
if command -v rg &> /dev/null; then
  alias rgrep="rg"
  alias greps='rg -i'                    # Case-insensitive search (search string)
  alias grepi='rg -i'                    # Case-insensitive (grep insensitive)
  alias grip='rg -i'                     # Easy to remember: grep case-insensitive
else
  # Fallback to grep with case-insensitive
  alias greps='grep -i'
  alias grepi='grep -i'
  alias grip='grep -i'
fi

# fd (modern find)
if command -v fd &> /dev/null; then
  alias find='fd'
fi

# zoxide (smart cd that learns your habits)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  # Note: NOT aliasing cd to z - use 'z' explicitly for smart jumping
  
  # Bookmarks system for frequently used directories
  # Add your favorite directories here and use 'mycd <TAB>' to jump to them
  
  # Bookmark system moved to ~/.zsh/bookmarks.zsh
  # Commands: bm, bml, bmrm, bmcheck, bmstats, bmback, bmcode
  
  # Interactive history search with fzf
  alias h='history -100 | fzf --tac --no-sort | sed "s/^ *[0-9]* *//"'
fi


# delta (beautiful git diffs)
if command -v delta &> /dev/null; then
  export GIT_PAGER='delta'
  
  git config --global core.pager 'delta'
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global delta.navigate true
  git config --global delta.light false
  git config --global delta.side-by-side true
  git config --global delta.line-numbers true
  git config --global merge.conflictstyle diff3
  git config --global diff.colorMoved default
fi

# ============================================================================
# Vi Mode Configuration (Vim keybindings at shell prompt)
# ============================================================================
# Press ESC for normal mode, then use vim keybindings!
# Examples: w/b (word forward/back), 0/$ (start/end), ciw (change word)

# Enable Vi mode by default
bindkey -v

# Reduce ESC delay for faster mode switching (10ms instead of 400ms)
export KEYTIMEOUT=1

# Visual indicator: Show [NORMAL] in right prompt when in normal mode
function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [NORMAL]%{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# Better history search in vi mode (Ctrl+R always works)
bindkey '^R' history-incremental-search-backward

# Additional useful bindings for vi mode
bindkey -M viins 'jk' vi-cmd-mode  # Alternative to ESC: type 'jk' quickly
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Toggle functions for vi/emacs mode
vimode() {
    bindkey -v
    echo "✅ Vi mode enabled (ESC for normal mode, 'i' for insert mode)"
    echo "💡 Tip: Press ESC then try: w, b, 0, $, ciw, dw, /, n"
}

emacsmode() {
    bindkey -e
    echo "✅ Emacs mode enabled (default shell keybindings)"
    echo "💡 Vi mode is great - try it! Run: vimode"
}

# ============================================================================
# UTILITY FUNCTIONS - Clipboard, Network, Dev Tools, etc.
# ============================================================================

# Clipboard functions (copy/paste from terminal)
if command -v pbcopy &> /dev/null; then
  # macOS
  alias clip='pbcopy'
  alias paste='pbpaste'
  alias cb='clip'     # Shortcut for clipboard
elif command -v xclip &> /dev/null; then
  # Linux with xclip
  alias clip='xclip -selection clipboard'
  alias paste='xclip -selection clipboard -o'
elif command -v wl-copy &> /dev/null; then
  # Wayland
  alias clip='wl-copy'
  alias paste='wl-paste'
fi

# Enhanced myip - shows both local and public IPv4
unalias myip 2>/dev/null  # Clear any existing alias before function definition
myip() {
  echo "🌐 Your IP Addresses:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Local IPv4
  if command -v ipconfig &> /dev/null; then
    # macOS
    local_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
  else
    # Linux
    local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  fi
  echo "Local IPv4:  ${local_ip:-Not found}"
  
  # Public IPv4 (try multiple sources for reliability, force IPv4)
  local public_ip=$(curl -s -4 --connect-timeout 3 ifconfig.me 2>/dev/null || \
                    curl -s -4 --connect-timeout 3 icanhazip.com 2>/dev/null || \
                    curl -s -4 --connect-timeout 3 api.ipify.org 2>/dev/null)
  echo "Public IPv4: ${public_ip:-Not available}"
}

# Quick aliases for just one IP
alias ip4='curl -s -4 ifconfig.me; echo'      # Just public IPv4
alias localip='ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1'

# Weather command
weather() {
  local location="${1:-Elgin,IL}"
  # Simpler format for better readability
  curl -s "wttr.in/${location}?format=3"
  echo ""
  echo "💡 For detailed forecast: weather-full"
}

weather-full() {
  local location="${1:-Elgin,IL}"
  curl -s "wttr.in/${location}"
}

# Quick notes system
note() {
  local notes_file=~/notes.txt
  if [[ -z "$1" ]]; then
    echo "Usage: note \"Your note here\""
    return 1
  fi
  echo "[$(date '+%Y-%m-%d %H:%M')] $*" >> "$notes_file"
  echo "✅ Note saved to $notes_file"
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

# Port checker and killer
port() {
  if [[ -z "$1" ]]; then
    echo "Usage: port <port-number>"
    echo "Example: port 8080"
    return 1
  fi
  
  echo "🔍 Checking port $1..."
  lsof -i ":$1" || echo "Port $1 is not in use"
}

killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port-number>"
    echo "Example: killport 8080"
    return 1
  fi
  
  echo "💀 Killing processes on port $1..."
  lsof -ti ":$1" | xargs kill -9 2>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "✅ Killed processes on port $1"
  else
    echo "❌ No processes found on port $1"
  fi
}

# Path explorer - show PATH one per line
path() {
  echo "📂 Your \$PATH:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo $PATH | tr ':' '\n' | nl
}

# HTTP server
serve() {
  local port="${1:-8000}"
  echo "🌐 Starting HTTP server on port $port..."
  echo "📂 Serving: $(pwd)"
  echo "🔗 Open: http://localhost:$port"
  echo ""
  python3 -m http.server "$port"
}

# JSON pretty print and validate
if command -v jq &> /dev/null; then
  json() {
    if [[ -z "$1" ]]; then
      # Read from stdin
      jq '.'
    else
      # Read from file
      jq '.' "$1"
    fi
  }
  
  json-validate() {
    if [[ -z "$1" ]]; then
      echo "Usage: json-validate <file.json>"
      return 1
    fi
    
    if jq empty "$1" 2>/dev/null; then
      echo "✅ Valid JSON"
    else
      echo "❌ Invalid JSON"
      return 1
    fi
  }
  
  alias jpretty='jq .'
fi

# Process management shortcuts
alias psa='ps aux | sort -k 3 -r | head -20'        # Top 20 by CPU
alias psmem='ps aux | sort -k 4 -r | head -20'      # Top 20 by memory

# Git extras
git-undo() {
  git reset --soft HEAD~1
  echo "✅ Undid last commit (changes kept)"
}

git-wip() {
  git add -A
  git commit -m "WIP: $(date '+%Y-%m-%d %H:%M')"
  echo "✅ Saved work in progress"
}

git-cleanup() {
  echo "🧹 Cleaning up merged branches..."
  git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | xargs -n 1 git branch -d
  echo "✅ Done!"
}

# k9s shortcuts (Kubernetes TUI)
if command -v k9s &> /dev/null; then
  alias k='k9s'
  alias k9='k9s'
fi

# VSCode shortcuts
if command -v code &> /dev/null; then
  alias c='code .'
  alias codehere='code .'
  alias codediff='code --diff'
fi

# lazygit shortcuts
if command -v lazygit &> /dev/null; then
  alias lg='lazygit'
  alias lazg='lazygit'
fi

# lazydocker shortcuts
if command -v lazydocker &> /dev/null; then
  alias lzd='lazydocker'
  alias lazd='lazydocker'
fi

# tldr shortcuts (simplified man pages)
if command -v tldr &> /dev/null; then
  alias help='tldr'
  alias man='tldr'  # Override man for simpler examples
  alias realman='command man'  # Keep real man available
fi

# httpie shortcuts (better curl)
if command -v http &> /dev/null; then
  alias GET='http GET'
  alias POST='http POST'
  alias PUT='http PUT'
  alias DELETE='http DELETE'
fi

# yq shortcuts (YAML processor)
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
    
    if yq eval '.' "$1" > /dev/null 2>&1; then
      echo "✅ Valid YAML"
    else
      echo "❌ Invalid YAML"
      return 1
    fi
  }
fi

# ============================================================================
# END UTILITY FUNCTIONS
# ============================================================================

# ============================================================================
# MARKDOWN VIEWING - Beautiful formatted markdown in terminal
# ============================================================================

# View markdown files with glow (falls back to cat)
mdview() {
  if [[ -z "$1" ]]; then
    echo "📄 Markdown Viewer"
    echo ""
    echo "Usage: mdview <file.md>"
    echo ""
    echo "Examples:"
    echo "  mdview README.md"
    echo "  mdview ~/.zsh/docs/00-START-HERE.md"
    echo ""
    if command -v glow &> /dev/null; then
      echo "✅ Using: glow (beautiful formatting)"
    else
      echo "⚠️  glow not installed - install with: brew install glow"
      echo "   Falling back to: cat"
    fi
    return 1
  fi
  
  if command -v glow &> /dev/null; then
    glow "$@"
  else
    echo "⚠️  glow not installed (brew install glow)"
    echo "Showing raw markdown with cat:"
    echo ""
    cat "$@"
  fi
}

# Aliases for markdown viewing
alias md='mdview'
alias markdown='mdview'

# Auto-open .md files when you just type the filename
# Example: Just type "README.md" and it opens in glow!
if command -v glow &> /dev/null; then
  alias -s md='glow'
else
  alias -s md='cat'
fi

# ============================================================================
# END MARKDOWN VIEWING
# ============================================================================

# ============================================================================
# Your Custom Functions
# ============================================================================

# Your catrange function (preserved exactly as-is)
alias catr="catrange"
function catrange ()
{
   if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
      nStart=$1
      nEnd=$2
      filename=$3
   else
      nStart=$2
      nEnd=$3
      filename=$1
   fi
   cat -n $filename | sed -n $nStart,${nEnd}p
}

# ============================================================================
# SSH Autocomplete - OPTIMIZED for Large Configs (58+ hosts)
# ============================================================================

# Cache file location
_SSH_COMPLETION_CACHE="$HOME/.zsh_ssh_completion_cache"

# Function to refresh SSH completion cache
refresh_ssh_autocomplete() {
  if [[ ! -f ~/.ssh/config ]]; then
    return
  fi
  
  # Extract hosts and cache them (skip wildcards)
  local host_list=($(awk '/^Host[[:space:]]/ && !/\*/ {for(i=2;i<=NF;i++) print $i}' ~/.ssh/config))
  
  if [[ ${#host_list[@]} -gt 0 ]]; then
    # Save to cache file
    printf '%s\n' "${host_list[@]}" > "$_SSH_COMPLETION_CACHE"
    
    # Apply to zstyle
    zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts $host_list
    
    echo "✅ SSH completion refreshed: ${#host_list[@]} hosts cached"
  fi
}

# Load cached hosts if available, otherwise generate
if [[ -f "$_SSH_COMPLETION_CACHE" ]] && [[ -f ~/.ssh/config ]]; then
  # Check if SSH config is newer than cache
  if [[ ~/.ssh/config -nt "$_SSH_COMPLETION_CACHE" ]]; then
    # Config changed, refresh cache
    refresh_ssh_autocomplete
  else
    # Use cached hosts (FAST!)
    local cached_hosts=(${(f)"$(<$_SSH_COMPLETION_CACHE)"})
    zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts $cached_hosts
  fi
else
  # No cache exists, create it
  refresh_ssh_autocomplete
fi

# Alias for manual refresh
alias sshrefresh='refresh_ssh_autocomplete'

# Cleanup
unset _SSH_COMPLETION_CACHE

# ============================================================================
# ENHANCED SCP & RSYNC FUNCTIONS WITH FZF INTEGRATION
# Interactive file transfers with host/path selection from your 59 SSH hosts!
# ============================================================================

# Enhanced SCP helper with fzf host selection
scpd() {
  echo "🔐 SCP Helper - Easy file transfers"
  echo ""
  echo "What do you want to do?"
  echo "  1) Download from remote server to here"
  echo "  2) Upload from here to remote server"
  echo ""
  read "choice?Enter choice (1 or 2): "
  
  case $choice in
    1)
      # Download
      echo ""
      echo "Select remote host:"
      
      # Use fzf to select from SSH config
      local host=$(awk '/^Host / && $2 !~ /\*/ {print $2}' ~/.ssh/config 2>/dev/null | fzf --height=40% --prompt="SSH Host> ")
      
      if [[ -z "$host" ]]; then
        echo "❌ No host selected"
        return 1
      fi
      
      echo "Selected host: $host"
      echo ""
      read "remote_path?Remote file/directory path: "
      read "local_path?Save to (default: current dir): "
      local_path=${local_path:-.}
      
      echo ""
      echo "📥 Running: scp -r $host:$remote_path $local_path"
      scp -r "$host:$remote_path" "$local_path"
      ;;
      
    2)
      # Upload
      echo ""
      echo "Select local file/directory:"
      
      # Use fzf to browse local files
      local local_file=$(fd --type f --type d --max-depth 3 2>/dev/null | fzf --height=40% --prompt="Local File> " --preview="ls -lah {}")
      
      if [[ -z "$local_file" ]]; then
        echo "❌ No file selected"
        return 1
      fi
      
      echo "Selected: $local_file"
      echo ""
      echo "Select remote host:"
      
      # Use fzf to select from SSH config
      local host=$(awk '/^Host / && $2 !~ /\*/ {print $2}' ~/.ssh/config 2>/dev/null | fzf --height=40% --prompt="SSH Host> ")
      
      if [[ -z "$host" ]]; then
        echo "❌ No host selected"
        return 1
      fi
      
      echo "Selected host: $host"
      echo ""
      read "remote_path?Remote destination path: "
      
      echo ""
      echo "📤 Running: scp -r $local_file $host:$remote_path"
      scp -r "$local_file" "$host:$remote_path"
      ;;
      
    *)
      echo "❌ Invalid choice"
      ;;
  esac
}

# Enhanced rget - Download with fzf host selection
rget() {
  if [[ $# -eq 0 ]]; then
    # Interactive mode with fzf
    echo "📥 Interactive Download"
    echo ""
    echo "Select remote host:"
    
    local host=$(awk '/^Host / && $2 !~ /\*/ {print $2}' ~/.ssh/config 2>/dev/null | fzf --height=40% --prompt="SSH Host> ")
    
    if [[ -z "$host" ]]; then
      echo "❌ No host selected"
      return 1
    fi
    
    echo "Selected: $host"
    echo ""
    read "remote_path?Remote path to download: "
    read "local_path?Save to (default: current dir): "
    local_path=${local_path:-.}
    
    echo ""
    echo "📥 Downloading: $host:$remote_path → $local_path"
    rsync -avzP "$host:$remote_path" "$local_path"
    
  elif [[ $# -eq 1 ]]; then
    # Single argument - assume it's HOST:PATH, download to current dir
    echo "📥 Downloading: $1 → ."
    rsync -avzP "$1" .
    
  elif [[ $# -eq 2 ]]; then
    # Two arguments - HOST:PATH and LOCAL_PATH
    echo "📥 Downloading: $1 → $2"
    rsync -avzP "$1" "$2"
    
  else
    echo "Usage: rget [HOST:REMOTE_PATH] [LOCAL_PATH]"
    echo "   Or: rget (interactive mode with fzf)"
    return 1
  fi
}

# Enhanced rput - Upload with fzf file and host selection
rput() {
  if [[ $# -eq 0 ]]; then
    # Interactive mode with fzf
    echo "📤 Interactive Upload"
    echo ""
    echo "Select local file/directory:"
    
    local local_file=$(fd --type f --type d --max-depth 3 2>/dev/null | fzf --height=40% --prompt="Local File> " --preview="ls -lah {}")
    
    if [[ -z "$local_file" ]]; then
      echo "❌ No file selected"
      return 1
    fi
    
    echo "Selected: $local_file"
    echo ""
    echo "Select remote host:"
    
    local host=$(awk '/^Host / && $2 !~ /\*/ {print $2}' ~/.ssh/config 2>/dev/null | fzf --height=40% --prompt="SSH Host> ")
    
    if [[ -z "$host" ]]; then
      echo "❌ No host selected"
      return 1
    fi
    
    echo "Selected: $host"
    echo ""
    read "remote_path?Remote destination path: "
    
    echo ""
    echo "📤 Uploading: $local_file → $host:$remote_path"
    rsync -avzP "$local_file" "$host:$remote_path"
    
  elif [[ $# -eq 2 ]]; then
    # Two arguments - LOCAL_PATH and HOST:PATH
    echo "📤 Uploading: $1 → $2"
    rsync -avzP "$1" "$2"
    
  else
    echo "Usage: rput [LOCAL_PATH] [HOST:REMOTE_PATH]"
    echo "   Or: rput (interactive mode with fzf)"
    return 1
  fi
}

# Enhanced rsync-sync with fzf
rsync-sync() {
  if [[ $# -eq 0 ]]; then
    # Interactive mode
    echo "🔄 Interactive Sync"
    echo ""
    echo "Select local directory:"
    
    local local_dir=$(fd --type d --max-depth 3 2>/dev/null | fzf --height=40% --prompt="Local Dir> " --preview="ls -lah {}")
    
    if [[ -z "$local_dir" ]]; then
      echo "❌ No directory selected"
      return 1
    fi
    
    echo "Selected: $local_dir"
    echo ""
    echo "Select remote host:"
    
    local host=$(awk '/^Host / && $2 !~ /\*/ {print $2}' ~/.ssh/config 2>/dev/null | fzf --height=40% --prompt="SSH Host> ")
    
    if [[ -z "$host" ]]; then
      echo "❌ No host selected"
      return 1
    fi
    
    echo "Selected: $host"
    echo ""
    read "remote_path?Remote destination path: "
    
    echo ""
    echo "🔄 DRY RUN: Syncing $local_dir → $host:$remote_path"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    rsync -avzP --dry-run "$local_dir/" "$host:$remote_path"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    read "confirm?⚠️  Proceed with actual sync? (y/n): "
    
    if [[ $confirm == "y" ]]; then
      echo "🚀 Syncing..."
      rsync -avzP "$local_dir/" "$host:$remote_path"
      echo "✅ Sync complete!"
    else
      echo "❌ Sync cancelled"
    fi
    
  elif [[ $# -eq 2 ]]; then
    # Two arguments - standard mode
    local local_path=$1
    local host=$2
    
    echo "🔄 DRY RUN: Syncing $local_path → $host"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    rsync -avzP --dry-run "$local_path/" "$host"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    read "confirm?⚠️  Proceed with actual sync? (y/n): "
    
    if [[ $confirm == "y" ]]; then
      echo "🚀 Syncing..."
      rsync -avzP "$local_path/" "$host"
      echo "✅ Sync complete!"
    else
      echo "❌ Sync cancelled"
    fi
    
  else
    echo "Usage: rsync-sync [LOCAL_DIR] [HOST:REMOTE_DIR]"
    echo "   Or: rsync-sync (interactive mode with fzf)"
    return 1
  fi
}

# BONUS: Browse remote directory
rbrowse() {
  echo "🔍 Remote Directory Browser"
  echo ""
  echo "Select remote host:"
  
  local host=$(awk '/^Host / && $2 !~ /\*/ {print $2}' ~/.ssh/config 2>/dev/null | fzf --height=40% --prompt="SSH Host> ")
  
  if [[ -z "$host" ]]; then
    echo "❌ No host selected"
    return 1
  fi
  
  echo "Selected: $host"
  echo ""
  read "remote_path?Remote path to browse (default: ~): "
  remote_path=${remote_path:-~}
  
  echo ""
  echo "📂 Listing: $host:$remote_path"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  ssh "$host" "ls -lah $remote_path"
}

# Aliases
alias scpi='scpd'           # Interactive SCP
alias scphelp='echo "Download: scp HOST:PATH LOCAL" && echo "Upload: scp LOCAL HOST:PATH"'

# ============================================================================
# Your Custom Aliases
# ============================================================================

alias sshconfig='code ~/.ssh/config'
# myip is defined as a function earlier (shows both local and public IPv4)
alias bfg="java -jar ~/bin/bfg-1.14.0.jar"
alias cleanlog="~/bin/clean-jenkins-log.sh"

# Your work directory shortcuts
alias tfeks='cd ~/git/as/terraform/tf-live-scrm/scrm-it_018805767579'
alias cdeks='cd ~/git/as/terraform/tf-live-scrm/scrm-it_018805767579'

# ============================================================================
# kubectl Aliases (All 73 from your _zsh_kubectl_aliases file)
# ============================================================================

# Core kubectl shortcut
alias k='kubectl'

# Get commands
alias kg='kubectl get'
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kgd='kubectl get deployments'
alias kgr='kubectl get rs'
alias kgi='kubectl get ingress'
alias kgcm='kubectl get configmap'
alias kgsec='kubectl get secret'
alias kgns='kubectl get namespaces'
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'
alias kgcrd='kubectl get crd'

# Describe commands
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kdn='kubectl describe node'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe svc'
alias kdi='kubectl describe ingress'
alias kdcm='kubectl describe configmap'
alias kdsec='kubectl describe secret'

# Delete commands
alias kdel='kubectl delete'
alias kdelp='kubectl delete pod'
alias kdeld='kubectl delete deployment'
alias kdels='kubectl delete svc'
alias kdeli='kubectl delete ingress'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# Exec
alias kex='kubectl exec -it'

# Apply / Create / Edit
alias ka='kubectl apply -f'
alias kc='kubectl create -f'
alias ke='kubectl edit'

# Namespace helpers
alias kcn='kubectl config set-context --current --namespace'
alias kctx='kubectl config use-context'
alias kctxs='kubectl config get-contexts'

# Rollouts
alias kro='kubectl rollout'
alias kros='kubectl rollout status'
alias krou='kubectl rollout undo'

# Port-forward
alias kpf='kubectl port-forward'

# Top
alias ktp='kubectl top pod'
alias ktn='kubectl top node'

# Kustomize
alias kky='kubectl kustomize'

# CRD helpers
alias kgcr='kubectl get customresourcedefinition'
alias kdcr='kubectl describe customresourcedefinition'

# ============================================================================
# Terraform Settings & Aliases
# ============================================================================
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
export TERRAGRUNT_DOWNLOAD="$HOME/.terraform.d/terragrunt"
alias tf='terraform'

# ============================================================================
# PATH Setup (Your Custom Paths)
# ============================================================================
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/bin:$HOME/git/as/SCRM_CIDR/scripts_and_sharelib/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# ============================================================================
# ASDF Version Manager (only load if installed)
# ============================================================================
# asdf is installed via: brew install asdf
# Then run: devsetup add terraform (or kubectl, nodejs, etc.)
if [[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]]; then
    . /opt/homebrew/opt/asdf/libexec/asdf.sh
elif [[ -f /usr/local/opt/asdf/libexec/asdf.sh ]]; then
    . /usr/local/opt/asdf/libexec/asdf.sh
elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    . "$HOME/.asdf/asdf.sh"
fi

# ============================================================================
# Pager Overrides (Your Settings)
# ============================================================================
export PAGER=""
export AWS_PAGER=""

# ============================================================================
# fzf Configuration (ENHANCED)
# ============================================================================

# Use fd with fzf for better file finding
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Enhanced fzf options with Catppuccin Mocha theme
export FZF_DEFAULT_OPTS="--preview-window=right:60%:wrap --ansi --height 60% --layout=reverse --border --inline-info \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Enhanced preview with bat
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons --git --color=always {}'"

# ============================================================================
# fzf-tab Configuration
# ============================================================================

# Completion menu settings
zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Your existing fzf-tab settings
zstyle ':fzf-tab:*' switch-group ',' '.'

# Enhanced default preview using eza or bat
zstyle ':fzf-tab:*' fzf-preview \
  'if [ -f $realpath ]; then
    if command -v bat &> /dev/null; then
      bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null
    else
      head -n 100 $realpath 2>/dev/null
    fi
  elif [ -d $realpath ]; then
    if command -v eza &> /dev/null; then
      eza -la --icons --git --color=always $realpath 2>/dev/null
    else
      ls -lah --color=always $realpath 2>/dev/null
    fi
  else
    echo "Unknown file type"
  fi'

# ============================================================================
# Load Your fzf-tab Preview Modules (All 11 files!)
# ============================================================================

# Load all your custom preview files
for file in ~/.zsh/previews/*.zsh; do
  [ -r "$file" ] && source "$file"
done

# ============================================================================
# Network Debugging Toolkit
# ============================================================================

# Load network debugging functions (ports, DNS, tunneling, etc.)
if [ -f ~/.zsh/network-toolkit.zsh ]; then
  source ~/.zsh/network-toolkit.zsh
fi

# ============================================================================
# AWS SSO Toolkit
# ============================================================================

# Load AWS SSO functions (awslogin, awsuse, awsstatus, etc.)
if [ -f ~/.zsh/aws-sso-toolkit.zsh ]; then
  source ~/.zsh/aws-sso-toolkit.zsh
fi

# ============================================================================
# GitHub CLI Toolkit
# ============================================================================

# Load GitHub CLI functions (ghprs, ghissues, ghclone, etc.)
if [ -f ~/.zsh/github-cli-toolkit.zsh ]; then
  source ~/.zsh/github-cli-toolkit.zsh
fi

# ============================================================================
# Bookmark System
# ============================================================================

# Load bookmark functions (bm, bml, bmrm, bmcheck, bmstats, bmback, bmcode)
if [ -f ~/.zsh/bookmarks.zsh ]; then
  source ~/.zsh/bookmarks.zsh
fi

# ============================================================================
# Markdown Toolkit
# ============================================================================

# Load markdown conversion functions (mdpdf, mdhtml, mdslack, mdview, etc.)
if [ -f ~/.zsh/markdown-toolkit.zsh ]; then
  source ~/.zsh/markdown-toolkit.zsh
fi

# ============================================================================
# My Favorites (Startup Display)
# ============================================================================

# Load favorites system (fav, favedit, favadd, favoff, favon)
# This shows your customizable favorite commands at terminal startup
if [ -f ~/.zsh/favorites.zsh ]; then
  source ~/.zsh/favorites.zsh
fi

# ============================================================================
# Project Status (auto-show on cd)
# ============================================================================

# Shows PROJECT-STATUS.md when entering project folders
# Commands: project-status, project-status-init, pst, pst-edit
if [ -f ~/.zsh/project-status.zsh ]; then
  source ~/.zsh/project-status.zsh
fi

# ============================================================================
# iTerm2: Shell Integration & Features
# ============================================================================

# Enable true color support (24-bit colors) for modern terminals
export COLORTERM=truecolor

# Detect if we're in iTerm2
if [[ "$TERM_PROGRAM" == "iTerm.app" ]] || [[ -n "$ITERM_SESSION_ID" ]]; then
    export ITERM2_DETECTED=1
    
    # Shell integration (Cmd+Click files, badges, imgcat, etc.)
    if [[ -f ~/.iterm2_shell_integration.zsh ]]; then
        source ~/.iterm2_shell_integration.zsh
    else
        # Auto-install shell integration (one-time, silent)
        if command -v curl &>/dev/null && [[ ! -f ~/.iterm2_install_attempted ]]; then
            touch ~/.iterm2_install_attempted
            curl -fsSL https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh 2>/dev/null
            [[ -f ~/.iterm2_shell_integration.zsh ]] && source ~/.iterm2_shell_integration.zsh && echo "✅ iTerm2 shell integration installed!"
        fi
    fi
    
    # ─── iTerm2 Functions ────────────────────────────────────────────────────
    
    # Display image inline
    imgcat() {
        if [[ -x ~/.iterm2/imgcat ]]; then
            ~/.iterm2/imgcat "$@"
        else
            echo "💡 Run: brew install imgcat"
        fi
    }
    
    # Set tab/window title
    title() { echo -ne "\033]0;$*\007"; }
    
    # Badge in corner
    badge() { printf "\e]1337;SetBadgeFormat=%s\a" $(echo -n "$*" | base64); }
    clearbadge() { printf "\e]1337;SetBadgeFormat=\a"; }
    
    # Notification when done
    notify() {
        local msg="${1:-Done}"
        osascript -e "display notification \"$msg\" with title \"Terminal\"" 2>/dev/null
        printf "\e]9;%s\a" "$msg"
    }
    
    # Tab colors for context
    tabcolor() { printf "\e]6;1;bg;red;brightness;%s\a\e]6;1;bg;green;brightness;%s\a\e]6;1;bg;blue;brightness;%s\a" "$1" "$2" "$3"; }
    tabreset() { printf "\e]6;1;bg;*;default\a"; }
    tabwork() { tabcolor 255 100 100; badge "WORK"; }
    tabprod() { tabcolor 255 50 50; badge "⚠️ PROD"; }
    tabdev() { tabcolor 100 255 100; badge "DEV"; }
    
    # SSH with auto profile switch (reads # iTerm2Profile: from ~/.ssh/config)
    ssh() {
        local host=""
        for arg in "$@"; do [[ "$arg" != -* ]] && host="$arg" && break; done
        if [[ -n "$host" ]]; then
            local profile=$(grep -A5 "Host $host" ~/.ssh/config 2>/dev/null | grep "# iTerm2Profile:" | cut -d: -f2 | tr -d ' ')
            [[ -n "$profile" ]] && echo -ne "\033]50;SetProfile=$profile\a"
        fi
        command ssh "$@"
        echo -ne "\033]50;SetProfile=Default\a"
    }
else
    export ITERM2_DETECTED=0
    imgcat() { echo "Requires iTerm2"; }
    badge() { :; }
    clearbadge() { :; }
fi

# ============================================================================
# SSH Tunnels, Proxies & Remote Access
# ============================================================================
# Works in any terminal - essential for personal Mac ↔ work laptop setup

# ─── SOCKS Proxy (Browse web through remote machine) ────────────────────────

# Start SOCKS5 proxy - browse as if you're on the remote machine
# Usage: socks work-laptop       → starts on port 9999
#        socks work-laptop 1080  → custom port
socks() {
    local host="${1:?Usage: socks <host> [port]}"
    local port="${2:-9999}"
    echo "🌐 SOCKS5 proxy through $host on localhost:$port"
    echo ""
    echo "   Browser setup: SOCKS5 proxy → localhost:$port"
    echo "   Or system-wide: System Preferences → Network → Proxies → SOCKS"
    echo "   Or CLI: export ALL_PROXY=socks5://localhost:$port"
    echo ""
    echo "   Press Ctrl+C to stop"
    ssh -D "$port" -C -q -N "$host"
}

# Alias for clarity
alias socks-proxy='socks'

# ─── Port Forwarding ─────────────────────────────────────────────────────────

# Forward local port to remote service
# Usage: forward 8080 internal.work.com:443 work-laptop
#        Then: https://localhost:8080 → internal.work.com:443
forward() {
    local lport="${1:?Usage: forward <local_port> <remote_host:port> <ssh_host>}"
    local remote="${2:?Need remote_host:port}"
    local via="${3:?Need ssh_host}"
    echo "🔗 localhost:$lport → $remote (via $via)"
    ssh -L "$lport:$remote" -N -q "$via"
}

# Quick forwards for common services
forward-web() {
    local host="${1:?Usage: forward-web <internal_host> <ssh_jump>}"
    local via="${2:?Need ssh jump host}"
    echo "🌐 Forwarding $host:443 to localhost:8443"
    ssh -L "8443:$host:443" -N -q "$via"
}

forward-rdp() {
    local host="${1:?Usage: forward-rdp <windows_host> <ssh_jump>}"
    local via="${2:?Need ssh jump host}"
    echo "🖥️  Forwarding $host:3389 to localhost:3389"
    ssh -L "3389:$host:3389" -N -q "$via"
}

# Reverse tunnel - expose local service to remote
# Usage: expose 3000 work-laptop
#        Then on work-laptop: curl localhost:3000
expose() {
    local port="${1:?Usage: expose <port> <ssh_host>}"
    local host="${2:?Need ssh_host}"
    echo "⬅️  Exposing localhost:$port to $host:$port"
    ssh -R "$port:localhost:$port" -N -q "$host"
}

# ─── Tunnel Management ───────────────────────────────────────────────────────

# List active tunnels
tunnels() {
    echo "🔗 Active SSH tunnels/proxies:"
    ps aux | grep -E "ssh.+(-[DLRN]|ProxyJump)" | grep -v grep | while read line; do
        echo "  $line" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}'
    done
    [[ $(ps aux | grep -E "ssh.+(-[DLRN])" | grep -v grep | wc -l) -eq 0 ]] && echo "  (none active)"
}

# Kill tunnels
tunnel-kill() {
    local count=$(ps aux | grep -E "ssh.+-[DLRN]" | grep -v grep | wc -l)
    pkill -f "ssh.*-[DLRN]"
    echo "✅ Killed $count tunnel(s)"
}

# ─── File Transfer Helpers ───────────────────────────────────────────────────

# Push file to remote (with progress)
push() {
    local file="${1:?Usage: push <file> <host>:[path]}"
    local dest="${2:?Need destination host:[path]}"
    rsync -avzP --partial "$file" "$dest"
}

# Pull file from remote (with progress)
pull() {
    local src="${1:?Usage: pull <host>:<path> [local_path]}"
    local dest="${2:-.}"
    rsync -avzP --partial "$src" "$dest"
}

# Sync directory to remote (mirror)
sync-to() {
    local dir="${1:?Usage: sync-to <dir> <host>:<path>}"
    local dest="${2:?Need destination}"
    rsync -avzP --delete "$dir/" "$dest/"
}

# Sync directory from remote
sync-from() {
    local src="${1:?Usage: sync-from <host>:<path> <local_dir>}"
    local dest="${2:?Need local destination}"
    rsync -avzP --delete "$src/" "$dest/"
}

# ─── Connection Helpers ──────────────────────────────────────────────────────

# Test SSH connection
sshtest() {
    local host="${1:?Usage: sshtest <host>}"
    echo -n "Testing $host... "
    if ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" echo "✅ OK" 2>/dev/null; then
        :
    else
        echo "❌ Failed"
        return 1
    fi
}

# Get remote machine's IP (useful for LAN setup)
remote-ip() {
    local host="${1:?Usage: remote-ip <host>}"
    ssh "$host" "hostname -I 2>/dev/null | awk '{print \$1}' || ipconfig getifaddr en0 2>/dev/null"
}

# SSH with connection sharing (faster subsequent connections)
# Enable this in ~/.ssh/config instead for automatic benefit

# ─── Quick Setup Helpers ─────────────────────────────────────────────────────

# Copy SSH key to remote host
ssh-copy-key() {
    local host="${1:?Usage: ssh-copy-key <host>}"
    if [[ ! -f ~/.ssh/id_ed25519.pub ]] && [[ ! -f ~/.ssh/id_rsa.pub ]]; then
        echo "No SSH key found. Generate one with: ssh-keygen -t ed25519"
        return 1
    fi
    ssh-copy-id "$host"
}

# Generate SSH key if needed
ssh-setup() {
    if [[ -f ~/.ssh/id_ed25519 ]]; then
        echo "✅ SSH key already exists: ~/.ssh/id_ed25519"
    else
        echo "🔑 Generating new SSH key..."
        ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"
    fi
    echo ""
    echo "📋 Your public key:"
    cat ~/.ssh/id_ed25519.pub
    echo ""
    echo "💡 Copy to remote with: ssh-copy-key <host>"
}

# Show SSH config tips
ssh-tips() {
    cat << 'EOF'
━━━ SSH Config Tips (~/.ssh/config) ━━━

# Keep connections alive (no timeout)
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Connection sharing (faster repeat connections)
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600

# Jump through bastion to internal servers
Host internal-*
    ProxyJump bastion.company.com

# Quick alias with custom key
Host work
    HostName 192.168.1.100
    User mark
    IdentityFile ~/.ssh/work_key

# iTerm2 profile switching
Host prod-*
    # iTerm2Profile: Production

━━━ Create socket directory ━━━
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh/sockets
EOF
}

# ============================================================================
# Git Aliases (Additional Shortcuts)
# ============================================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate'
alias glog='git log --pretty=format:"%C(yellow)%h%Creset %C(blue)%ad%Creset | %s%C(green)%d%Creset %C(bold blue)[%an]%Creset" --date=short'

# ============================================================================
# Docker Aliases
# ============================================================================
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimg='docker images'

function dexec() {
  docker exec -it $1 ${2:-bash}
}

# ============================================================================
# Development Shortcuts
# ============================================================================

# Quick directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Quick edit configs
alias zshconfig='code ~/.zshrc'
alias starconfig='code ~/.config/starship.toml'

# Quick reload
alias reload='source ~/.zshrc'

# Show PATH nicely
alias path='echo $PATH | tr ":" "\n"'

# localip is defined earlier with better fallback

# ============================================================================
# Additional Helper Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find process using port
port() {
  lsof -i :$1
}

# Kill process on port
killport() {
  kill -9 $(lsof -t -i:$1)
}

# Quick git commit
gcom() {
  git add -A && git commit -m "$*"
}

# Quick push
gpush() {
  git add -A && git commit -m "$*" && git push
}

# Git diff with delta
gdiff() {
  git diff $* | delta
}

# Kubectl quick pod exec
kexec() {
  local pod=$1
  shift
  kubectl exec -it $pod -- ${@:-bash}
}

# Kubectl quick logs with follow
klogs() {
  local pod=$1
  kubectl logs -f $pod --tail=100
}

# Kubectl get pod by label
kgetl() {
  kubectl get pods -l $1
}

# ============================================================================
# Environment Variables
# ============================================================================

# Editor
export EDITOR='code --wait'
export VISUAL='code --wait'

# History settings
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Language environments - Cross-platform compatible
# macOS, Linux (WSL), and other Unix systems handle locales differently
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS - Use the system default, don't force UTF-8 if not available
  # macOS will use the best available locale automatically
  export LANG="${LANG:-en_US.UTF-8}"
  # Don't set LC_ALL on macOS - let the system handle it
elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
  # Linux / WSL - Usually has full UTF-8 support
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
else
  # Other Unix systems - use conservative defaults
  export LANG=en_US.UTF-8
fi

# ============================================================================
# PROMPT: Powerlevel10k (Recommended) or Starship
# ============================================================================

# Choose your prompt:
# - Powerlevel10k: Instant prompt, transient prompt works perfectly, p10k configure wizard
# - Starship: Fast, cross-shell, but transient prompt has issues in zsh

# ----------------------------------------------------------------------------
# OPTION 1: Powerlevel10k (DEFAULT - Transient Prompt Works!)
# ----------------------------------------------------------------------------

# Enable Powerlevel10k instant prompt (should stay close to top of .zshrc)
# Initialization code that may require console input must go above this block
# quiet = suppress warning about console output during init (we show favorites)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Powerlevel10k theme
# Install: brew install powerlevel10k
# Or: git clone https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
if [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source ~/powerlevel10k/powerlevel10k.zsh-theme
else
  echo "⚠️  Powerlevel10k not found!"
  echo "Install: brew install powerlevel10k"
  echo "Or switch to Starship (see comments in .zshrc)"
fi

# Load P10k configuration (created by running: p10k configure)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ----------------------------------------------------------------------------
# OPTION 2: Starship (Alternative - Uncomment to use instead)
# ----------------------------------------------------------------------------
# 
# # Use starship config from ~/.zsh/ (keeps all zsh configs together)
# export STARSHIP_CONFIG=~/.zsh/starship.toml
# 
# # Initialize starship
# eval "$(starship init zsh)"
# 
# # Note: Starship's transient prompt has issues in zsh
# # If you need transient prompts, use Powerlevel10k instead
# 
# # Enable right prompt clearing (partial transient support)
# setopt TRANSIENT_RPROMPT

# ----------------------------------------------------------------------------
# End of Prompt Configuration
# ----------------------------------------------------------------------------

# ============================================================================
# 📝 CUSTOM EDITS SECTION - Add Your Personal Customizations Below
# ============================================================================

# Add your custom aliases here:
# alias myalias='my command'

# Add your custom functions here:
# myfunction() {
#   # your code
# }

# Add your custom environment variables here:
# export MY_VAR="value"

# ============================================================================
# Modern Tools Reference - Quick lookup for command replacements
# ============================================================================

# Show what modern tools replaced traditional commands
tools() {
  cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════╗
║               🚀 MODERN CLI TOOLS REFERENCE                          ║
╚══════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────┐
│ FILE LISTING (eza replaces ls)                                       │
└──────────────────────────────────────────────────────────────────────┘

  OLD COMMAND          NEW COMMAND              WHAT IT DOES
  ────────────────────────────────────────────────────────────────────
  ls                   ls                       List with icons
  ls -la               ll                       Long detailed list
  ls -ltr              ltr                      Oldest→Newest ✨
  ls -ltr              lsr                      Real ls -ltr ✨
  ls -la               llr                      Real ls -la ✨
  ls -a                la                       Show hidden files
  tree                 lt                       Tree view (2 levels)

  💡 eza adds: Icons, git status, colors
  💡 Use original: lsr (real ls -ltr)

┌──────────────────────────────────────────────────────────────────────┐
│ FILE VIEWING (bat replaces cat)                                      │
└──────────────────────────────────────────────────────────────────────┘

  OLD COMMAND          NEW COMMAND              WHAT IT DOES
  ────────────────────────────────────────────────────────────────────
  cat file.txt         cat file.txt             Syntax + line numbers
  cat file.txt         catp file.txt            Plain cat ✨
  cat file.txt         rawcat file.txt          Same as catp ✨
  cat file.txt         plaincat file.txt        No line numbers ✨

  💡 bat adds: Syntax highlighting, line numbers, git changes
  💡 For piping: Use catp or rawcat

┌──────────────────────────────────────────────────────────────────────┐
│ DIRECTORY NAVIGATION (zoxide - smart cd with bookmarks!)             │
└──────────────────────────────────────────────────────────────────────┘

  BASIC USAGE:
  ────────────────────────────────────────────────────────────────────
  cd ~/long/path       z path                   Smart jump
  cd -                 z -                      Previous dir
  (none)               zi                       Interactive picker
  (none)               d                        Directory history ✨

  BOOKMARKS SYSTEM:
  ────────────────────────────────────────────────────────────────────
  (none)               bookmark proj ~/Projects Add bookmark ✨
  (none)               bookmarks                List all bookmarks ✨
  (none)               mycd <TAB>               Jump with completion ✨

  HOW IT WORKS:
  • Every 'cd' you do is automatically tracked
  • Use 'z <partial-name>' to jump anywhere
  • Use 'bookmark' to save favorite dirs
  • Use 'bookmarks' to see your top 20 dirs
  • Use 'mycd <TAB>' for tab completion

  EXAMPLES:
  z down              → Jumps to ~/Downloads
  bookmark proj ~/Projects/myapp
  mycd proj           → Jumps to ~/Projects/myapp
  bookmarks           → Shows your top 20 directories

  💡 Regular 'cd' still works and tracks locations!

┌──────────────────────────────────────────────────────────────────────┐
│ TEXT SEARCHING (ripgrep - faster grep)                               │
└──────────────────────────────────────────────────────────────────────┘

  OLD COMMAND               NEW COMMAND
  ────────────────────────────────────────────────────────────────────
  grep -r "text" .          rg text
  grep -i "text" file       grip "text" file       ✨
  grep -i "text" file       grepi "text" file      ✨
  grep -i "text" file       greps "text" file      ✨

  💡 All three aliases do case-insensitive search
  💡 ripgrep is 10-100x faster, respects .gitignore

  EXAMPLES:
  grip "error" *.log        Find error in log files
  grepi "TODO" *.js         Find TODO in JS files (any case)

┌──────────────────────────────────────────────────────────────────────┐
│ FILE SEARCHING (fd replaces find)                                    │
└──────────────────────────────────────────────────────────────────────┘

  OLD COMMAND                      NEW COMMAND
  ────────────────────────────────────────────────────────────────────
  find . -name "*.txt"             fd txt
  find . -type f -name "*.js"      fd -e js

  💡 fd is faster with simpler syntax

╔══════════════════════════════════════════════════════════════════════╗
║                        QUICK REFERENCE                                ║
╚══════════════════════════════════════════════════════════════════════╝

EZA (LS):
  ls       Basic list       ltr      Oldest→Newest ✨
  ll       Long detailed    lsr      Real ls -ltr ✨
  la       Hidden files     llr      Real ls -la ✨
  lt       Tree view        l        Long readable

BAT (CAT):
  cat      With format      catp     Plain cat ✨
  rawcat   Plain cat        plaincat No numbers

GREP (SEARCH):
  grip "text" file          Case-insensitive ✨
  grepi "text" file         Same thing ✨
  greps "text" file         Same thing ✨

ZOXIDE (CD with BOOKMARKS):
  z myproject               Smart jump
  d                         History ✨
  bookmarks                 List top 20 ✨
  bookmark name ~/path      Save favorite ✨
  mycd <TAB>                Jump with completion ✨

SHORTCUTS (Save typing!):
  bm                        → bookmark (save dir) ✨
  bms                       → bookmarks (list dirs) ✨
  h                         → history search (Ctrl+R) ✨

╔══════════════════════════════════════════════════════════════════════╗
║ Type 'tools' anytime to see this reference!                          ║
╚══════════════════════════════════════════════════════════════════════╝
EOF
}

# Add aliases
alias modern='tools'           # For those used to typing 'modern'
alias toolhelp='tools'
alias cmdref='tools'

# ============================================================================
# Welcome Message & Quick Reference - DYNAMIC
# ============================================================================

# Enhanced terminal help command with fzf menu - CATEGORIZED
termhelp() {
  local topics=(
    "┌─ DAILY USE ────────────────────────────────────"
    "fzf:Fuzzy finding - Tab completion, Ctrl+R, file search"
    "dirs:Directory jumping - Bookmarks, zoxide, never lose folders"
    "history:Command history - h, Ctrl+R, search your past commands"
    "files:File utilities - extract, mkcd, clip, serve"
    "modern:Modern CLI tools - eza, bat, ripgrep, fd"
    "├─ DEV TOOLS ───────────────────────────────────"
    "python:Python & asdf - Version management, .tool-versions, Lambda"
    "git:Git workflow - Aliases, shortcuts, git-undo, git-wip"
    "docker:Docker & Kubernetes - Aliases, k9s shortcuts"
    "vscode:VSCode integration - code command shortcuts"
    "devtools:Dev utilities - lazygit, lazydocker, httpie, tldr"
    "tui:TUI apps - Terminal UI tools (btop, lazygit, gum, superfile)"
    "├─ TOOLKITS ────────────────────────────────────"
    "github:GitHub CLI toolkit - 42 commands for PRs, issues, repos"
    "network:Network toolkit - 24 debugging commands (ports, DNS, SSL)"
    "aws:AWS SSO toolkit - 10 commands for AWS management"
    "├─ SSH & REMOTE ───────────────────────────────"
    "iterm2:iTerm2 + SSH complete guide - tunnels, proxies, file transfer"
    "ssh:SSH tunnels & proxies - SOCKS, port forward, jump hosts"
    "├─ UTILITIES ───────────────────────────────────"
    "favorites:Customize startup display - favedit, fav, favoff"
    "clipboard:Clipboard - Copy/paste from terminal"
    "netutils:Network utils - myip, port, killport"
    "json:JSON/YAML tools - jq, yq shortcuts"
    "processes:Process management - psa, psmem shortcuts"
    "├─ REFERENCE ───────────────────────────────────"
    "vim:Vim reference - Complete Vim command guide with examples"
    "vimode:Shell vi mode - Use Vim keybindings at your prompt"
    "all:All commands A-Z - Complete command reference"
    "cheat:Cheat sheet - One-page quick reference"
    "└────────────────────────────────────────────────"
  )
  
  if [[ -z "$1" ]]; then
    # Interactive mode with fzf
    echo "📚 Terminal Help - Select a topic:"
    echo ""
    
    # Filter out separator lines for fzf but show them in preview
    local choice=$(printf '%s\n' "${topics[@]}" | grep -v "^[┌├└]" | fzf \
      --height=60% \
      --prompt="Help> " \
      --header="Use arrows to navigate, Enter to select" \
      --preview='echo "Select a topic to view its documentation"' | cut -d: -f1)
    
    if [[ -n "$choice" ]]; then
      echo ""
      # Call the appropriate command/function
      case "$choice" in
        fzf) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DAILY-USE/FZF-FUZZY-FINDING.md
          else
            ${PAGER:-less} ~/.zsh/docs/DAILY-USE/FZF-FUZZY-FINDING.md
          fi
          ;;
        dirs) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DAILY-USE/DIRECTORY-JUMPING.md
          else
            ${PAGER:-less} ~/.zsh/docs/DAILY-USE/DIRECTORY-JUMPING.md
          fi
          ;;
        history) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DAILY-USE/COMMAND-HISTORY.md
          else
            ${PAGER:-less} ~/.zsh/docs/DAILY-USE/COMMAND-HISTORY.md
          fi
          ;;
        files) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DAILY-USE/FILE-TOOLS.md
          else
            ${PAGER:-less} ~/.zsh/docs/DAILY-USE/FILE-TOOLS.md
          fi
          ;;
        modern) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DAILY-USE/MODERN-CLI-TOOLS.md
          else
            ${PAGER:-less} ~/.zsh/docs/DAILY-USE/MODERN-CLI-TOOLS.md
          fi
          ;;
        git) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DEV-TOOLS/GIT-WORKFLOW.md
          else
            ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/GIT-WORKFLOW.md
          fi
          ;;
        docker) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DEV-TOOLS/DOCKER-KUBERNETES.md
          else
            ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/DOCKER-KUBERNETES.md
          fi
          ;;
        vscode) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DEV-TOOLS/VSCODE-INTEGRATION.md
          else
            ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/VSCODE-INTEGRATION.md
          fi
          ;;
        devtools)
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DEV-TOOLS/DEV-UTILITIES.md
          else
            ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/DEV-UTILITIES.md
          fi
          ;;
        python)
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DEV-TOOLS/PYTHON-ASDF.md
          else
            ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/PYTHON-ASDF.md
          fi
          ;;
        tui)
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DEV-TOOLS/TUI-TOOLS.md
          else
            ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/TUI-TOOLS.md
          fi
          ;;
        github) ghhelp ;;
        network) nethelp ;;
        aws) awshelp ;;
        iterm2|ssh) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/COMPREHENSIVE/ITERM2-SSH-GUIDE.md
          else
            ${PAGER:-less} ~/.zsh/docs/COMPREHENSIVE/ITERM2-SSH-GUIDE.md
          fi
          ;;
        clipboard) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/UTILITIES/CLIPBOARD.md
          else
            ${PAGER:-less} ~/.zsh/docs/UTILITIES/CLIPBOARD.md
          fi
          ;;
        netutils) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/UTILITIES/NETWORK-UTILS.md
          else
            ${PAGER:-less} ~/.zsh/docs/UTILITIES/NETWORK-UTILS.md
          fi
          ;;
        json) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/UTILITIES/JSON-YAML-TOOLS.md
          else
            ${PAGER:-less} ~/.zsh/docs/UTILITIES/JSON-YAML-TOOLS.md
          fi
          ;;
        processes) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/UTILITIES/SYSTEM-MONITOR.md
          else
            ${PAGER:-less} ~/.zsh/docs/UTILITIES/SYSTEM-MONITOR.md
          fi
          ;;
        all) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/REFERENCE/ALL-COMMANDS.md
          else
            ${PAGER:-less} ~/.zsh/docs/REFERENCE/ALL-COMMANDS.md
          fi
          ;;
        cheat) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/REFERENCE/CHEAT-SHEET.md
          else
            ${PAGER:-less} ~/.zsh/docs/REFERENCE/CHEAT-SHEET.md
          fi
          ;;
        vim) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/REFERENCE/VIM-REFERENCE.md
          else
            ${PAGER:-less} ~/.zsh/docs/REFERENCE/VIM-REFERENCE.md
          fi
          ;;
        vimode) 
          if command -v glow &> /dev/null; then
            glow ~/.zsh/docs/DAILY-USE/ZSH-VI-MODE.md
          else
            ${PAGER:-less} ~/.zsh/docs/DAILY-USE/ZSH-VI-MODE.md
          fi
          ;;
        *) echo "Unknown topic: $choice" ;;
      esac
    else
      echo "❌ No topic selected"
    fi
  else
    # Direct command mode
    case "$1" in
      fzf) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DAILY-USE/FZF-FUZZY-FINDING.md
        else
          ${PAGER:-less} ~/.zsh/docs/DAILY-USE/FZF-FUZZY-FINDING.md
        fi
        ;;
      dirs) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DAILY-USE/DIRECTORY-JUMPING.md
        else
          ${PAGER:-less} ~/.zsh/docs/DAILY-USE/DIRECTORY-JUMPING.md
        fi
        ;;
      history) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DAILY-USE/COMMAND-HISTORY.md
        else
          ${PAGER:-less} ~/.zsh/docs/DAILY-USE/COMMAND-HISTORY.md
        fi
        ;;
      files) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DAILY-USE/FILE-TOOLS.md
        else
          ${PAGER:-less} ~/.zsh/docs/DAILY-USE/FILE-TOOLS.md
        fi
        ;;
      modern) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DAILY-USE/MODERN-CLI-TOOLS.md
        else
          ${PAGER:-less} ~/.zsh/docs/DAILY-USE/MODERN-CLI-TOOLS.md
        fi
        ;;
      git) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DEV-TOOLS/GIT-WORKFLOW.md
        else
          ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/GIT-WORKFLOW.md
        fi
        ;;
      docker) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DEV-TOOLS/DOCKER-KUBERNETES.md
        else
          ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/DOCKER-KUBERNETES.md
        fi
        ;;
      vscode) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DEV-TOOLS/VSCODE-INTEGRATION.md
        else
          ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/VSCODE-INTEGRATION.md
        fi
        ;;
      devtools)
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DEV-TOOLS/DEV-UTILITIES.md
        else
          ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/DEV-UTILITIES.md
        fi
        ;;
      python)
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DEV-TOOLS/PYTHON-ASDF.md
        else
          ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/PYTHON-ASDF.md
        fi
        ;;
      tui)
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DEV-TOOLS/TUI-TOOLS.md
        else
          ${PAGER:-less} ~/.zsh/docs/DEV-TOOLS/TUI-TOOLS.md
        fi
        ;;
      github) ghhelp ;;
      network) nethelp ;;
      aws) awshelp ;;
      iterm2|ssh) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/COMPREHENSIVE/ITERM2-SSH-GUIDE.md
        else
          ${PAGER:-less} ~/.zsh/docs/COMPREHENSIVE/ITERM2-SSH-GUIDE.md
        fi
        ;;
      favorites) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/UTILITIES/FAVORITES-SYSTEM.md
        else
          ${PAGER:-less} ~/.zsh/docs/UTILITIES/FAVORITES-SYSTEM.md
        fi
        ;;
      clipboard) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/UTILITIES/CLIPBOARD.md
        else
          ${PAGER:-less} ~/.zsh/docs/UTILITIES/CLIPBOARD.md
        fi
        ;;
      netutils) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/UTILITIES/NETWORK-UTILS.md
        else
          ${PAGER:-less} ~/.zsh/docs/UTILITIES/NETWORK-UTILS.md
        fi
        ;;
      json) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/UTILITIES/JSON-YAML-TOOLS.md
        else
          ${PAGER:-less} ~/.zsh/docs/UTILITIES/JSON-YAML-TOOLS.md
        fi
        ;;
      processes) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/UTILITIES/SYSTEM-MONITOR.md
        else
          ${PAGER:-less} ~/.zsh/docs/UTILITIES/SYSTEM-MONITOR.md
        fi
        ;;
      all) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/REFERENCE/ALL-COMMANDS.md
        else
          ${PAGER:-less} ~/.zsh/docs/REFERENCE/ALL-COMMANDS.md
        fi
        ;;
      cheat) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/REFERENCE/CHEAT-SHEET.md
        else
          ${PAGER:-less} ~/.zsh/docs/REFERENCE/CHEAT-SHEET.md
        fi
        ;;
      vim) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/REFERENCE/VIM-REFERENCE.md
        else
          ${PAGER:-less} ~/.zsh/docs/REFERENCE/VIM-REFERENCE.md
        fi
        ;;
      vimode) 
        if command -v glow &> /dev/null; then
          glow ~/.zsh/docs/DAILY-USE/ZSH-VI-MODE.md
        else
          ${PAGER:-less} ~/.zsh/docs/DAILY-USE/ZSH-VI-MODE.md
        fi
        ;;
      *) echo "Unknown topic: $1. Run 'th' to see all topics." ;;
    esac
  fi
}

# Tab completion for termhelp command - proper zsh style with categories
_termhelp() {
  local -a topics
  topics=(
    'fzf:Fuzzy finding'
    'dirs:Directory jumping'
    'history:Command history'
    'files:File utilities'
    'modern:Modern CLI tools'
    'python:Python & asdf version management'
    'git:Git workflow'
    'docker:Docker & Kubernetes'
    'vscode:VSCode integration'
    'devtools:Dev utilities'
    'tui:TUI apps (btop, lazygit, gum)'
    'github:GitHub CLI toolkit'
    'network:Network toolkit'
    'aws:AWS SSO toolkit'
    'iterm2:iTerm2 + SSH guide'
    'ssh:SSH tunnels & proxies'
    'clipboard:Clipboard functions'
    'netutils:Network utilities'
    'json:JSON/YAML tools'
    'processes:Process management'
    'vim:Vim reference guide'
    'vimode:Shell vi mode guide'
    'all:All commands A-Z'
    'cheat:Cheat sheet'
  )
  _describe 'help topic' topics
}

# Register completion
compdef _termhelp termhelp
compdef _termhelp th
compdef _termhelp thelp
compdef _termhelp myz

# Convenient aliases
alias th='termhelp'
alias thelp='termhelp'

# Favorites system aliases (defined after favorites.zsh is sourced)
alias dev-tools='fav'
alias dev-tools-edit='favedit'


# Disable bracketed paste to prevent paste issues
unset zle_bracketed_paste

# ============================================================================
# EXTERNAL EXTENSIONS HOOK
# ============================================================================
# Allows external projects to add functionality without modifying this file.
# Projects install *.zsh files to ~/.zsh/extensions.d/ and they load here.
# Loaded BEFORE ~/.zshrc_hubers so user can override extension aliases.
# See: ~/hubers-devtools-system/docs/EXTENSION-SYSTEM.md
# ============================================================================

if [[ -d "$HOME/.zsh/extensions.d" ]]; then
  for _ext in "$HOME/.zsh/extensions.d"/*.zsh(N); do
    [[ -f "$_ext" ]] && source "$_ext"
  done
  unset _ext
fi

# ============================================================================
# FAVORITES STARTUP - Called AFTER extensions so plugin favorites are available
# ============================================================================
# Extensions can define _pluginname_favorites() functions that will be
# discovered and displayed by _show_extension_favorites()
# ============================================================================
if type _favorites_startup &>/dev/null; then
  _favorites_startup
fi

# ============================================================================
# USER CUSTOMIZATIONS - DO NOT EDIT ABOVE THIS LINE
# ============================================================================
# This section sources your personal customizations from ~/.zshrc_hubers
#
# Add YOUR custom aliases, functions, and configurations to:
#   ~/.zshrc_hubers
#
# That file will NEVER be overwritten by the installer, so your customizations
# are safe even when you update or reinstall the terminal configuration.
#
# The installer will create ~/.zshrc_hubers with a helpful template if it
# doesn't exist, but will never touch it again after that.
# ============================================================================

if [ -f ~/.zshrc_hubers ]; then
  source ~/.zshrc_hubers
fi
