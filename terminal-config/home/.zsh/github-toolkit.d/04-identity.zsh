# ============================================================================
# GitHub CLI Toolkit — Per-Session Identity Isolation (ghid)
# ============================================================================
# Problem this solves:
#   `gh auth switch` / ghauto / gh-as all rewrite ONE shared file
#   (~/.config/gh/hosts.yml). That state is global — every terminal and every
#   tool sees it. You cannot hold "personal" in one session and "work" in
#   another at the same time; the last switch wins and clobbers the others.
#
# How ghid fixes it:
#   gh reads its auth state from $GH_CONFIG_DIR (default ~/.config/gh). Point
#   each shell at its OWN config dir and the sessions become fully independent
#   — no shared hosts.yml, no clobbering.
#
#   git push over HTTPS uses this identity ONLY when git's credential helper is
#   `gh auth git-credential` (the default after `gh auth setup-git`). SSH
#   remotes, an osxkeychain helper, or a preset GH_TOKEN bypass GH_CONFIG_DIR.
#   `ghid show` reports whether push is actually wired to gh — don't assume.
#
# Two layers:
#   1. Per-terminal:  ghid use <name>      (binds THIS shell only)
#   2. Per-repo:      .gh-id file in repo  (auto-binds via opt-in chpwd hook)
#                     — survives fresh subshells, so automation/CI bind too.
#
# Identity homes live under $GH_ID_HOME (default ~/.config/gh-identities),
# one isolated gh config dir per identity.
# ============================================================================

## Root dir holding one isolated gh config per identity
: ${GH_ID_HOME:=$HOME/.config/gh-identities}

# --- Internal helpers -------------------------------------------------------

## Validate an identity name (no path traversal, safe charset only)
## Returns 0 if valid, 1 otherwise.
_gh_id_valid_name() {
   local name="${1:-}"
   [[ -n "$name" ]] || return 1
   ## Reject bare "." / ".." and any path traversal
   [[ "$name" == "." || "$name" == ".." ]] && return 1
   [[ "$name" == *".."* ]] && return 1
   [[ "$name" == /* ]] && return 1
   ## Engine/locale-independent charset check: reject if ANY char is outside
   ## [A-Za-z0-9._-]. This also catches newline, glob, and unicode bytes.
   [[ "$name" == *[!A-Za-z0-9._-]* ]] && return 1
   return 0
}

## Echo the config dir path for an identity name
_gh_id_dir() {
   echo "$GH_ID_HOME/$1"
}

## Echo the identity bound to THIS shell (basename of GH_CONFIG_DIR if it
## lives under GH_ID_HOME), or empty if unbound / pointed elsewhere.
_gh_id_current_name() {
   local cfg="${GH_CONFIG_DIR:-}"
   [[ -n "$cfg" ]] || return 0
   case "$cfg" in
      "$GH_ID_HOME"/*) echo "${cfg:t}" ;;
      *)               return 0 ;;
   esac
}

## Echo the gh account logged into a given config dir (active one preferred,
## else first found). Empty if none / dir not logged in.
_gh_id_account_in_dir() {
   local dir="${1:-}"
   [[ -n "$dir" && -d "$dir" ]] || return 0
   ## Handle both gh wordings ("...account NAME" and older "...as NAME") and any
   ## host (not just github.com), so GitHub Enterprise dirs parse too.
   GH_CONFIG_DIR="$dir" gh auth status 2>/dev/null | awk '
      /Logged in to .* account / { for (i=1;i<=NF;i++) if ($i=="account") { a=$(i+1); gsub(/\(.*/,"",a) } if (first=="") first=a }
      /Logged in to .* as /      { for (i=1;i<=NF;i++) if ($i=="as")      { a=$(i+1); gsub(/\(.*/,"",a) } if (first=="") first=a }
      /Active account: true/     { print a; found=1; exit }
      END { if (!found && first!="") print first }
   '
}

## True only if git push in THIS shell will honor the bound identity, i.e. git's
## credential helper routes through gh. (Finding 1: verify, never assume.)
_gh_id_push_helper_ok() {
   local helpers
   helpers="$(git config --get-all credential.helper 2>/dev/null
              git config --system --get-all credential.helper 2>/dev/null)"
   [[ "$helpers" == *"gh auth git-credential"* ]]
}

# --- Per-shell git push routing (Option C, opt-in) ---------------------------
## Route github.com git credentials through `gh auth git-credential` for THIS
## shell only, using git's GIT_CONFIG_* env vars (NO ~/.gitconfig change, no
## effect on other shells/keychain). gh resolves the identity from
## GH_CONFIG_DIR, so `git push` follows whatever `ghid use` bound.

