# TEAM MANAGEMENT
# ====================================
# Wraps GitHub Teams API for org-level team operations.

ghteam() {
   _gh_check || return 1
   _gh_require_jq || return 1

   local subcmd="$1"
   shift 2>/dev/null

   case "$subcmd" in
      list)          _ghteam_list "$@" ;;
      show)          _ghteam_show "$@" ;;
      add-member)    _ghteam_add_member "$@" ;;
      remove-member) _ghteam_remove_member "$@" ;;
      set-repo)      _ghteam_set_repo "$@" ;;
      fix)           _ghteam_fix "$@" ;;
      *)
         echo "👥 ghteam — GitHub Team Management"
         echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
         echo ""
         echo "Usage: ghteam <command> <org> [arguments]"
         echo ""
         echo "Commands:"
         echo "  list          <org>                            List teams"
         echo "  show          <org> <team>                     Team details + members + repos"
         echo "  add-member    <org> <team> <user> [--role ..]  Add/update member"
         echo "  remove-member <org> <team> <user>              Remove member"
         echo "  set-repo      <org> <team> <repo> <permission> Set repo access"
         echo "  fix           <org> <team> [--parent ..] [--description ..]"
         echo ""
         echo "Permissions: pull, triage, push, maintain, admin"
         echo ""
         echo "Examples:"
         echo "  ghteam list alvaria-bu"
         echo "  ghteam show alvaria-bu platform"
         echo "  ghteam add-member alvaria-bu scrm mark-hubers"
         echo "  ghteam set-repo alvaria-bu platform my-repo push"
         echo "  ghteam fix alvaria-bu scrm --parent users --description 'SCRM team'"
         return 1
         ;;
   esac
}

# --- ghteam list ---
_ghteam_list() {
   local org="" json_mode=0
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
         *)      org="$arg" ;;
      esac
   done

   if [[ -z "$org" ]]; then
      echo "Usage: ghteam list <org> [--json]"
      return 1
   fi

   local result
   result=$(_gh_admin api "/orgs/$org/teams" --paginate 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "list teams for $org"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo "$result"
      return 0
   fi

   echo "👥 Teams: $org"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   printf "  %-20s %-10s %-16s %-6s %-6s %s\n" "SLUG" "PRIVACY" "PARENT" "MEMB" "REPOS" "DESCRIPTION"
   echo "  ──────────────────── ────────── ──────────────── ────── ────── ─────────────────────"

   echo "$result" | jq -r '.[] | "\(.slug)\t\(.privacy)\t\(.parent.slug // "-")\t\(.members_count // "-")\t\(.repos_count // "-")\t\(.description // "")"' | \
      while IFS=$'\t' read -r slug privacy parent memb repos desc; do
         printf "  %-20s %-10s %-16s %-6s %-6s %s\n" "$slug" "$privacy" "$parent" "$memb" "$repos" "${desc:0:30}"
      done

   local count
   count=$(echo "$result" | jq 'length')
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  $count team(s)"
}

