# ============================================================================
# GitHub CLI Toolkit — Infrastructure (admin token, target parsing, error handling)
# ============================================================================

## Run gh with admin token (profile-aware, legacy fallback)
_gh_admin() {
   ## If a profile is active, use its token source
   if [[ -n "$GH_PROFILE_TOKEN" && "$GH_PROFILE_TOKEN" != "gh-auth" ]]; then
      local token
      token=$(_gh_resolve_token "$GH_PROFILE_TOKEN") || return 1
      if [[ -n "$token" ]]; then
         GH_TOKEN="$token" gh "$@"
         return $?
      fi
   fi

   ## Fallback: legacy ~/.gh-admin-token file
   local token_file="$HOME/.gh-admin-token"
   if [[ ! -f "$token_file" ]]; then
      echo "✗ Admin token not found: $token_file"
      echo ""
      echo "Options:"
      echo "  1. Create a profile:   ghprofile create"
      echo "  2. Manual token file:  echo 'ghp_xxx' > ~/.gh-admin-token && chmod 600 ~/.gh-admin-token"
      return 1
   fi
   local perms
   perms=$(stat -f '%Lp' "$token_file" 2>/dev/null || stat -c '%a' "$token_file" 2>/dev/null)
   if [[ -n "$perms" && "$perms" != "600" ]]; then
      echo "⚠ Fixing permissions on $token_file ($perms → 600)"
      _gh_chmod_600 "$token_file"
   fi
   GH_TOKEN=$(<"$token_file") gh "$@"
}

## Parse target into scope + API path
## Sets: _GH_SCOPE (org|repo), _GH_API_PATH, _GH_TARGET_LABEL
_gh_parse_target() {
   local target="$1"

   ## Strip whitespace
   target="${target#"${target%%[![:space:]]*}"}"
   target="${target%"${target##*[![:space:]]}"}"

   if [[ -z "$target" ]]; then
      ## Try active profile's org first
      if [[ -n "$GH_PROFILE_ORG" ]]; then
         _GH_SCOPE="org"
         _GH_API_PATH="/orgs/$GH_PROFILE_ORG/actions/variables"
         _GH_TARGET_LABEL="$GH_PROFILE_ORG"
         return 0
      fi

      ## Auto-detect from git remote
      local remote_url
      remote_url=$(git remote get-url origin 2>/dev/null)
      if [[ -z "$remote_url" ]]; then
         echo "✗ No target specified, no active profile, and not in a git repo"
         echo "  Run: ghprofile use <name>  or specify a target"
         return 1
      fi
      local owner_repo
      owner_repo=$(echo "$remote_url" | sed -E 's#^(git@[^:]+:|https://[^/]+/)##; s/\.git$//')
      if [[ -z "$owner_repo" || "$owner_repo" != */* ]]; then
         echo "✗ Could not parse owner/repo from remote: $remote_url"
         return 1
      fi
      _GH_SCOPE="repo"
      _GH_API_PATH="/repos/$owner_repo/actions/variables"
      _GH_TARGET_LABEL="$owner_repo"
      return 0
   fi

   ## Validate: reject too many slashes
   local slash_count="${target//[^\/]/}"
   if [[ ${#slash_count} -gt 1 ]]; then
      echo "✗ Invalid target: '$target' (expected 'org' or 'owner/repo')"
      return 1
   fi

   if [[ "$target" == */* ]]; then
      _GH_SCOPE="repo"
      _GH_API_PATH="/repos/$target/actions/variables"
      _GH_TARGET_LABEL="$target"
   else
      _GH_SCOPE="org"
      _GH_API_PATH="/orgs/$target/actions/variables"
      _GH_TARGET_LABEL="$target"
   fi
   return 0
}

## Run gh or _gh_admin based on current scope
_gh_scoped() {
   if [[ "$_GH_SCOPE" == "org" ]]; then
      _gh_admin "$@"
   else
      gh "$@"
   fi
}

## Build secrets API path from current scope
_gh_secrets_api_path() {
   if [[ "$_GH_SCOPE" == "org" ]]; then
      echo "/orgs/$_GH_TARGET_LABEL/actions/secrets"
   else
      echo "/repos/$_GH_TARGET_LABEL/actions/secrets"
   fi
}

## Shared error handler (used by ghvar, ghsecret, ghteam)
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
