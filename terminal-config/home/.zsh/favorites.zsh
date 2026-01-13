#!/bin/zsh
# ============================================================================
# My Favorites - Customizable Terminal Startup Display
# ============================================================================
FAVORITES_FILE="${HOME}/.zsh/my-favorites.txt"
FAVORITES_ENABLED="${HOME}/.zsh/.favorites_enabled"

# Colors
_fav_colors() {
    C_RESET='\033[0m'
    C_BOLD='\033[1m'
    C_DIM='\033[2m'
    C_CYAN='\033[36m'
    C_YELLOW='\033[33m'
    C_GREEN='\033[32m'
    C_MAGENTA='\033[35m'
    C_WHITE='\033[97m'
    C_GRAY='\033[90m'
}

# Initialize favorites file with defaults if it doesn't exist
_favorites_init() {
    _fav_colors
    if [[ ! -f "$FAVORITES_FILE" ]]; then
        cat > "$FAVORITES_FILE" << 'FAVEOF'
#= HELP & DOCS
th <TAB>           | Browse all help topics        || th iterm2       | iTerm2 + SSH guide
th git             | Git reference                 || th ssh          | SSH tunnels guide
th fzf             | FZF guide                     || th aws          | AWS toolkit help
#
#= NAVIGATION
bm <n>          | Jump to bookmark              || bm <n> .     | Save current dir
bm                 | List bookmarks (fzf)          || bmedit          | Edit bookmarks
z <partial>        | Smart jump (zoxide)           || z -             | Previous dir
#
#= SSH & REMOTE
socks <host>       | SOCKS proxy (browse via host) || tunnels         | List active tunnels
forward 8080 h:p j | Port forward via jump         || tunnel-kill     | Kill all tunnels
push file host:~   | Upload file (rsync)           || pull host:f .   | Download file
ssh-tips           | SSH config examples           || ssh-setup       | Generate SSH key
#
#= DEVSETUP
devsetup check     | Show installed/missing        || devsetup add <x>| Install tool
devsetup search    | Find tools by name            || devsetup list   | List all tools
#
#= TUI APPS
lazygit            | Git terminal UI               || k9s             | Kubernetes TUI
lazydocker         | Docker terminal UI            || btop            | System monitor TUI
glow file.md       | Markdown viewer               || gum choose      | Interactive prompts
superfile          | File manager TUI              || posting         | API testing TUI
#
#= SEARCH (rg & fd)
rg <pat>           | Grep (ripgrep)                || rg -i <pat>     | Case insensitive
rg <pat> -t py     | Search Python files           || rg -l <pat>     | List files only
fd <n>          | Find files by name            || fd -e md        | Find by extension
#
#= FZF FINDERS
ff                 | File finder + preview         || fif <pat>       | Grep in files
fh                 | Command history               || fkill           | Kill process
Ctrl+T             | Insert file path              || Ctrl+R          | History search
#
#= GIT
lazygit            | Git terminal UI               || gs              | git status
gp                 | git push                      || gpl             | git pull
gco <branch>       | checkout branch               || gcob <n>     | checkout -b new
glog               | Pretty log (30)               || gd              | git diff
#
#= GITHUB CLI
ghlist             | List GitHub accounts          || ghadd           | Add account (guided)
ghtest             | Test current account          || ghswitch        | Switch accounts
ghauto             | Auto-switch by repo           || ghwho           | Current vs required
ghprs              | Browse PRs (fzf)              || ghpr            | Create PR
ghhelp             | All GitHub commands           || th github       | GitHub docs
#
#= KUBERNETES
k9s                | K8s terminal UI               || kctx            | Switch context
kns                | Switch namespace              || kgp             | get pods
kl <pod>           | Pod logs                      || kex <pod>       | Exec into pod
#
#= FILES & VIEWING
bat <file>         | Cat + syntax highlight        || ll              | Better ls (eza)
tree -L 2          | Tree depth 2                  || cat f | jq .    | Pretty JSON
#
#= SSH FILE TRANSFER (iTerm2)
Cmd+Click file     | Download from SSH session     || Drag file in    | Upload to SSH dir
scp h:~/f .        | Download file                 || scp f host:~/   | Upload file
push file host:~   | Upload + progress (rsync)     || pull host:f .   | Download + progress
sync-to dir h:dir  | Sync folder TO remote         || sync-from h:d d | Sync folder FROM
#
#= SSH TUNNELS & PROXY
socks work         | Browse web via work laptop    || tunnels         | List active tunnels
forward 8080 h:p j | Port forward via jump         || tunnel-kill     | Kill all tunnels
ssh-tips           | SSH config examples           || ssh-setup       | Generate SSH key
#
#= MARKDOWN
mdpdf file.md      | Convert to PDF                || mdview file.md  | View in terminal
mdhtml file.md     | Convert to HTML               || mdslack file.md | Format for Slack
#
#= VIM COMMANDS
:123 or 123G       | Jump to line 123              || gg / G          | Top/end of file
/pattern           | Search forward                || n / N           | Next/prev match
:%s/old/new/gc     | Replace all (with confirm)    || :noh            | Clear search highlight
%                  | Jump to matching bracket      || f{char}         | Find char in line
ciw / ci"          | Change word/inside quotes     || diw / di"       | Delete word/inside quotes
:set number        | Show line numbers             || 0 / $           | Start/end of line
:g/pattern/d       | Delete all lines matching     || :10,20s/old/new/g | Replace in line range
#
#= SHELL VI MODE (Press ESC!)
ESC then w/b       | Jump word forward/back        || ESC then 0/$    | Start/end of line
ESC then ciw       | Change word at cursor         || ESC then dw     | Delete word
ESC then /text     | Search history backward       || ESC then n/N    | Next/prev match
vimode / emacsmode | Toggle vi mode on/off         || Ctrl+R          | History search (always)
th vim             | Full Vim reference guide      || th vimode       | Shell vi mode guide
#
#= NETWORK
myip               | Show local + public IPv4      || ports           | Listening ports
awslogin           | AWS SSO login                 || awswho          | AWS identity
#
FAVEOF
        echo "✅ Created favorites file: $FAVORITES_FILE"
    fi
    [[ ! -f "$FAVORITES_ENABLED" ]] && touch "$FAVORITES_ENABLED"
}

