ghvar() {
   _gh_check || return 1
   _gh_require_jq || return 1

   local subcmd="$1"
   shift 2>/dev/null

   case "$subcmd" in
      list)
         _ghvar_list "$@"
         ;;
      get)
         _ghvar_get "$@"
         ;;
      set)
         _ghvar_set "$@"
         ;;
      delete)
         _ghvar_delete "$@"
         ;;
      import)
         _ghvar_import "$@"
         ;;
      *)
         echo "📋 ghvar — GitHub Actions Variable Management"
         echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
         echo ""
         echo "Usage: ghvar <command> [arguments]"
         echo ""
         echo "Commands:"
         echo "  list   [target]                          List variables"
         echo "  get    <name> [target]                   Show variable details"
         echo "  set    <name> <value> [target] [flags]   Create or update variable"
         echo "  delete <name> [target]                   Delete variable"
         echo "  import <file> <target> [flags]            Bulk set from KEY=VALUE file"
         echo ""
         echo "Target (positional — auto-detected if omitted):"
         echo "  alvaria-bu          Org scope (uses admin token)"
         echo "  alvaria-bu/my-repo  Repo scope"
         echo "  (omitted)           Current repo from git remote"
         echo ""
         echo "Flags (set only):"
         echo "  --visibility all|private|selected   Org variable visibility"
         echo "  --repos repo1,repo2                 Repos for selected visibility"
         echo ""
         echo "Options:"
         echo "  --json              Machine-readable output"
         echo "  --dry-run           Show what would happen without making changes"
         echo ""
         echo "Examples:"
         echo "  ghvar list alvaria-bu"
         echo "  ghvar get AWS_REGION alvaria-bu"
         echo "  ghvar set DEPLOY_ENV staging alvaria-bu --visibility all"
         echo "  ghvar set MY_VAR value123"
         echo "  ghvar delete OLD_VAR alvaria-bu"
         echo "  ghvar list --json | jq '.[] | .name'"
         return 1
         ;;
   esac
}

# --- ghvar list ---
_ghvar_list() {
   local target="" json_mode=0
   ## Parse args
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
         *)      target="$arg" ;;
      esac
   done

   _gh_parse_target "$target" || return 1

   local result
   result=$(_gh_scoped api "$_GH_API_PATH" --paginate 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "list variables for $_GH_TARGET_LABEL"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo "$result" | jq '.variables // []'
      return 0
   fi

   local scope_label
   [[ "$_GH_SCOPE" == "org" ]] && scope_label="Org" || scope_label="Repo"

   echo "📋 $scope_label Variables: $_GH_TARGET_LABEL"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

   local count
   count=$(echo "$result" | jq '.variables | length')

   if [[ "$count" == "0" ]]; then
      echo "  (none)"
   elif [[ "$_GH_SCOPE" == "org" ]]; then
      printf "  %-28s %-30s %s\n" "NAME" "VALUE" "VISIBILITY"
      echo "  ─────────────────────────── ────────────────────────────── ──────────"
      echo "$result" | jq -r '.variables[] | "  \(.name)\t\(.value)\t\(.visibility)"' | \
         while IFS=$'\t' read -r name val vis; do
            printf "  %-28s %-30s %s\n" "$name" "$val" "$vis"
         done
   else
      printf "  %-28s %s\n" "NAME" "VALUE"
      echo "  ─────────────────────────── ──────────────────────────────"
      echo "$result" | jq -r '.variables[] | "  \(.name)\t\(.value)"' | \
         while IFS=$'\t' read -r name val; do
            printf "  %-28s %s\n" "$name" "$val"
         done
   fi

   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  $count variable(s)"
}