_gh_id_push_route_apply() {
   ## Never clobber a GIT_CONFIG_* block we don't own.
   if [[ -n "${GIT_CONFIG_COUNT:-}" && "${GH_ID_GIT_CONFIG_OWNED:-}" != "1" ]]; then
      echo "✗ GIT_CONFIG_COUNT is already set by something else — not overriding it." >&2
      echo "  Use 'gh auth setup-git' for global routing instead." >&2
      return 1
   fi
   ## Entry 0 resets the helper (drops keychain for this process); entry 1 adds gh.
   export GIT_CONFIG_COUNT=2
   export GIT_CONFIG_KEY_0='credential.https://github.com.helper'
   export GIT_CONFIG_VALUE_0=''
   export GIT_CONFIG_KEY_1='credential.https://github.com.helper'
   export GIT_CONFIG_VALUE_1='!gh auth git-credential'
   export GH_ID_GIT_CONFIG_OWNED=1
   export GH_ID_PUSH_ROUTE=1
   return 0
}

_gh_id_push_route_clear() {
   ## Only tear down the block if WE set it.
   if [[ "${GH_ID_GIT_CONFIG_OWNED:-}" == "1" ]]; then
      unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0 \
            GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1 GH_ID_GIT_CONFIG_OWNED
   fi
   unset GH_ID_PUSH_ROUTE
   return 0
}

## Core bind: point this shell at identity <name>. Creates the dir (700) if new.
## Quiet (no output); returns 1 on invalid name. Used by ghid + autodetect.
_gh_id_use_quiet() {
   local name="${1:-}"
   _gh_id_valid_name "$name" || return 1
   ## Keep the identity home private so other local users can't enumerate names.
   [[ -d "$GH_ID_HOME" ]] || mkdir -p "$GH_ID_HOME" || return 1
   chmod 700 "$GH_ID_HOME" 2>/dev/null
   local dir
   dir="$(_gh_id_dir "$name")"
   mkdir -p "$dir" || return 1
   ## Enforce 700 on EVERY bind, not just creation (a restored/backup dir or a
   ## different umask could otherwise leave hosts.yml world-readable).
   chmod 700 "$dir" 2>/dev/null
   export GH_CONFIG_DIR="$dir"
   export GH_ACTIVE_IDENTITY="$name"
   return 0
}

