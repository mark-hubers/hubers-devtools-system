# ============================================================================
# GitHub CLI Toolkit — Profiles, Escalation, Guardrails, Audit
# ============================================================================
# Profiles define org, token source, visibility defaults, and mode.
# Config lives in ~/.gh-profiles.zsh (optional — toolkit works without it).
#
# Token source prefixes:
#   gh-auth           — use gh's built-in auth (default)
#   file:/path        — read from file
#   env:VAR_NAME      — read from env var
#   keychain:item     — future: macOS Keychain
#   op:vault/item     — future: 1Password

## Source profile config if it exists
[[ -f "$HOME/.gh-profiles.zsh" ]] && source "$HOME/.gh-profiles.zsh"

## Parse a profile's key=value config string into vars
_gh_profile_parse() {
   local config="$1"
   _GH_PROF_ORG=""
   _GH_PROF_TOKEN="gh-auth"
   _GH_PROF_VIS=""
   _GH_PROF_MODE="dev"

   local pair
   for pair in ${(z)config}; do
      case "$pair" in
         org=*)         _GH_PROF_ORG="${pair#org=}" ;;
         token=*)       _GH_PROF_TOKEN="${pair#token=}" ;;
         default_vis=*) _GH_PROF_VIS="${pair#default_vis=}" ;;
         mode=*)        _GH_PROF_MODE="${pair#mode=}" ;;
      esac
   done
}

## Activate a profile (set env vars for current shell)
_gh_profile_activate() {
   local name="$1"
   if [[ -z "${GH_PROFILES[$name]}" ]]; then
      [[ -n "$name" ]] && echo "✗ Unknown profile: $name"
      return 1
   fi

   _gh_profile_parse "${GH_PROFILES[$name]}"
   export GH_ACTIVE_PROFILE="$name"
   export GH_PROFILE_ORG="$_GH_PROF_ORG"
   export GH_PROFILE_TOKEN="$_GH_PROF_TOKEN"
   export GH_PROFILE_VIS="$_GH_PROF_VIS"
   export GH_PROFILE_MODE="$_GH_PROF_MODE"
}

## Activate default profile on shell startup (must run after _gh_profile_activate is defined)
if [[ -n "$GH_DEFAULT_PROFILE" && -z "$GH_ACTIVE_PROFILE" ]]; then
   GH_ACTIVE_PROFILE="$GH_DEFAULT_PROFILE"
   _gh_profile_activate "$GH_DEFAULT_PROFILE" 2>/dev/null
fi

## Resolve token from a token source string
_gh_resolve_token() {
   local source="${1:-gh-auth}"
   case "$source" in
      gh-auth)
         echo ""
         return 0
         ;;
      file:*)
         local path="${source#file:}"
         path="${path/#\~/$HOME}"
         if [[ ! -f "$path" ]]; then
            echo "✗ Token file not found: $path" >&2
            return 1
         fi
         local perms
         perms=$(stat -f '%Lp' "$path" 2>/dev/null || stat -c '%a' "$path" 2>/dev/null)
         if [[ "$perms" != "600" ]]; then
            echo "⚠ Fixing permissions on $path ($perms → 600)" >&2
            chmod 600 "$path"
         fi
         echo "$(<"$path")"
         ;;
      env:*)
         local var="${source#env:}"
         echo "${(P)var}"
         ;;
      keychain:*)
         local item="${source#keychain:}"
         security find-generic-password -a "$item" -s "gh-toolkit" -w 2>/dev/null
         ;;
      *)
         if [[ -f "$source" ]]; then
            echo "$(<"$source")"
         else
            echo "✗ Unknown token source: $source" >&2
            return 1
         fi
         ;;
   esac
}

