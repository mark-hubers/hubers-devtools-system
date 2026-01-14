#!/bin/zsh
# ============================================================================
# Terminal Help System
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# For custom help topics, create your own file without _devtools_ prefix
# ============================================================================

# Helper function to show docs with glow or less
_show_doc() {
  local doc="$1"
  if command -v glow &> /dev/null; then
    glow "$doc"
  else
    ${PAGER:-less} "$doc"
  fi
}

# ============================================================================
# Modern Tools Reference
# ============================================================================

tools() {
  cat << 'EOF'
================================================================================
                    MODERN CLI TOOLS REFERENCE
================================================================================

FILE LISTING (eza replaces ls)
--------------------------------------------------------------------------------
  ls       → List with icons         ll       → Long detailed list
  la       → Show hidden files       lt       → Tree view (2 levels)
  ltr      → Oldest→Newest           lsr      → Real ls -ltr
  llr      → Real ls -la

FILE VIEWING (bat replaces cat)
--------------------------------------------------------------------------------
  cat      → Syntax + line numbers   catp     → Plain cat (original)
  rawcat   → Plain cat               plaincat → No line numbers

TEXT SEARCHING (ripgrep replaces grep)
--------------------------------------------------------------------------------
  rg text  → Search (fast!)          grip     → Case-insensitive search
  grepi    → Case-insensitive        greps    → Case-insensitive

FILE SEARCHING (fd replaces find)
--------------------------------------------------------------------------------
  fd txt   → Find files              fd -e js → Find by extension

DIRECTORY NAVIGATION (zoxide)
--------------------------------------------------------------------------------
  z path   → Smart jump              zi       → Interactive picker
  d        → Directory history

Type 'tools' anytime to see this reference!
================================================================================
EOF
}

alias modern='tools'
alias toolhelp='tools'
alias cmdref='tools'

# ============================================================================
# Interactive Terminal Help
# ============================================================================