# --- ghvar get ---
_ghvar_get() {
   local name="" target="" json_mode=0
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
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
      echo "Usage: ghvar get <name> [target] [--json]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   local result
   result=$(_gh_scoped api "$_GH_API_PATH/$name" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "get variable '$name' from $_GH_TARGET_LABEL"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo "$result"
      return 0
   fi

   echo "📋 Variable: $name"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  Name:       $(echo "$result" | jq -r '.name')"
   echo "  Value:      $(echo "$result" | jq -r '.value')"
   if [[ "$_GH_SCOPE" == "org" ]]; then
      echo "  Visibility: $(echo "$result" | jq -r '.visibility')"
   fi
   echo "  Created:    $(echo "$result" | jq -r '.created_at')"
   echo "  Updated:    $(echo "$result" | jq -r '.updated_at')"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# --- ghvar set ---
_ghvar_set() {
   local name="" value="" target="" visibility="" repos="" json_mode=0 dry_run=0
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --json) json_mode=1; shift ;;
         --dry-run) dry_run=1; shift ;;
         --visibility) visibility="$2"; shift 2 ;;
         --repos) repos="$2"; shift 2 ;;
         *)
            if [[ -z "$name" ]]; then
               name="$1"
            elif [[ -z "$value" ]]; then
               value="$1"
            else
               target="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$name" || -z "$value" ]]; then
      echo "Usage: ghvar set <name> <value> [target] [--visibility all|private|selected] [--repos r1,r2]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   ## Dry-run: validate and show what would happen without API calls
   if [[ $dry_run -eq 1 ]]; then
      if [[ "$_GH_SCOPE" == "org" && -z "$visibility" ]]; then
         echo "✗ Org variable requires --visibility (all, private, or selected)"
         return 1
      fi
      echo "[dry-run] Would set variable '$name' on $_GH_TARGET_LABEL"
      echo "  Scope: $_GH_SCOPE"
      echo "  Value: $value"
      [[ -n "$visibility" ]] && echo "  Visibility: $visibility"
      [[ -n "$repos" ]] && echo "  Repos: $repos"
      return 0
   fi

   _gh_require_admin || return 1

   ## Build JSON body safely with jq
   local body=""

   if [[ "$_GH_SCOPE" == "org" ]]; then
      if [[ -n "$visibility" ]]; then
         if [[ "$visibility" == "selected" && -n "$repos" ]]; then
            ## Resolve repo names to IDs
            local org="$_GH_TARGET_LABEL"
            local ids=()
            for repo_name in ${(s:,:)repos}; do
               local rid
               rid=$(_gh_admin api "/repos/$org/$repo_name" --jq '.id' 2>/dev/null)
               if [[ -n "$rid" ]]; then
                  ids+=("$rid")
               else
                  echo "⚠ Could not resolve repo: $org/$repo_name"
               fi
            done
            local repo_ids_json
            repo_ids_json="$(printf '%s\n' "${ids[@]}" | jq -R 'select(length>0) | tonumber' | jq -s '.')"
            body="$(jq -nc \
               --arg n "$name" \
               --arg v "$value" \
               --arg vis "$visibility" \
               --argjson rid "${repo_ids_json:-[]}" \
               '{name:$n, value:$v, visibility:$vis, selected_repository_ids:$rid}')"
         else
            body="$(jq -nc --arg n "$name" --arg v "$value" --arg vis "$visibility" '{name:$n, value:$v, visibility:$vis}')"
         fi
      else
         body="$(jq -nc --arg n "$name" --arg v "$value" '{name:$n, value:$v}')"
      fi
   else
      body="$(jq -nc --arg n "$name" --arg v "$value" '{name:$n, value:$v}')"
   fi

   ## Try update (PATCH) first
   local result
   result=$(_gh_scoped api "$_GH_API_PATH/$name" --method PATCH --input - <<< "$body" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      ## Check if 404 (variable doesn't exist yet)
      if echo "$result" | grep -qi '404\|not found'; then
         ## Create (POST) — need visibility for org scope
         if [[ "$_GH_SCOPE" == "org" && -z "$visibility" ]]; then
            echo "✗ Org variable requires --visibility (all, private, or selected)"
            return 1
         fi
         result=$(_gh_scoped api "$_GH_API_PATH" --method POST --input - <<< "$body" 2>&1)
         rc=$?
         if [[ $rc -ne 0 ]]; then
            _gh_handle_error "$result" "create variable '$name' on $_GH_TARGET_LABEL"
            return 1
         fi
         if [[ $json_mode -eq 1 ]]; then
            echo '{"action":"created","name":"'"$name"'","target":"'"$_GH_TARGET_LABEL"'"}'
         else
            echo "✓ Created $name on $_GH_TARGET_LABEL"
         fi
      else
         _gh_handle_error "$result" "update variable '$name' on $_GH_TARGET_LABEL"
         return 1
      fi
   else
      if [[ $json_mode -eq 1 ]]; then
         echo '{"action":"updated","name":"'"$name"'","target":"'"$_GH_TARGET_LABEL"'"}'
      else
         echo "✓ Updated $name on $_GH_TARGET_LABEL"
      fi
   fi
}

