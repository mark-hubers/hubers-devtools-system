#!/bin/zsh
# ============================================================================
# Conflict Detection Tests
# ============================================================================
# Detects alias/function naming conflicts that cause parse errors like:
#   "defining function based on alias 'xxx'"
# ============================================================================

# Get all alias names from config files
_get_all_aliases() {
    local files=(
        "$HOME/.zshrc"
        "$HOME/.zsh/aliases.d"/*.zsh(N)
        "$HOME/.zsh"/*.zsh(N)
        "$HOME/.zsh/extensions.d"/*.zsh(N)
    )
    for f in "${files[@]}"; do
        [[ -f "$f" ]] && grep -oE "^\s*alias\s+[a-zA-Z0-9_-]+=" "$f" 2>/dev/null | sed 's/.*alias\s*//' | sed 's/=//'
    done | sort -u
}

# Get all function names from config files
_get_all_functions() {
    local files=(
        "$HOME/.zshrc"
        "$HOME/.zsh/functions.d"/*.zsh(N)
        "$HOME/.zsh"/*.zsh(N)
        "$HOME/.zsh/extensions.d"/*.zsh(N)
    )
    for f in "${files[@]}"; do
        [[ -f "$f" ]] && grep -oE "^[a-zA-Z0-9_-]+\(\)" "$f" 2>/dev/null | sed 's/()//'
    done | sort -u
}

# Check for alias/function name collisions
_find_alias_function_conflicts() {
    local aliases=($(_get_all_aliases))
    local functions=($(_get_all_functions))
    local conflicts=()

    for alias_name in "${aliases[@]}"; do
        for func_name in "${functions[@]}"; do
            if [[ "$alias_name" == "$func_name" ]]; then
                # Check if the alias is defined BEFORE the function
                # (this is what causes the parse error)
                conflicts+=("$alias_name")
            fi
        done
    done

    printf '%s\n' "${conflicts[@]}" | sort -u
}

# Check for duplicate alias definitions
_find_duplicate_aliases() {
    local files=(
        "$HOME/.zshrc"
        "$HOME/.zsh/aliases.d"/*.zsh(N)
        "$HOME/.zsh"/*.zsh(N)
        "$HOME/.zsh/extensions.d"/*.zsh(N)
    )

    local all_aliases=""
    for f in "${files[@]}"; do
        [[ -f "$f" ]] && all_aliases+=$(grep -oE "^\s*alias\s+[a-zA-Z0-9_-]+=" "$f" 2>/dev/null | sed 's/.*alias\s*//' | sed 's/=//')$'\n'
    done

    echo "$all_aliases" | sort | uniq -d
}

test_conflicts() {
    step "Conflict Detection"

    local conflicts
    local duplicates
    local has_conflicts=0

    # Check for alias/function name conflicts
    conflicts=$(_find_alias_function_conflicts)
    if [[ -n "$conflicts" ]]; then
        has_conflicts=1
        warn_test "Alias/function name conflicts detected!"
        echo "  These names are defined as BOTH alias and function:"
        echo "$conflicts" | while read name; do
            [[ -n "$name" ]] && echo "    - $name"
        done
        echo ""
        echo "  Fix: Add 'unalias $name' before the function definition"
        echo "  Or: Remove the duplicate alias"
    else
        pass_test "No alias/function name conflicts"
    fi

    # Check for duplicate alias definitions
    duplicates=$(_find_duplicate_aliases)
    if [[ -n "$duplicates" ]]; then
        has_conflicts=1
        warn_test "Duplicate alias definitions detected!"
        echo "  These aliases are defined multiple times:"
        echo "$duplicates" | while read name; do
            [[ -n "$name" ]] && echo "    - $name"
        done
        echo ""
        echo "  Tip: Use 'grep -r \"alias $name=\" ~/.zsh/' to find duplicates"
    else
        pass_test "No duplicate alias definitions"
    fi

    # Quick syntax check on key config files
    local syntax_errors=0
    for f in "$HOME/.zsh/functions.d"/_devtools_*.zsh(N); do
        if ! zsh -n "$f" 2>/dev/null; then
            warn_test "Syntax error in: $f"
            syntax_errors=1
        fi
    done

    if [[ $syntax_errors -eq 0 ]]; then
        pass_test "All _devtools_ files pass syntax check"
    fi

    return $has_conflicts
}

# Standalone validation function (can be called directly)
validate_shell_config() {
    echo "🔍 Validating shell configuration..."
    echo ""

    local conflicts=$(_find_alias_function_conflicts)
    local duplicates=$(_find_duplicate_aliases)
    local has_issues=0

    if [[ -n "$conflicts" ]]; then
        has_issues=1
        echo "⚠️  ALIAS/FUNCTION CONFLICTS:"
        echo "   These names are both an alias AND a function:"
        echo "$conflicts" | while read name; do
            [[ -n "$name" ]] && echo "     - $name"
        done
        echo ""
        echo "   This will cause: 'defining function based on alias' error"
        echo "   Fix: Add 'unalias NAME 2>/dev/null' before the function"
        echo ""
    fi

    if [[ -n "$duplicates" ]]; then
        has_issues=1
        echo "⚠️  DUPLICATE ALIASES:"
        echo "   These aliases are defined multiple times:"
        echo "$duplicates" | while read name; do
            [[ -n "$name" ]] && echo "     - $name"
        done
        echo ""
        echo "   Find them: grep -r 'alias NAME=' ~/.zsh/"
        echo ""
    fi

    if [[ $has_issues -eq 0 ]]; then
        echo "✅ No conflicts detected!"
    fi

    return $has_issues
}
