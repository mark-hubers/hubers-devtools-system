# ORG/REPO SECRET MANAGEMENT
# ====================================
# Wraps GitHub Actions Secrets API. Values are NEVER returned by the API.
# Uses `gh secret set` for creates (handles libsodium encryption).

ghsecret() {
   _gh_check || return 1
   _gh_require_jq || return 1

   local subcmd="$1"
   shift 2>/dev/null

   case "$subcmd" in
      list)   _ghsecret_list "$@" ;;
      set)    _ghsecret_set "$@" ;;
      delete) _ghsecret_delete "$@" ;;
      *)
         echo "🔒 ghsecret — GitHub Actions Secret Management"
         echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
         echo ""
         echo "Usage: ghsecret <command> [arguments]"
         echo ""
         echo "Commands:"
         echo "  list   [target]                          List secrets (names only)"
         echo "  set    <name> [target] [--visibility ..]  Create or update secret"
         echo "  delete <name> [target]                   Delete secret"
         echo ""
         echo "Target: org-name = org scope, owner/repo = repo, omit = current repo"
         echo ""
         echo "Examples:"
         echo "  ghsecret list alvaria-bu"
         echo "  ghsecret set DEPLOY_KEY alvaria-bu --visibility all"
         echo "  ghsecret delete OLD_SECRET alvaria-bu"
         echo ""
         echo "Note: GitHub never returns secret values — only names are visible."
         return 1
         ;;
   esac
}

# --- ghsecret list ---
_ghsecret_list() {
   local target="" json_mode=0
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
         *)      target="$arg" ;;
      esac
   done

   _gh_parse_target "$target" || return 1

   local secrets_api_path
   secrets_api_path="$(_gh_secrets_api_path)" || return 1

   local result
   result=$(_gh_scoped api "$secrets_api_path" --paginate 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "list secrets for $_GH_TARGET_LABEL"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo "$result" | jq '.secrets // []'
      return 0
   fi

   local scope_label
   [[ "$_GH_SCOPE" == "org" ]] && scope_label="Org" || scope_label="Repo"

   echo "🔒 $scope_label Secrets: $_GH_TARGET_LABEL"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

   local count
   count=$(echo "$result" | jq '.secrets | length')

   if [[ "$count" == "0" ]]; then
      echo "  (none)"
   elif [[ "$_GH_SCOPE" == "org" ]]; then
      printf "  %-28s %-14s %s\n" "NAME" "VISIBILITY" "UPDATED"
      echo "  ─────────────────────────── ────────────── ────────────────────"
      echo "$result" | jq -r '.secrets[] | "\(.name)\t\(.visibility)\t\(.updated_at)"' | \
         while IFS=$'\t' read -r name vis updated; do
            printf "  %-28s %-14s %s\n" "$name" "$vis" "${updated%T*}"
         done
   else
      printf "  %-28s %s\n" "NAME" "UPDATED"
      echo "  ─────────────────────────── ────────────────────"
      echo "$result" | jq -r '.secrets[] | "\(.name)\t\(.updated_at)"' | \
         while IFS=$'\t' read -r name updated; do
            printf "  %-28s %s\n" "$name" "${updated%T*}"
         done
   fi

   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  $count secret(s)  (values never shown)"
}

# --- ghsecret set ---
_ghsecret_set() {
   local name="" target="" visibility="" repos="" dry_run=0
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --dry-run) dry_run=1; shift ;;
         --visibility) visibility="$2"; shift 2 ;;
         --repos) repos="$2"; shift 2 ;;
         *)
            if [[ -z "$name" ]]; then
               name="$1"
            else
               target="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$name" ]]; then
      echo "Usage: ghsecret set <name> [target] [--visibility all|private|selected] [--dry-run]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   if [[ $dry_run -eq 1 ]]; then
      echo "[dry-run] Would set secret '$name' on $_GH_TARGET_LABEL"
      echo "  Scope: $_GH_SCOPE"
      [[ -n "$visibility" ]] && echo "  Visibility: $visibility"
      echo "  (value would be prompted interactively)"
      return 0
   fi

   _gh_require_admin || return 1

   ## Read secret value silently
   local secret_value
   echo -n "Enter value for secret '$name': "
   read -s secret_value
   echo ""

   if [[ -z "$secret_value" ]]; then
      echo "✗ Empty value — aborting"
      return 1
   fi

   ## Build gh secret set command args
   local -a cmd_args=("secret" "set" "$name")
   if [[ "$_GH_SCOPE" == "org" ]]; then
      cmd_args+=("--org" "$_GH_TARGET_LABEL")
      if [[ -n "$visibility" ]]; then
         cmd_args+=("--visibility" "$visibility")
         if [[ "$visibility" == "selected" && -n "$repos" ]]; then
            cmd_args+=("--repos" "$repos")
         fi
      else
         echo "✗ Org secret requires --visibility (all, private, or selected)"
         return 1
      fi
   elif [[ "$_GH_SCOPE" == "repo" ]]; then
      cmd_args+=("--repo" "$_GH_TARGET_LABEL")
   fi

   ## Pipe value to gh secret set (handles encryption)
   local result
   result=$(echo "$secret_value" | _gh_scoped "${cmd_args[@]}" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "set secret '$name' on $_GH_TARGET_LABEL"
      return 1
   fi

   echo "✓ Set secret $name on $_GH_TARGET_LABEL"
}

# --- ghsecret delete ---
_ghsecret_delete() {
   local name="" target="" dry_run=0
   for arg in "$@"; do
      case "$arg" in
         --dry-run) dry_run=1 ;;
         *)
            if [[ -z "$name" ]]; then
               name="$arg"
            else
               target="$arg"
            fi
            ;;
      esac
   done

   if [[ -z "$name" ]]; then
      echo "Usage: ghsecret delete <name> [target] [--dry-run]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   local secrets_api_path
   secrets_api_path="$(_gh_secrets_api_path)" || return 1

   if [[ $dry_run -eq 1 ]]; then
      echo "[dry-run] Would delete secret '$name' from $_GH_TARGET_LABEL"
      return 0
   fi

   _gh_require_admin || return 1

   ## Confirm
   echo -n "Delete secret '$name' from $_GH_TARGET_LABEL? (y/n): "
   read -k 1 confirm
   echo ""
   if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "  Cancelled"
      return 0
   fi

   local result
   result=$(_gh_scoped api "$secrets_api_path/$name" --method DELETE 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "delete secret '$name' from $_GH_TARGET_LABEL"
      return 1
   fi

   echo "✓ Deleted secret $name from $_GH_TARGET_LABEL"
}

# ====================================
