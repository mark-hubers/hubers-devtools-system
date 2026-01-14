#!/bin/zsh
# ============================================================================
# Test Utilities - Testing Framework for hubers-devtools
# ============================================================================
# Source this in test scripts for consistent assertions and output.
#
# Usage:
#   source "$DEVTOOLS_DIR/lib/test-utils.sh"
#
# Provides:
#   - Test assertions (assert_command_exists, assert_file_exists, etc.)
#   - Test counters (TEST_PASSED, TEST_FAILED, TEST_SKIPPED)
#   - Test summary (print_test_summary)
# ============================================================================

# Get script directory and source setup-utils for colors/helpers
_TEST_UTILS_DIR="${0:a:h}"
source "$_TEST_UTILS_DIR/setup-utils.sh"

# ============================================================================
# Test Counters
# ============================================================================

TEST_PASSED=0
TEST_FAILED=0
TEST_SKIPPED=0

# ============================================================================
# Test Assertions
# ============================================================================

# Assert command exists in PATH
assert_command_exists() {
    local cmd="$1"
    local desc="${2:-Command '$cmd' exists}"

    if has_command "$cmd"; then
        ((TEST_PASSED++))
        success "$desc"
        return 0
    else
        ((TEST_FAILED++))
        fail "$desc"
        return 1
    fi
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    local desc="${2:-File '$file' exists}"

    if [[ -f "$file" ]]; then
        ((TEST_PASSED++))
        success "$desc"
        return 0
    else
        ((TEST_FAILED++))
        fail "$desc"
        return 1
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    local desc="${2:-Directory '$dir' exists}"

    if [[ -d "$dir" ]]; then
        ((TEST_PASSED++))
        success "$desc"
        return 0
    else
        ((TEST_FAILED++))
        fail "$desc"
        return 1
    fi
}

# Assert directory is in PATH
assert_in_path() {
    local dir="$1"
    local desc="${2:-Directory '$dir' is in PATH}"

    if [[ ":$PATH:" == *":$dir:"* ]]; then
        ((TEST_PASSED++))
        success "$desc"
        return 0
    else
        ((TEST_FAILED++))
        fail "$desc"
        return 1
    fi
}

# Assert function is defined
assert_function_exists() {
    local func="$1"
    local desc="${2:-Function '$func' is defined}"

    if typeset -f "$func" &>/dev/null; then
        ((TEST_PASSED++))
        success "$desc"
        return 0
    else
        ((TEST_FAILED++))
        fail "$desc"
        return 1
    fi
}

# Assert alias is defined
assert_alias_exists() {
    local name="$1"
    local desc="${2:-Alias '$name' is defined}"

    if alias "$name" &>/dev/null; then
        ((TEST_PASSED++))
        success "$desc"
        return 0
    else
        ((TEST_FAILED++))
        fail "$desc"
        return 1
    fi
}

# Assert pattern exists in file
assert_line_in_file() {
    local file="$1"
    local pattern="$2"
    local desc="${3:-Pattern found in '$file'}"

    if [[ ! -f "$file" ]]; then
        ((TEST_FAILED++))
        fail "$desc (file not found)"
        return 1
    fi

    if grep -qE "$pattern" "$file" 2>/dev/null; then
        ((TEST_PASSED++))
        success "$desc"
        return 0
    else
        ((TEST_FAILED++))
        fail "$desc"
        return 1
    fi
}

# Assert environment variable is set
assert_env_set() {
    local var="$1"
    local desc="${2:-Environment variable '$var' is set}"

    if [[ -n "${(P)var}" ]]; then
        ((TEST_PASSED++))
        success "$desc"
        return 0
    else
        ((TEST_FAILED++))
        fail "$desc"
        return 1
    fi
}

# ============================================================================
# Test Helpers
# ============================================================================

# Skip a test with reason
skip_test() {
    local reason="$1"
    ((TEST_SKIPPED++))
    skip "$reason"
}

# Pass a test manually
pass_test() {
    local desc="$1"
    ((TEST_PASSED++))
    success "$desc"
}

# Fail a test manually
fail_test() {
    local desc="$1"
    ((TEST_FAILED++))
    fail "$desc"
}

# ============================================================================
# Test Summary
# ============================================================================

print_test_summary() {
    echo ""
    echo -e "${BOLD}════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}  Test Summary${RESET}"
    echo -e "${BOLD}════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${GREEN}Passed:${RESET}  $TEST_PASSED"
    echo -e "  ${RED}Failed:${RESET}  $TEST_FAILED"
    echo -e "  ${DIM}Skipped:${RESET} $TEST_SKIPPED"
    echo ""

    local total=$((TEST_PASSED + TEST_FAILED))

    if [[ $TEST_FAILED -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}✓ All $total tests passed!${RESET}"
        echo ""
        return 0
    else
        echo -e "  ${RED}${BOLD}✗ $TEST_FAILED of $total tests failed${RESET}"
        echo ""
        return 1
    fi
}

# ============================================================================
# Test Header
# ============================================================================

print_test_header() {
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET}  ${BOLD}🧪 hubers-devtools Test Suite${RESET}                               ${BOLD}${CYAN}║${RESET}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}