# Show favorites content (without footer - used by startup to allow extensions before footer)
_fav_content() {
    _favorites_init
    _fav_colors

    # Display configuration - DISPLAY_WIDTH = inner width of box (between borders)
    local DISPLAY_WIDTH=105

    echo ""
    echo -e "${C_CYAN}${C_BOLD}╔═════════════════════════════════════════════════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}║${C_RESET} ${C_YELLOW}${C_BOLD}⭐ MY FAVORITE COMMANDS${C_RESET}                                                    ${C_DIM}favedit${C_RESET}${C_DIM}=edit  ${C_DIM}favoff${C_RESET}${C_DIM}=hide${C_RESET} ${C_CYAN}${C_BOLD}║${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}╚═════════════════════════════════════════════════════════════════════════════════════════════════════════╝${C_RESET}"

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        # Section headers with DYNAMIC PADDING
        if [[ "$line" =~ ^#=[[:space:]]*(.+) ]]; then
            local section="${match[1]}"

            # Calculate dynamic padding for section headers
            local section_len=${#section}           # Length of section title
            local prefix_len=5                      # " ─── " = space + 3 dashes + space = 5 chars
            local suffix_len=1                      # Space after section name

            # Calculate how many dashes needed to reach DISPLAY_WIDTH
            local dash_count=$((DISPLAY_WIDTH - section_len - prefix_len - suffix_len))

            # Prevent negative dash count (if section title is too long)
            if (( dash_count < 5 )); then
                dash_count=5
            fi

            # Generate the exact number of dashes needed
            local dashes=$(printf '─%.0s' $(seq 1 $dash_count))

            # Display with perfect alignment
            echo -e "${C_MAGENTA}${C_BOLD} ─── ${section} ${dashes}${C_RESET}"

        elif [[ "$line" =~ ^# ]]; then
            continue
        else
            # Parse columns
            local col1="${line%%||*}"
            local col2="${line#*||}"

            local cmd1="${col1%%|*}"; local desc1="${col1#*|}"
            cmd1="${cmd1%% }"; cmd1="${cmd1## }"; desc1="${desc1%% }"; desc1="${desc1## }"

            local cmd2="" desc2=""
            if [[ "$col2" != "$line" && -n "$col2" ]]; then
                cmd2="${col2%%|*}"; desc2="${col2#*|}"
                cmd2="${cmd2%% }"; cmd2="${cmd2## }"; desc2="${desc2%% }"; desc2="${desc2## }"
            fi

            if [[ -n "$cmd1" ]]; then
                printf "  ${C_GREEN}%-18s${C_RESET} ${C_WHITE}%-28s${C_RESET}" "$cmd1" "$desc1"
                if [[ -n "$cmd2" ]]; then
                    printf " ${C_GRAY}│${C_RESET} ${C_GREEN}%-15s${C_RESET} ${C_WHITE}%s${C_RESET}" "$cmd2" "$desc2"
                fi
                echo ""
            fi
        fi
    done < "$FAVORITES_FILE"
}

# Show favorites footer
_fav_footer() {
    _fav_colors
    echo -e "${C_CYAN}═════════════════════════════════════════════════════════════════════════════════════════════════════════════${C_RESET}"
    echo -e " ${C_DIM}💡${C_RESET} ${C_YELLOW}th <TAB>${C_RESET} ${C_DIM}browse docs${C_RESET}  ${C_GRAY}│${C_RESET}  ${C_YELLOW}favedit${C_RESET} ${C_DIM}customize${C_RESET}  ${C_GRAY}│${C_RESET}  ${C_YELLOW}favoff${C_RESET} ${C_DIM}disable at startup${C_RESET}"
    echo ""
}

# Show favorites (colorful 2-column format) - standalone command
fav() {
    _fav_content
    _fav_footer
}

favedit() {
    _favorites_init
    
    # Call editors directly - no variable expansion issues
    if command -v code &> /dev/null; then
        code --wait "$FAVORITES_FILE"
    elif command -v vim &> /dev/null; then
        vim "$FAVORITES_FILE"
    elif command -v vi &> /dev/null; then
        vi "$FAVORITES_FILE"
    else
        nano "$FAVORITES_FILE"
    fi
    
    echo "✅ Saved. Run 'fav' to preview."
}

favadd() {
    _favorites_init
    [[ -z "$1" ]] && { echo "Usage: favadd \"cmd | desc\""; return 1; }
    echo "$1" >> "$FAVORITES_FILE"
    echo "✅ Added: $1"
}

favoff() { rm -f "$FAVORITES_ENABLED"; echo "✅ Disabled at startup (run 'fav' anytime)"; }
favon() { touch "$FAVORITES_ENABLED"; echo "✅ Enabled at startup"; }

_favorites_startup() {
    _favorites_init
    [[ -f "$FAVORITES_ENABLED" ]] || return 0

    # Check if we're in an SSH session - show short version
    if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" ]]; then
        fav_short
    else
        # Show: main content → extension favorites → footer
        _fav_content
        _show_extension_favorites
        _fav_footer
    fi
}

# Short version for SSH sessions
fav_short() {
    _favorites_init
    _fav_colors

    echo ""
    echo -e "${C_CYAN}${C_BOLD}╔═══════════════════════════════════════════════════════════════╗${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}║${C_RESET} ${C_YELLOW}${C_BOLD}⭐ QUICK COMMANDS${C_RESET}                    ${C_DIM}favfull = show all${C_RESET} ${C_CYAN}${C_BOLD}║${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}╚═══════════════════════════════════════════════════════════════╝${C_RESET}"

    echo -e "${C_MAGENTA}${C_BOLD} ─── ESSENTIALS ────────────────────────────────────────────────${C_RESET}"
    printf "  ${C_GREEN}%-18s${C_RESET} ${C_WHITE}%-28s${C_RESET} ${C_GRAY}│${C_RESET} ${C_GREEN}%-15s${C_RESET} ${C_WHITE}%s${C_RESET}\n" "th <TAB>" "Browse help topics" "fav" "Show favorites"
    printf "  ${C_GREEN}%-18s${C_RESET} ${C_WHITE}%-28s${C_RESET} ${C_GRAY}│${C_RESET} ${C_GREEN}%-15s${C_RESET} ${C_WHITE}%s${C_RESET}\n" "z <partial>" "Smart jump (zoxide)" "ll" "List files (eza)"
    printf "  ${C_GREEN}%-18s${C_RESET} ${C_WHITE}%-28s${C_RESET} ${C_GRAY}│${C_RESET} ${C_GREEN}%-15s${C_RESET} ${C_WHITE}%s${C_RESET}\n" "rg <pattern>" "Search in files" "fd <name>" "Find files"
    printf "  ${C_GREEN}%-18s${C_RESET} ${C_WHITE}%-28s${C_RESET} ${C_GRAY}│${C_RESET} ${C_GREEN}%-15s${C_RESET} ${C_WHITE}%s${C_RESET}\n" "lazygit" "Git TUI" "gs" "git status"

    echo -e "${C_CYAN}═══════════════════════════════════════════════════════════════════${C_RESET}"
    echo -e " ${C_DIM}💡${C_RESET} ${C_YELLOW}favfull${C_RESET} ${C_DIM}show complete listing${C_RESET}  ${C_GRAY}│${C_RESET}  ${C_YELLOW}th <TAB>${C_RESET} ${C_DIM}browse all help${C_RESET}"
    echo ""
}

# Show full favorites (for use in SSH when you want everything)
favfull() {
    _fav_content
    _show_extension_favorites
    _fav_footer
}

# ============================================================================
# Extension Favorites - Auto-display favorites from extensions.d/
#
# Extensions define a function like:
#   _myext_favorites() {
#       cat << 'EOF'
#       MY EXTENSION
#       cmd1 | Description one
#       cmd2 | Description two
#       EOF
#   }
#
# First line = section header, rest = command | description pairs
# System formats into 2 columns automatically
# ============================================================================

_show_extension_favorites() {
    _fav_colors
    local DISPLAY_WIDTH=105

    # Find all _*_favorites functions from extensions
    local funcs=(${(k)functions[(I)_*_favorites]})

    for func in "${funcs[@]}"; do
        # Skip our own internal functions
        [[ "$func" == "_show_extension_favorites" ]] && continue
        [[ "$func" == "_favorites_init" ]] && continue
        [[ "$func" == "_favorites_startup" ]] && continue
        [[ "$func" == "_fav_colors" ]] && continue
        [[ "$func" == "_work_fav_colors" ]] && continue

        # Get output from the function
        local output="$($func 2>/dev/null)"
        [[ -z "$output" ]] && continue

        # Parse: first line = header, rest = commands
        local header=""
        local commands=()
        local first=true

        while IFS= read -r line; do
            # Skip empty lines
            [[ -z "${line// /}" ]] && continue

            if $first; then
                header="$line"
                first=false
            else
                commands+=("$line")
            fi
        done <<< "$output"

        [[ -z "$header" ]] && continue

        # Display section header
        local header_clean="${header## }"  # trim leading spaces
        header_clean="${header_clean%% }"  # trim trailing spaces
        local header_len=${#header_clean}
        local prefix_len=5
        local suffix_len=1
        local dash_count=$((DISPLAY_WIDTH - header_len - prefix_len - suffix_len))
        (( dash_count < 5 )) && dash_count=5
        local dashes=$(printf '─%.0s' $(seq 1 $dash_count))

        echo -e "${C_MAGENTA}${C_BOLD} ─── ${header_clean} ${dashes}${C_RESET}"

        # Display commands in 2 columns
        local i=0
        local total=${#commands[@]}

        while (( i < total )); do
            local line1="${commands[$((i+1))]}"
            local line2="${commands[$((i+2))]}"

            # Parse line1: cmd | desc
            local cmd1="${line1%%|*}"
            local desc1="${line1#*|}"
            cmd1="${cmd1## }"; cmd1="${cmd1%% }"
            desc1="${desc1## }"; desc1="${desc1%% }"

            if [[ -n "$cmd1" ]]; then
                printf "  ${C_GREEN}%-18s${C_RESET} ${C_WHITE}%-28s${C_RESET}" "$cmd1" "$desc1"

                # Parse line2 if exists
                if [[ -n "$line2" ]]; then
                    local cmd2="${line2%%|*}"
                    local desc2="${line2#*|}"
                    cmd2="${cmd2## }"; cmd2="${cmd2%% }"
                    desc2="${desc2## }"; desc2="${desc2%% }"

                    if [[ -n "$cmd2" ]]; then
                        printf " ${C_GRAY}│${C_RESET} ${C_GREEN}%-15s${C_RESET} ${C_WHITE}%s${C_RESET}" "$cmd2" "$desc2"
                    fi
                    (( i += 2 ))
                else
                    (( i += 1 ))
                fi
                echo ""
            else
                (( i += 1 ))
            fi
        done
    done
}

# NOTE: _favorites_startup is called from .zshrc AFTER extensions are loaded
# This ensures plugin favorites functions (like _work_tunnel_favorites) are available
