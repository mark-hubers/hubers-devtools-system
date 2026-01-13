# ============================================================================
# PROJECT STATUS - Auto-show status when entering project folders
# ============================================================================

# Show project status when cd'ing into a folder with PROJECT-STATUS.md
_show_project_status() {
    local status_file="$PWD/PROJECT-STATUS.md"

    if [[ -f "$status_file" ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        # Show first 20 lines (the summary part)
        head -25 "$status_file" | tail -24
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "💡 Full status: cat PROJECT-STATUS.md"
        echo "💡 Resume Claude: claude --continue"
        echo ""
    fi
}

# Hook into cd
autoload -Uz add-zsh-hook

# Create wrapper for cd
_cd_with_status() {
    # Actually change directory
    builtin cd "$@" || return
    # Show status if exists
    _show_project_status
}

# Only show on manual cd, not on shell startup spam
# Use chpwd hook which fires after directory change
chpwd() {
    _show_project_status
}

# Command to manually show status
project-status() {
    if [[ -f "PROJECT-STATUS.md" ]]; then
        cat "PROJECT-STATUS.md"
    else
        echo "No PROJECT-STATUS.md in current directory"
        echo ""
        echo "Create one with: project-status-init"
    fi
}

# Command to create a new status file
project-status-init() {
    if [[ -f "PROJECT-STATUS.md" ]]; then
        echo "PROJECT-STATUS.md already exists!"
        echo "Edit it with: $EDITOR PROJECT-STATUS.md"
        return 1
    fi

    local project_name=$(basename "$PWD")

    cat > PROJECT-STATUS.md << EOF
# Project Status: $project_name

## Last Session
**Date:** $(date +%Y-%m-%d)
**What we did:**
-

## Next Up
- [ ]

## Quick Resume
\`\`\`bash
claude --continue
\`\`\`

## Key Files
-

## Tips
-
EOF

    echo "✅ Created PROJECT-STATUS.md"
    echo "Edit it with: $EDITOR PROJECT-STATUS.md"
}

# Command to update the date in status file
project-status-touch() {
    if [[ ! -f "PROJECT-STATUS.md" ]]; then
        echo "No PROJECT-STATUS.md found"
        return 1
    fi

    # Update the date line
    local today=$(date +%Y-%m-%d)
    sed -i '' "s/\*\*Date:\*\* [0-9-]*/\*\*Date:\*\* $today/" PROJECT-STATUS.md
    echo "✅ Updated date to $today"
}

# Alias for quick access
alias pst='project-status'
alias pst-init='project-status-init'
alias pst-edit='${EDITOR:-nano} PROJECT-STATUS.md'
