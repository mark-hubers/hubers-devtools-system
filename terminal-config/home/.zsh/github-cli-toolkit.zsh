# ============================================================================
# GITHUB CLI (gh) TOOLKIT - Enhanced with fzf
# Makes GitHub workflows fast and easy from the terminal!
# ============================================================================
#
# Modular architecture — each domain in its own file:
#
#   github-toolkit.d/
#     00-ui.zsh        — output helpers (_gh_rule, _gh_title, _gh_kv, _gh_flags_parse)
#     01-core.zsh      — dependency checks, ghdoctor
#     02-infra.zsh     — admin token, target parsing, error handling
#     03-profiles.zsh  — profiles, escalation, guardrails, audit log
#     04-accounts.zsh  — multi-account (ghlist, ghadd, ghswitch, gh-as)
#     05-repos.zsh     — repos, PRs, issues, branches, workflows, help, aliases
#     06-variables.zsh — ghvar (list/get/set/delete/import)
#     07-secrets.zsh   — ghsecret (list/set/delete)
#     08-teams.zsh     — ghteam (list/show/add-member/remove-member/set-repo/fix)
#     09-setup.zsh     — ghsetup, ghconfig, ghtoken
#
# Dependencies: gh (required), jq (required), fzf (optional)
# Run 'ghdoctor' to check dependencies.
# ============================================================================

## Load all toolkit modules in order
local _gh_toolkit_dir="${0:a:h}/github-toolkit.d"
if [[ -d "$_gh_toolkit_dir" ]]; then
   local _gh_mod
   for _gh_mod in "$_gh_toolkit_dir"/*.zsh; do
      [[ -f "$_gh_mod" ]] && source "$_gh_mod"
   done
   unset _gh_mod
fi
unset _gh_toolkit_dir
