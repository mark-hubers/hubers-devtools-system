#!/bin/zsh
# ============================================================================
# Bootstrap - Legacy Wrapper
# ============================================================================
# This file exists for backwards compatibility.
# The main script is now setup.sh
#
# Both do the same thing - use whichever name you remember!
# ============================================================================

SCRIPT_DIR="${0:a:h}"

echo "Note: bootstrap.sh now calls setup.sh (same functionality)"
echo ""

exec "$SCRIPT_DIR/setup.sh" "$@"