# --- ghteam show ---
_ghteam_show() {
   local org="" team="" json_mode=0 show_members=1 show_repos=1
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --json)       json_mode=1; shift ;;
         --no-members) show_members=0; shift ;;
         --no-repos)   show_repos=0; shift ;;
         *)
            if [[ -z "$org" ]]; then
               org="$1"
            else
               team="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$org" || -z "$team" ]]; then
      echo "Usage: ghteam show <org> <team> [--json] [--no-members] [--no-repos]"
      return 1
   fi

   ## Team details
   local team_result
   team_result=$(_gh_admin api "/orgs/$org/teams/$team" 2>&1)
   if [[ $? -ne 0 ]]; then
      _gh_handle_error "$team_result" "get team '$team' from $org"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      local output="$team_result"
      if [[ $show_members -eq 1 ]]; then
         local members
         members=$(_gh_admin api "/orgs/$org/teams/$team/members" --paginate 2>&1)
         output=$(echo "$output" | jq --argjson m "$(echo "$members" | jq '[.[] | {login, role: "member"}]')" '. + {members: $m}')
      fi
      if [[ $show_repos -eq 1 ]]; then
         local repos
         repos=$(_gh_admin api "/orgs/$org/teams/$team/repos" --paginate 2>&1)
         output=$(echo "$output" | jq --argjson r "$(echo "$repos" | jq '[.[] | {name, permission: .role_name}]')" '. + {repos: $r}')
      fi
      echo "$output"
      return 0
   fi

   echo "👥 Team: $(echo "$team_result" | jq -r '.name') ($org/$team)"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  Privacy:     $(echo "$team_result" | jq -r '.privacy')"
   echo "  Parent:      $(echo "$team_result" | jq -r '.parent.slug // "(none)"')"
   echo "  Description: $(echo "$team_result" | jq -r '.description // "(none)"')"
   echo "  Members:     $(echo "$team_result" | jq -r '.members_count // "?"')"
   echo "  Repos:       $(echo "$team_result" | jq -r '.repos_count // "?"')"

   if [[ $show_members -eq 1 ]]; then
      echo ""
      echo "  MEMBERS:"
      local members
      members=$(_gh_admin api "/orgs/$org/teams/$team/members" --paginate 2>&1)
      if [[ $? -eq 0 ]]; then
         local mem_count
         mem_count=$(echo "$members" | jq 'length')
         if [[ "$mem_count" == "0" ]]; then
            echo "    (none)"
         else
            echo "$members" | jq -r '.[] | "    \(.login)"'
         fi
      fi
   fi

   if [[ $show_repos -eq 1 ]]; then
      echo ""
      echo "  REPOS:"
      local repos
      repos=$(_gh_admin api "/orgs/$org/teams/$team/repos" --paginate 2>&1)
      if [[ $? -eq 0 ]]; then
         local repo_count
         repo_count=$(echo "$repos" | jq 'length')
         if [[ "$repo_count" == "0" ]]; then
            echo "    (none)"
         else
            printf "    %-35s %s\n" "REPO" "PERMISSION"
            echo "    ─────────────────────────────────── ──────────"
            echo "$repos" | jq -r '.[] | "    \(.name)\t\(.role_name // "read")"' | \
               while IFS=$'\t' read -r rname rperm; do
                  printf "    %-35s %s\n" "$rname" "$rperm"
               done
         fi
      fi
   fi

   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# --- ghteam add-member ---
_ghteam_add_member() {
   local org="" team="" user="" role="member" dry_run=0
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --dry-run) dry_run=1; shift ;;
         --role) role="$2"; shift 2 ;;
         *)
            if [[ -z "$org" ]]; then
               org="$1"
            elif [[ -z "$team" ]]; then
               team="$1"
            else
               user="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$org" || -z "$team" || -z "$user" ]]; then
      echo "Usage: ghteam add-member <org> <team> <user> [--role member|maintainer] [--dry-run]"
      return 1
   fi

   if [[ $dry_run -eq 1 ]]; then
      echo "[dry-run] Would add '$user' to $org/$team (role=$role)"
      return 0
   fi

   _gh_require_admin || return 1

   local result
   result=$(_gh_admin api "/orgs/$org/teams/$team/memberships/$user" \
      --method PUT --field "role=$role" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "add '$user' to $org/$team"
      return 1
   fi

   local state
   state=$(echo "$result" | jq -r '.state // "unknown"')
   echo "✓ $user → $org/$team (role=$role, state=$state)"
}

