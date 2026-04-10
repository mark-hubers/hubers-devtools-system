# ============================================================================
# GitHub CLI Toolkit — UI Helpers
# Shared output formatting primitives
# ============================================================================

## Standard separator width
_GH_UI_WIDTH=57

## Print a horizontal rule
_gh_rule() {
   printf '%*s\n' "$_GH_UI_WIDTH" '' | tr ' ' '━'
}

## Print a light rule (for table rows)
_gh_rule_light() {
   printf '%*s\n' "$_GH_UI_WIDTH" '' | tr ' ' '─'
}

## Print a title with rule
_gh_title() {
   echo "$1"
   _gh_rule
}

## Print a key-value pair
_gh_kv() {
   local key="$1" val="$2" width="${3:-14}"
   printf "  %-${width}s %s\n" "$key:" "$val"
}

## Shared flag parsing for --json, --dry-run, --visibility, --repos
## Sets: _GH_F_JSON, _GH_F_DRY, _GH_F_VIS, _GH_F_REPOS
## Returns remaining positional args via _GH_F_POS array
_gh_flags_reset() {
   _GH_F_JSON=0
   _GH_F_DRY=0
   _GH_F_VIS=""
   _GH_F_REPOS=""
   _GH_F_ROLE=""
   _GH_F_PARENT=""
   _GH_F_DESC=""
   _GH_F_NO_MEMBERS=0
   _GH_F_NO_REPOS=0
   _GH_F_TODAY=0
   _GH_F_PROFILE=""
   _GH_F_YES=0
   _GH_F_POS=()
}

_gh_flags_parse() {
   _gh_flags_reset
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --json)       _GH_F_JSON=1; shift ;;
         --dry-run)    _GH_F_DRY=1; shift ;;
         --visibility) _GH_F_VIS="$2"; shift 2 ;;
         --repos)      _GH_F_REPOS="$2"; shift 2 ;;
         --role)       _GH_F_ROLE="$2"; shift 2 ;;
         --parent)     _GH_F_PARENT="$2"; shift 2 ;;
         --description) _GH_F_DESC="$2"; shift 2 ;;
         --no-members) _GH_F_NO_MEMBERS=1; shift ;;
         --no-repos)   _GH_F_NO_REPOS=1; shift ;;
         --today)      _GH_F_TODAY=1; shift ;;
         --profile)    _GH_F_PROFILE="$2"; shift 2 ;;
         --yes)        _GH_F_YES=1; shift ;;
         *)            _GH_F_POS+=("$1"); shift ;;
      esac
   done
}