termhelp() {
  local topics=(
    "fzf:Fuzzy finding - Tab completion, Ctrl+R, file search"
    "dirs:Directory jumping - Bookmarks, zoxide, never lose folders"
    "history:Command history - h, Ctrl+R, search your past commands"
    "files:File utilities - extract, mkcd, clip, serve"
    "modern:Modern CLI tools - eza, bat, ripgrep, fd"
    "python:Python & asdf - Version management, .tool-versions, Lambda"
    "git:Git workflow - Aliases, shortcuts, git-undo, git-wip"
    "docker:Docker & Kubernetes - Aliases, k9s shortcuts"
    "vscode:VSCode integration - code command shortcuts"
    "devtools:Dev utilities - lazygit, lazydocker, httpie, tldr"
    "tui:TUI apps - Terminal UI tools (btop, lazygit, gum, superfile)"
    "github:GitHub CLI toolkit - 42 commands for PRs, issues, repos"
    "network:Network toolkit - 24 debugging commands (ports, DNS, SSL)"
    "aws:AWS SSO toolkit - 10 commands for AWS management"
    "iterm2:iTerm2 + SSH complete guide - tunnels, proxies, file transfer"
    "ssh:SSH tunnels & proxies - SOCKS, port forward, jump hosts"
    "favorites:Customize startup display - favedit, fav, favoff"
    "clipboard:Clipboard - Copy/paste from terminal"
    "netutils:Network utils - myip, port, killport"
    "json:JSON/YAML tools - jq, yq shortcuts"
    "processes:Process management - psa, psmem shortcuts"
    "vim:Vim reference - Complete Vim command guide with examples"
    "vimode:Shell vi mode - Use Vim keybindings at your prompt"
    "all:All commands A-Z - Complete command reference"
    "cheat:Cheat sheet - One-page quick reference"
  )

  local choice="$1"

  if [[ -z "$choice" ]]; then
    # Interactive mode with fzf
    echo "Terminal Help - Select a topic:"
    echo ""
    choice=$(printf '%s\n' "${topics[@]}" | fzf \
      --height=60% \
      --prompt="Help> " \
      --header="Use arrows to navigate, Enter to select" | cut -d: -f1)
    [[ -z "$choice" ]] && echo "No topic selected" && return 1
    echo ""
  fi

  case "$choice" in
    fzf)        _show_doc ~/.zsh/docs/DAILY-USE/FZF-FUZZY-FINDING.md ;;
    dirs)       _show_doc ~/.zsh/docs/DAILY-USE/DIRECTORY-JUMPING.md ;;
    history)    _show_doc ~/.zsh/docs/DAILY-USE/COMMAND-HISTORY.md ;;
    files)      _show_doc ~/.zsh/docs/DAILY-USE/FILE-TOOLS.md ;;
    modern)     _show_doc ~/.zsh/docs/DAILY-USE/MODERN-CLI-TOOLS.md ;;
    git)        _show_doc ~/.zsh/docs/DEV-TOOLS/GIT-WORKFLOW.md ;;
    docker)     _show_doc ~/.zsh/docs/DEV-TOOLS/DOCKER-KUBERNETES.md ;;
    vscode)     _show_doc ~/.zsh/docs/DEV-TOOLS/VSCODE-INTEGRATION.md ;;
    devtools)   _show_doc ~/.zsh/docs/DEV-TOOLS/DEV-UTILITIES.md ;;
    python)     _show_doc ~/.zsh/docs/DEV-TOOLS/PYTHON-ASDF.md ;;
    tui)        _show_doc ~/.zsh/docs/DEV-TOOLS/TUI-TOOLS.md ;;
    github)     ghhelp 2>/dev/null || echo "GitHub help not available" ;;
    network)    nethelp 2>/dev/null || echo "Network help not available" ;;
    aws)        awshelp 2>/dev/null || echo "AWS help not available" ;;
    iterm2|ssh) _show_doc ~/.zsh/docs/COMPREHENSIVE/ITERM2-SSH-GUIDE.md ;;
    favorites)  _show_doc ~/.zsh/docs/UTILITIES/FAVORITES-SYSTEM.md ;;
    clipboard)  _show_doc ~/.zsh/docs/UTILITIES/CLIPBOARD.md ;;
    netutils)   _show_doc ~/.zsh/docs/UTILITIES/NETWORK-UTILS.md ;;
    json)       _show_doc ~/.zsh/docs/UTILITIES/JSON-YAML-TOOLS.md ;;
    processes)  _show_doc ~/.zsh/docs/UTILITIES/SYSTEM-MONITOR.md ;;
    all)        _show_doc ~/.zsh/docs/REFERENCE/ALL-COMMANDS.md ;;
    cheat)      _show_doc ~/.zsh/docs/REFERENCE/CHEAT-SHEET.md ;;
    vim)        _show_doc ~/.zsh/docs/REFERENCE/VIM-REFERENCE.md ;;
    vimode)     _show_doc ~/.zsh/docs/DAILY-USE/ZSH-VI-MODE.md ;;
    *) echo "Unknown topic: $choice. Run 'th' to see all topics." ;;
  esac
}

# Tab completion for termhelp
_termhelp() {
  local -a topics
  topics=(
    'fzf:Fuzzy finding'
    'dirs:Directory jumping'
    'history:Command history'
    'files:File utilities'
    'modern:Modern CLI tools'
    'python:Python & asdf'
    'git:Git workflow'
    'docker:Docker & Kubernetes'
    'vscode:VSCode integration'
    'devtools:Dev utilities'
    'tui:TUI apps'
    'github:GitHub CLI toolkit'
    'network:Network toolkit'
    'aws:AWS SSO toolkit'
    'iterm2:iTerm2 + SSH guide'
    'ssh:SSH tunnels & proxies'
    'favorites:Favorites system'
    'clipboard:Clipboard functions'
    'netutils:Network utilities'
    'json:JSON/YAML tools'
    'processes:Process management'
    'vim:Vim reference'
    'vimode:Shell vi mode'
    'all:All commands A-Z'
    'cheat:Cheat sheet'
  )
  _describe 'help topic' topics
}

compdef _termhelp termhelp
compdef _termhelp th
compdef _termhelp thelp

alias th='termhelp'
alias thelp='termhelp'