## Profile commands
ghprofile() {
   local subcmd="${1:-show}"
   shift 2>/dev/null

   case "$subcmd" in
      list)
         _gh_title "📋 GitHub Profiles"
         if [[ ${#GH_PROFILES} -eq 0 ]]; then
            echo "  (none configured)"
            echo ""
            echo "  Create ~/.gh-profiles.zsh or run: ghprofile create"
            return 0
         fi
         printf "  %-16s %-20s %-12s %-8s %s\n" "PROFILE" "ORG" "TOKEN" "MODE" "DEFAULT VIS"
         _gh_rule_light
         local name
         for name in ${(ko)GH_PROFILES}; do
            _gh_profile_parse "${GH_PROFILES[$name]}"
            local active=""
            [[ "$name" == "$GH_ACTIVE_PROFILE" ]] && active=" *"
            local token_short="$_GH_PROF_TOKEN"
            [[ "$token_short" == file:* ]] && token_short="file:..."
            printf "  %-16s %-20s %-12s %-8s %s%s\n" "$name" "$_GH_PROF_ORG" "$token_short" "$_GH_PROF_MODE" "${_GH_PROF_VIS:--}" "$active"
         done
         _gh_rule
         echo "  * = active profile"
         ;;

      use)
         local name="$1"
         if [[ -z "$name" ]]; then
            echo "Usage: ghprofile use <name>"
            echo "  Run 'ghprofile list' to see available profiles."
            return 1
         fi
         _gh_profile_activate "$name" || return 1
         echo "✓ Switched to profile: $name (org=$GH_PROFILE_ORG, mode=$GH_PROFILE_MODE)"
         ;;

      show)
         if [[ -z "$GH_ACTIVE_PROFILE" ]]; then
            echo "  No active profile. Run: ghprofile use <name>"
            return 0
         fi
         _gh_title "📋 Active Profile: $GH_ACTIVE_PROFILE"
         _gh_kv "Org" "$GH_PROFILE_ORG"
         _gh_kv "Token" "$GH_PROFILE_TOKEN"
         _gh_kv "Mode" "$GH_PROFILE_MODE"
         _gh_kv "Visibility" "${GH_PROFILE_VIS:-(not set)}"
         _gh_rule
         ;;

      create)
         echo "🔧 Create GitHub Profile"
         echo ""
         read "p_name?Profile name (e.g. work-admin, personal): "
         [[ -z "$p_name" ]] && { echo "✗ Name required"; return 1; }

         read "p_org?Organization (e.g. alvaria-bu): "
         [[ -z "$p_org" ]] && { echo "✗ Org required"; return 1; }

         echo ""
         echo "Token source:"
         echo "  1. Use gh auth (default — browser login)"
         echo "  2. Token file (e.g. ~/.gh-admin-token)"
         echo "  3. Environment variable"
         read "t_choice?Choice (1-3) [1]: "
         t_choice=${t_choice:-1}

         local p_token="gh-auth"
         case "$t_choice" in
            2)
               read "t_path?Token file path [~/.gh-admin-token]: "
               t_path=${t_path:-~/.gh-admin-token}
               p_token="file:$t_path"
               ;;
            3)
               read "t_var?Environment variable name: "
               p_token="env:$t_var"
               ;;
         esac

         echo ""
         echo "Mode:"
         echo "  1. dev (read-only, safe default)"
         echo "  2. admin (org-level write access)"
         read "m_choice?Choice (1-2) [1]: "
         local p_mode="dev"
         [[ "$m_choice" == "2" ]] && p_mode="admin"

         local p_vis=""
         if [[ "$p_mode" == "admin" ]]; then
            read "p_vis?Default visibility for org vars/secrets (all/private/selected) [all]: "
            p_vis=${p_vis:-all}
         fi

         echo ""
         echo "Profile config to add to ~/.gh-profiles.zsh:"
         echo ""
         local config_line="\"$p_name\"    \"org=$p_org token=$p_token mode=$p_mode${p_vis:+ default_vis=$p_vis}\""
         echo "   $config_line"
         echo ""

         read "save?Save to ~/.gh-profiles.zsh? (y/n) [y]: "
         save=${save:-y}
         if [[ "$save" == "y" || "$save" == "Y" ]]; then
            if [[ ! -f "$HOME/.gh-profiles.zsh" ]]; then
               cat > "$HOME/.gh-profiles.zsh" << 'PROFILES_HEADER'
# GitHub CLI Toolkit — Profile Configuration
# Docs: docs/GITHUB-TOOLKIT.md
typeset -gA GH_PROFILES
GH_PROFILES=(
PROFILES_HEADER
               echo "   $config_line" >> "$HOME/.gh-profiles.zsh"
               echo ")" >> "$HOME/.gh-profiles.zsh"
               echo "GH_DEFAULT_PROFILE=\"$p_name\"" >> "$HOME/.gh-profiles.zsh"
            else
               local prof_tmp inserted=0
               prof_tmp=$(mktemp)
               while IFS= read -r pline || [[ -n "$pline" ]]; do
                  if [[ $inserted -eq 0 && "$pline" == ")" ]]; then
                     print -r -- "   $config_line" >> "$prof_tmp"
                     inserted=1
                  fi
                  print -r -- "$pline" >> "$prof_tmp"
               done < "$HOME/.gh-profiles.zsh"
               if [[ $inserted -eq 0 ]]; then
                  echo "✗ Could not find closing ')' in ~/.gh-profiles.zsh"
                  rm -f "$prof_tmp"
                  return 1
               fi
               mv "$prof_tmp" "$HOME/.gh-profiles.zsh"
            fi
            source "$HOME/.gh-profiles.zsh"
            _gh_profile_activate "$p_name"
            echo "✓ Profile '$p_name' saved and activated"
         fi
         ;;

      *)
         _gh_title "📋 ghprofile — GitHub Profile Management"
         echo ""
         echo "Usage: ghprofile <command>"
         echo ""
         echo "Commands:"
         echo "  list     Show all profiles"
         echo "  use      Switch to a profile"
         echo "  show     Show active profile details"
         echo "  create   Interactive profile creation"
         echo ""
         echo "Profiles define: org, token source, mode (dev/admin), default visibility"
         echo "Config: ~/.gh-profiles.zsh"
         return 1
         ;;
   esac
}

