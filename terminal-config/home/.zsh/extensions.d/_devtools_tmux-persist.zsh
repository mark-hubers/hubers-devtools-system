## tmux-persist.zsh - every local iTerm2 terminal becomes a persistent,
## reattachable tmux session, automatically.
##
## WHY (2026-09-09): Mark works from a MacBook Pro while travelling and from a
## Mac Studio at home. The Studio holds the real environment (24 GB - ACE, the
## databases, the daemon); the MacBook is a thin client (16 MB of config).
## Syncing them is the wrong model - remoting into the Studio is right.
##
## The blocker was that ~46 Claude Code sessions on the Studio were started in
## plain Terminal.app windows, NOT in tmux. A process started outside tmux can
## never be moved into it, so those sessions are reachable only by screen
## sharing to the Studio's desktop. From a terminal, they are unreachable.
##
## Fix: make persistence the DEFAULT so there is no decision to make when
## grabbing the laptop at short notice. Anything started from now on can be
## picked up from either machine.
##
## Uses iTerm2's native tmux integration (-CC): tmux windows render as REAL
## iTerm2 tabs with native scrollback and mouse. It does not feel like tmux.
## But underneath it is tmux, so closing the lid leaves work running and you
## reattach from anywhere.
##
## Escape hatches:
##   NO_TMUX=1          in the environment  -> skip auto-attach for that shell
##   tmux detach        (or close the window) -> session keeps running
##   tls / tat <name>   helpers below
##
## NOTE: mosh cannot carry -CC (control mode needs a clean pty). Over mosh use
## plain `tmux attach`; rclaude already does. SSH gets the native tabs.

## ---------------------------------------------------------------- helpers
## list tmux sessions here or on another host
tls() {
   if [ -n "${1:-}" ]; then
      ssh "$1" 'export PATH=$HOME/.local/bin:/opt/homebrew/bin:$PATH; tmux ls' 2>&1
   else
      tmux ls 2>&1
   fi
}

## attach to a named session locally (creates it if missing)
tat() {
   local name="${1:-main}"
   if [ -n "$TMUX" ]; then
      echo "-WARNING- already inside tmux; use 'tmux switch-client -t $name'"
      return 1
   fi
   tmux -CC new-session -A -s "$name"
}

## attach to a session on the Studio with NATIVE iTerm2 tabs (ssh, not mosh)
tstudio() {
   local name="${1:-main}"
   ssh -t marks-mac-studio \
      "export PATH=\$HOME/.local/bin:/opt/homebrew/bin:\$PATH; tmux -CC new-session -A -s '$name'"
}

## ---------------------------------------------------------- auto-attach
## Guards, all of which matter:
##   TERM_PROGRAM  - only iTerm2 supports -CC; other terminals get a normal shell
##   TMUX          - never nest tmux inside tmux
##   SSH_CONNECTION- incoming ssh (mine, rclaude, scripts) must NOT be hijacked
##   interactive   - never touch non-interactive shells or scripts
##   NO_TMUX       - manual override
##
## Deliberately NOT `exec tmux`: if tmux fails or you detach, you land in a
## normal working shell instead of a dead terminal.
if [[ "$TERM_PROGRAM" == "iTerm.app" ]] \
   && [[ -z "$TMUX" ]] \
   && [[ -z "$SSH_CONNECTION" ]] \
   && [[ -z "$NO_TMUX" ]] \
   && [[ -o interactive ]] \
   && command -v tmux >/dev/null 2>&1; then
   tmux -CC new-session -A -s main
fi
