#!/bin/zsh
# ============================================================================
# Test Runner - Main orchestrator for hubers-devtools tests
# ============================================================================
# Usage:
#   ./test-runner.sh           # Run all tests
#   ./test-runner.sh path      # Run specific test
#   ./test-runner.sh tools     # Run specific test
# ============================================================================

# Get script directory
SCRIPT_DIR="${0:a:h}"
DEVTOOLS_DIR="${SCRIPT_DIR:h}"

# Source test utilities
source "$DEVTOOLS_DIR/lib/test-utils.sh"

# ============================================================================
# Load Test Modules
# ============================================================================

load_test_modules() {
    for test_file in "$SCRIPT_DIR/tests.d"/*.sh; do
        [[ -f "$test_file" ]] && source "$test_file"
    done
}

# ============================================================================
# Run All Tests
# ============================================================================

run_all_tests() {
    print_test_header

    # Load all test modules
    load_test_modules

    # Run each test function in order
    test_path
    test_aliases
    test_core_tools
    test_favorites
    test_plugins
    test_config

    # Print summary and exit with appropriate code
    print_test_summary
}

# ============================================================================
# Run Single Test
# ============================================================================

run_single_test() {
    local test_name="$1"

    print_test_header

    # Load all test modules (needed for helpers)
    load_test_modules

    case "$test_name" in
        path)
            test_path
            ;;
        aliases)
            test_aliases
            ;;
        tools|core-tools)
            test_core_tools
            ;;
        favorites|fav)
            test_favorites
            ;;
        plugins|extensions)
            test_plugins
            ;;
        config|preservation)
            test_config
            ;;
        *)
            echo "Unknown test: $test_name"
            echo ""
            echo "Available tests:"
            echo "  path        - PATH configuration"
            echo "  aliases     - Aliases and functions"
            echo "  tools       - Core tool availability"
            echo "  favorites   - Favorites system"
            echo "  plugins     - Plugin detection"
            echo "  config      - Configuration preservation"
            echo ""
            exit 1
            ;;
    esac

    print_test_summary
}

# ============================================================================
# Main
# ============================================================================

if [[ -n "$1" ]]; then
    run_single_test "$1"
else
    run_all_tests
fi