# --- ghvar delete ---
_ghvar_delete() {
   local name="" target="" json_mode=0 dry_run=0
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
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
      echo "Usage: ghvar delete <name> [target] [--json]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   if [[ $dry_run -eq 1 ]]; then
      echo "[dry-run] Would delete variable '$name' from $_GH_TARGET_LABEL"
      return 0
   fi

   _gh_require_admin || return 1

   local result
   result=$(_gh_scoped api "$_GH_API_PATH/$name" --method DELETE 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "delete variable '$name' from $_GH_TARGET_LABEL"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo '{"action":"deleted","name":"'"$name"'","target":"'"$_GH_TARGET_LABEL"'"}'
   else
      echo "✓ Deleted $name from $_GH_TARGET_LABEL"
   fi
}

# --- ghvar import ---
_ghvar_import() {
   local file="" target="" visibility="" dry_run=0
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --dry-run) dry_run=1; shift ;;
         --visibility) visibility="$2"; shift 2 ;;
         *)
            if [[ -z "$file" ]]; then
               file="$1"
            else
               target="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$file" || -z "$target" ]]; then
      echo "Usage: ghvar import <file> <target> [--visibility all|private|selected] [--dry-run]"
      echo ""
      echo "File format (KEY=VALUE, one per line):"
      echo "  AWS_REGION=us-east-1"
      echo "  DEPLOY_ENV=staging"
      echo "  # comments and blank lines are ignored"
      return 1
   fi

   if [[ ! -f "$file" ]]; then
      echo "✗ File not found: $file"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   ## Require visibility for org scope
   if [[ "$_GH_SCOPE" == "org" && -z "$visibility" ]]; then
      echo "✗ Org import requires --visibility (all, private, or selected)"
      return 1
   fi

   ## Count valid lines
   local total=0 success=0 failed=0
   local -a vars=()
   while IFS= read -r line; do
      ## Normalize and skip comments/blank lines
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"
      [[ -z "$line" || "$line" == \#* ]] && continue
      ## Must contain =
      if [[ "$line" != *=* ]]; then
         echo "⚠ Skipping invalid line: $line"
         continue
      fi

      local var_name="${line%%=*}"
      var_name="${var_name#"${var_name%%[![:space:]]*}"}"
      var_name="${var_name%"${var_name##*[![:space:]]}"}"
      if [[ -z "$var_name" ]]; then
         echo "⚠ Skipping invalid line (empty key): $line"
         continue
      fi
      vars+=("$line")
      ((total++))
   done < "$file"

   if [[ $total -eq 0 ]]; then
      echo "✗ No valid KEY=VALUE lines found in $file"
      return 1
   fi

   echo "📋 Import: $total variable(s) → $_GH_TARGET_LABEL"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

   if [[ $dry_run -eq 0 ]]; then
      _gh_require_admin || return 1
   fi

   for entry in "${vars[@]}"; do
      local var_name="${entry%%=*}"
      local var_value="${entry#*=}"
      var_name="${var_name#"${var_name%%[![:space:]]*}"}"
      var_name="${var_name%"${var_name##*[![:space:]]}"}"

      if [[ $dry_run -eq 1 ]]; then
         printf "  [dry-run] %-28s = %s\n" "$var_name" "$var_value"
         ((success++))
         continue
      fi

      ## Build body with jq
      local body
      if [[ "$_GH_SCOPE" == "org" && -n "$visibility" ]]; then
         body="$(jq -nc --arg n "$var_name" --arg v "$var_value" --arg vis "$visibility" '{name:$n, value:$v, visibility:$vis}')"
      else
         body="$(jq -nc --arg n "$var_name" --arg v "$var_value" '{name:$n, value:$v}')"
      fi

      ## PATCH (update) first, POST (create) on 404
      ## Capture stderr only (error msgs); discard stdout (response body)
      local result
      result=$(_gh_scoped api "$_GH_API_PATH/$var_name" --method PATCH --input - <<< "$body" 2>&1 >/dev/null)
      local rc=$?

      if [[ $rc -ne 0 ]]; then
         if echo "$result" | grep -qi '404\|not found'; then
            result=$(_gh_scoped api "$_GH_API_PATH" --method POST --input - <<< "$body" 2>&1 >/dev/null)
            rc=$?
            if [[ $rc -ne 0 ]]; then
               printf "  ✗ %-28s FAILED (create)\n" "$var_name"
               ((failed++))
               continue
            fi
            printf "  ✓ %-28s created\n" "$var_name"
         else
            printf "  ✗ %-28s FAILED (update)\n" "$var_name"
            ((failed++))
            continue
         fi
      else
         printf "  ✓ %-28s updated\n" "$var_name"
      fi
      ((success++))
   done

   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   if [[ $dry_run -eq 1 ]]; then
      echo "  [dry-run] $total variable(s) would be set"
   else
      echo "  $success set, $failed failed (of $total)"
   fi
   [[ $failed -gt 0 ]] && return 1
   return 0
}

# --- Shared error handler (used by ghvar, ghsecret, ghteam) ---
_gh_handle_error() {
   local result="$1" context="$2"
   if echo "$result" | grep -qi '401\|bad credentials'; then
      echo "✗ Authentication failed — token expired or invalid"
   elif echo "$result" | grep -qi 'rate limit'; then
      echo "✗ Rate limited — wait a few minutes and retry"
   elif echo "$result" | grep -qi '403\|forbidden'; then
      echo "✗ Permission denied — admin token may lack required scope"
      echo "  Needed: classic PAT with admin:org"
   elif echo "$result" | grep -qi '404\|not found'; then
      echo "✗ Not found — check target name and your access"
   elif echo "$result" | grep -qi '422\|validation failed'; then
      echo "✗ Validation error"
      local msg
      msg=$(echo "$result" | jq -r '.message // empty' 2>/dev/null)
      [[ -n "$msg" ]] && echo "  API: $msg"
      local errors
      errors=$(echo "$result" | jq -r '.errors[]?.message // empty' 2>/dev/null)
      [[ -n "$errors" ]] && echo "  Detail: $errors"
   else
      echo "✗ Failed to $context"
      local msg
      msg=$(echo "$result" | jq -r '.message // empty' 2>/dev/null)
      [[ -n "$msg" ]] && echo "  API: $msg"
   fi
}

# ====================================