# --- Admin Escalation ---

ghadmin() {
   if [[ $# -gt 0 ]]; then
      local admin_profile=""
      local name
      for name in ${(ko)GH_PROFILES}; do
         _gh_profile_parse "${GH_PROFILES[$name]}"
         if [[ "$_GH_PROF_MODE" == "admin" ]]; then
            admin_profile="$name"
            break
         fi
      done

      if [[ -z "$admin_profile" ]]; then
         echo "✗ No admin profile configured. Run: ghprofile create"
         return 1
      fi

      _gh_profile_parse "${GH_PROFILES[$admin_profile]}"
      local token
      token=$(_gh_resolve_token "$_GH_PROF_TOKEN") || return 1

      (
         [[ -n "$token" ]] && export GH_TOKEN="$token"
         export GH_PROFILE_MODE=admin
         export GH_ACTIVE_PROFILE="$admin_profile"
         export GH_PROFILE_ORG="$_GH_PROF_ORG"
         export GH_PROFILE_TOKEN="$_GH_PROF_TOKEN"
         export GH_PROFILE_VIS="$_GH_PROF_VIS"
         "$@"
      )
      return $?
   fi

   local admin_profile=""
   local name
   for name in ${(ko)GH_PROFILES}; do
      _gh_profile_parse "${GH_PROFILES[$name]}"
      if [[ "$_GH_PROF_MODE" == "admin" ]]; then
         admin_profile="$name"
         break
      fi
   done

   if [[ -z "$admin_profile" ]]; then
      echo "✗ No admin profile configured. Run: ghprofile create"
      return 1
   fi

   ghprofile use "$admin_profile"
   _gh_audit_log "ghadmin" "escalated to $admin_profile"
}

ghdev() {
   if [[ -z "$GH_DEFAULT_PROFILE" ]]; then
      echo "✗ No default profile set. Add GH_DEFAULT_PROFILE to ~/.gh-profiles.zsh"
      return 1
   fi
   ghprofile use "$GH_DEFAULT_PROFILE"
   _gh_audit_log "ghdev" "de-escalated to $GH_DEFAULT_PROFILE"
}

# --- Prompt Indicator (Generic) ---

_gh_prompt_info() {
   if [[ -z "$GH_ACTIVE_PROFILE" ]]; then
      return 0
   fi
   if [[ "$GH_PROFILE_MODE" == "admin" ]]; then
      echo "[GH:$GH_ACTIVE_PROFILE:admin]"
   fi
}

# --- Guardrails ---

_gh_require_admin() {
   if [[ "$GH_PROFILE_MODE" == "dev" && -n "$GH_ACTIVE_PROFILE" ]]; then
      echo "✗ Profile '$GH_ACTIVE_PROFILE' is read-only (mode=dev)"
      echo "  Escalate: ghadmin"
      echo "  One-shot: ghadmin <command>"
      return 1
   fi
   return 0
}

# --- Audit Log ---

_gh_audit_log() {
   local command="$1" detail="$2" result="${3:-success}"
   local logfile="$HOME/.gh-toolkit-audit.log"
   local ts
   ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
   echo "${ts}|${GH_ACTIVE_PROFILE:-none}|${command}|${detail}|${result}" >> "$logfile"
}

ghaudit() {
   local subcmd="${1:-log}"
   shift 2>/dev/null

   case "$subcmd" in
      log)
         local logfile="$HOME/.gh-toolkit-audit.log"
         if [[ ! -f "$logfile" ]]; then
            echo "  No audit log yet. Admin actions will be logged automatically."
            return 0
         fi

         local filter=""
         case "${1:-}" in
            --today)   filter=$(date -u +"%Y-%m-%d") ;;
            --profile) filter="$2" ;;
         esac

         _gh_title "📋 Audit Log"
         printf "  %-22s %-14s %-16s %s\n" "TIMESTAMP" "PROFILE" "COMMAND" "DETAIL"
         _gh_rule_light

         if [[ -n "$filter" ]]; then
            grep "$filter" "$logfile"
         else
            tail -20 "$logfile"
         fi | while IFS='|' read -r ts prof cmd detail result; do
            printf "  %-22s %-14s %-16s %s\n" "${ts%T*} ${ts#*T}" "$prof" "$cmd" "$detail"
         done
         _gh_rule
         ;;
      *)
         echo "Usage: ghaudit log [--today | --profile <name>]"
         ;;
   esac
}