# --- ghteam remove-member ---
_ghteam_remove_member() {
   local org="" team="" user="" dry_run=0
   for arg in "$@"; do
      case "$arg" in
         --dry-run) dry_run=1 ;;
         *)
            if [[ -z "$org" ]]; then org="$arg"
            elif [[ -z "$team" ]]; then team="$arg"
            else user="$arg"
            fi
            ;;
      esac
   done

   if [[ -z "$org" || -z "$team" || -z "$user" ]]; then
      echo "Usage: ghteam remove-member <org> <team> <user> [--dry-run]"
      return 1
   fi

   if [[ $dry_run -eq 1 ]]; then
      echo "[dry-run] Would remove '$user' from $org/$team"
      return 0
   fi

   _gh_require_admin || return 1

   echo -n "Remove '$user' from $org/$team? (y/n): "
   read -k 1 confirm
   echo ""
   if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "  Cancelled"
      return 0
   fi

   local result
   result=$(_gh_admin api "/orgs/$org/teams/$team/memberships/$user" --method DELETE 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "remove '$user' from $org/$team"
      return 1
   fi

   echo "✓ Removed $user from $org/$team"
}

# --- ghteam set-repo ---
_ghteam_set_repo() {
   local org="" team="" repo="" permission="" dry_run=0
   for arg in "$@"; do
      case "$arg" in
         --dry-run) dry_run=1 ;;
         *)
            if [[ -z "$org" ]]; then org="$arg"
            elif [[ -z "$team" ]]; then team="$arg"
            elif [[ -z "$repo" ]]; then repo="$arg"
            else permission="$arg"
            fi
            ;;
      esac
   done

   if [[ -z "$org" || -z "$team" || -z "$repo" || -z "$permission" ]]; then
      echo "Usage: ghteam set-repo <org> <team> <repo> <permission> [--dry-run]"
      echo "  Permissions: pull, triage, push, maintain, admin"
      return 1
   fi

   if [[ $dry_run -eq 1 ]]; then
      echo "[dry-run] Would set $permission on $org/$repo for $org/$team"
      return 0
   fi

   _gh_require_admin || return 1

   local result
   result=$(_gh_admin api "/orgs/$org/teams/$team/repos/$org/$repo" \
      --method PUT --field "permission=$permission" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "set $permission on $org/$repo for $org/$team"
      return 1
   fi

   echo "✓ $org/$team → $repo ($permission)"
}

# --- ghteam fix ---
_ghteam_fix() {
   local org="" team="" parent="" description="" dry_run=0
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --dry-run)     dry_run=1; shift ;;
         --parent)      parent="$2"; shift 2 ;;
         --description) description="$2"; shift 2 ;;
         *)
            if [[ -z "$org" ]]; then
               org="$1"
            else
               team="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$org" || -z "$team" ]]; then
      echo "Usage: ghteam fix <org> <team> [--parent <parent-slug>] [--description \"text\"] [--dry-run]"
      return 1
   fi

   if [[ -z "$parent" && -z "$description" ]]; then
      echo "✗ Specify at least --parent or --description"
      return 1
   fi

   if [[ $dry_run -eq 1 ]]; then
      echo "[dry-run] Would update team $org/$team"
      [[ -n "$parent" ]] && echo "  Parent: → $parent"
      [[ -n "$description" ]] && echo "  Description: → $description"
      return 0
   fi

   _gh_require_admin || return 1

   ## Build JSON body safely
   local body
   if [[ -n "$description" ]]; then
      body="$(jq -nc --arg desc "$description" '{description: $desc}')"
   else
      body='{}'
   fi
   if [[ -n "$parent" ]]; then
      ## Resolve parent team slug to ID
      local parent_id
      parent_id=$(_gh_admin api "/orgs/$org/teams/$parent" --jq '.id' 2>/dev/null)
      if [[ -z "$parent_id" ]]; then
         echo "✗ Could not find parent team: $parent"
         return 1
      fi
      body="$(echo "$body" | jq -c --argjson pid "$parent_id" '. + {parent_team_id: $pid}')"
   fi

   local result
   result=$(_gh_admin api "/orgs/$org/teams/$team" --method PATCH --input - <<< "$body" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "update team $org/$team"
      return 1
   fi

   echo "✓ Updated $org/$team"
   [[ -n "$parent" ]] && echo "  Parent: $parent"
   [[ -n "$description" ]] && echo "  Description: $description"
}

# ====================================