## Walk up from PWD looking for a .gh-id file; echo its trimmed contents.
_gh_id_find_marker() {
   local dir="$PWD"
   while [[ -n "$dir" ]]; do
      if [[ -f "$dir/.gh-id" ]]; then
         ## First non-empty, non-comment line
         local line
         while IFS= read -r line || [[ -n "$line" ]]; do
            ## Trim leading/trailing whitespace (no extendedglob needed)
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"
            [[ -z "$line" || "$line" == \#* ]] && continue
            echo "$line"
            return 0
         done < "$dir/.gh-id"
         return 0
      fi
      [[ "$dir" == "/" ]] && break
      dir="${dir:h}"
   done
   return 0
}

## chpwd hook: bind identity from nearest .gh-id (opt-in via `ghid auto on`).
## SECURITY: .gh-id lives inside repos (possibly cloned/untrusted). Auto-bind
## only ever selects an identity you ALREADY created — it never materializes a
## new identity dir from a repo-supplied name. Unknown names just warn.
_gh_id_chpwd_hook() {
   local marker
   marker="$(_gh_id_find_marker)"
   [[ -z "$marker" ]] && return 0
   ## Only rebind if it differs from the current binding (avoid churn)
   [[ "$marker" == "$(_gh_id_current_name)" ]] && return 0
   if ! _gh_id_valid_name "$marker"; then
      echo "⚠ ghid: .gh-id names an invalid identity '$marker' — ignored"
      return 0
   fi
   if [[ ! -d "$(_gh_id_dir "$marker")" ]]; then
      echo "⚠ ghid: .gh-id wants identity '$marker', which doesn't exist."
      echo "  Create it first:  ghid import $marker [account]   (or: ghid login $marker)"
      return 0
   fi
   if _gh_id_use_quiet "$marker"; then
      echo "🔐 ghid: bound to '$marker' (from .gh-id)"
   fi
}

## Prompt/script helper: short identity tag, e.g. [id:personal]. Empty if none.
_gh_id_prompt_info() {
   local name
   name="$(_gh_id_current_name)"
   [[ -n "$name" ]] && echo "[id:$name]"
   ## Always succeed — this feeds prompts; must not pollute $?
   return 0
}

# --- ghid command -----------------------------------------------------------

ghid() {
   local subcmd="${1:-show}"
   shift 2>/dev/null

   case "$subcmd" in
      use)
         local name="${1:-}"
         if [[ -z "$name" ]]; then
            echo "Usage: ghid use <name>"
            echo "  Binds THIS shell to an isolated gh identity."
            return 1
         fi
         if ! _gh_id_valid_name "$name"; then
            echo "✗ Invalid identity name: '$name'"
            echo "  Allowed: letters, digits, dot, underscore, hyphen (no '..')"
            return 1
         fi
         _gh_id_use_quiet "$name" || { echo "✗ Could not bind identity '$name'"; return 1; }
         local acct
         acct="$(_gh_id_account_in_dir "$GH_CONFIG_DIR")"
         if [[ -n "$acct" ]]; then
            echo "✓ This shell → identity '$name' (github.com: $acct)"
         else
            echo "✓ This shell → identity '$name' (not logged in yet)"
            echo "  Log in:  ghid login $name      (browser)"
            echo "  Or seed: ghid import $name [account]   (reuse a global gh token)"
         fi
         ## If push routing is on, it follows the new identity automatically
         ## (the git env is identity-independent — gh reads GH_CONFIG_DIR).
         [[ "${GH_ID_PUSH_ROUTE:-}" == "1" ]] && echo "  git push → '$name' (routing on)"
         ;;

      push)
         case "${1:-status}" in
            on)
               if [[ -z "$(_gh_id_current_name)" ]]; then
                  echo "✗ Bind an identity first:  ghid use <name>"
                  return 1
               fi
               _gh_id_push_route_apply || return 1
               echo "✓ git push routing ON — github.com push in THIS shell now follows"
               echo "  the bound identity ('$(_gh_id_current_name)'). No global config changed."
               echo "  Turn off: ghid push off   |   also cleared by: ghid clear"
               ;;
            off)
               _gh_id_push_route_clear
               echo "✓ git push routing OFF — push uses your default git credential helper again"
               ;;
            status|"")
               if [[ "${GH_ID_PUSH_ROUTE:-}" == "1" ]]; then
                  echo "git push routing: ON  (identity=${GH_ACTIVE_IDENTITY:-none}, via gh credential helper)"
               else
                  local h
                  h="$(git config --get-all credential.helper 2>/dev/null | tr '\n' ' ')"
                  echo "git push routing: OFF (default helper: ${h:-none})"
               fi
               ;;
            *)
               echo "Usage: ghid push on|off|status"
               echo "  on     route github.com git push through the bound identity (this shell only)"
               echo "  off    revert to your default git credential helper"
               echo "  status show current routing state"
               ;;
         esac
         ;;

      login)
         local name="${1:-}"
         if [[ -z "$name" ]]; then
            echo "Usage: ghid login <name>"
            return 1
         fi
         _gh_id_valid_name "$name" || { echo "✗ Invalid identity name: '$name'"; return 1; }
         _gh_id_use_quiet "$name" || return 1
         echo "🌐 Logging into isolated identity '$name' (config dir: $GH_CONFIG_DIR)"
         gh auth login --hostname github.com --git-protocol https --web
         ;;

      import)
         local name="${1:-}" account="${2:-}"
         if [[ -z "$name" ]]; then
            echo "Usage: ghid import <name> [global-account]"
            echo "  Seeds an isolated identity from a token already in your global gh."
            echo "  No browser re-auth. Run 'ghlist' to see global accounts."
            return 1
         fi
         _gh_id_valid_name "$name" || { echo "✗ Invalid identity name: '$name'"; return 1; }
         ## Read the token from the GLOBAL gh config — NOT whatever this shell is
         ## currently bound to (a bound shell would otherwise copy ITS token into
         ## the new identity = cross-identity bleed). Subshell unsets the binding.
         local tok=""
         if [[ -n "$account" ]]; then
            tok="$(unset GH_CONFIG_DIR; gh auth token --user "$account" 2>/dev/null)"
            if [[ -z "$tok" ]]; then
               echo "✗ No token for global account '$account'. Try: ghlist"
               return 1
            fi
         else
            tok="$(unset GH_CONFIG_DIR; gh auth token 2>/dev/null)"
            if [[ -z "$tok" ]]; then
               echo "✗ No active global gh token to import. Log in globally first, or use: ghid login $name"
               return 1
            fi
         fi
         _gh_id_use_quiet "$name" || return 1
         ## Disable xtrace locally so the token never reaches the trace stream.
         setopt localoptions no_xtrace 2>/dev/null
         if echo "$tok" | gh auth login --hostname github.com --git-protocol https --with-token 2>/dev/null; then
            local acct
            acct="$(_gh_id_account_in_dir "$GH_CONFIG_DIR")"
            echo "✓ Identity '$name' seeded (github.com: ${acct:-unknown}). This shell is now bound to it."
         else
            echo "✗ Failed to seed identity '$name' from token"
            return 1
         fi
         ;;

      show|"")
         local name acct
         name="$(_gh_id_current_name)"
         local cfg="${GH_CONFIG_DIR:-}"
         _gh_title "🔐 GitHub Identity (this shell)"
         if [[ -z "$cfg" ]]; then
            _gh_kv "Binding" "(none — using global ~/.config/gh)"
         elif [[ -z "$name" ]]; then
            _gh_kv "Binding" "external dir (not a ghid identity)"
            _gh_kv "Config dir" "$cfg"
         else
            acct="$(_gh_id_account_in_dir "$cfg")"
            _gh_kv "Identity" "$name"
            _gh_kv "Config dir" "$cfg"
            _gh_kv "Account" "${acct:-(not logged in)}"
            if [[ "${GH_ID_PUSH_ROUTE:-}" == "1" ]]; then
               _gh_kv "git push" "→ this identity (ghid push routing ON, this shell)"
            elif _gh_id_push_helper_ok; then
               _gh_kv "git push" "honors this identity (global gh credential helper)"
            else
               _gh_kv "git push" "⚠ default helper — run: ghid push on  (or: gh auth setup-git)"
            fi
         fi
         _gh_rule
         ;;

      list)
         _gh_title "🔐 GitHub Identities"
         if [[ ! -d "$GH_ID_HOME" ]] || [[ -z "$(ls -A "$GH_ID_HOME" 2>/dev/null)" ]]; then
            echo "  (none yet)"
            echo ""
            echo "  Create one:  ghid login <name>   or   ghid import <name> [account]"
            _gh_rule
            return 0
         fi
         local current
         current="$(_gh_id_current_name)"
         printf "  %-18s %-26s %s\n" "IDENTITY" "ACCOUNT" "ACTIVE"
         _gh_rule_light
         local d nm acct mark
         for d in "$GH_ID_HOME"/*(N/); do
            nm="${d:t}"
            acct="$(_gh_id_account_in_dir "$d")"
            mark=""
            [[ "$nm" == "$current" ]] && mark="←  this shell"
            printf "  %-18s %-26s %s\n" "$nm" "${acct:-(not logged in)}" "$mark"
         done
         _gh_rule
         echo "  Bind this shell:  ghid use <identity>"
         ;;

      clear)
         unset GH_CONFIG_DIR
         unset GH_ACTIVE_IDENTITY
         _gh_id_push_route_clear   ## also drop push routing (no identity to route to)
         echo "✓ Identity binding cleared — this shell uses global ~/.config/gh"
         ;;

      which)
         ## Machine-readable: just the identity name (empty if unbound)
         _gh_id_current_name
         ;;

      auto)
         autoload -Uz add-zsh-hook 2>/dev/null
         case "$1" in
            on)
               add-zsh-hook chpwd _gh_id_chpwd_hook
               echo "✓ Auto-bind ON — .gh-id files now bind identity on cd"
               ## Bind immediately for the current directory
               _gh_id_chpwd_hook
               ;;
            off)
               add-zsh-hook -d chpwd _gh_id_chpwd_hook
               echo "✓ Auto-bind OFF"
               ;;
            *)
               echo "Usage: ghid auto on|off"
               echo "  Reads .gh-id in the repo root and binds that identity on cd."
               ;;
         esac
         ;;

      help)
         _gh_id_help
         ;;

      *)
         _gh_id_help
         return 1
         ;;
   esac
}

_gh_id_help() {
   _gh_title "🔐 ghid — per-session GitHub identity isolation"
   echo ""
   echo "Hold different GitHub logins in different shells AT THE SAME TIME."
   echo "Each identity is an isolated gh config dir (own hosts.yml), so sessions"
   echo "never clobber each other the way 'gh auth switch' does."
   echo ""
   echo "Commands:"
   echo "  ghid use <name>        Bind THIS shell to identity <name>"
   echo "  ghid login <name>      Bind + browser-login a new identity"
   echo "  ghid import <name> [a] Seed identity from a global gh token (no browser)"
   echo "  ghid show              Show this shell's identity (default)"
   echo "  ghid list              List all identities + their accounts"
   echo "  ghid clear             Unbind (back to global ~/.config/gh)"
   echo "  ghid which             Print bound identity name (for scripts/prompt)"
   echo "  ghid push on|off       Route git push through the bound identity (this shell)"
   echo "  ghid auto on|off       Auto-bind from a .gh-id file on cd"
   echo ""
   echo "git push: by default 'gh'/API is isolated but 'git push' uses your global"
   echo "credential helper. 'ghid push on' makes push follow the bound identity in"
   echo "THIS shell only (no ~/.gitconfig change). 'ghid show' reports the state."
   echo ""
   echo "Per-repo binding: put an identity name in a '.gh-id' file at the repo"
   echo "root (gitignore it). With 'ghid auto on', cd-ing in binds automatically —"
   echo "this also works for fresh subshells (CI, scripts, agents)."
   echo ""
   echo "Prompt tag: _gh_id_prompt_info → [id:<name>]  (wire into your PROMPT)"
   _gh_rule
}
