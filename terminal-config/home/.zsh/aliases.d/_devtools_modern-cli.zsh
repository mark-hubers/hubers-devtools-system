#!/bin/zsh
# ============================================================================
# Modern CLI Tool Aliases
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# For custom aliases, create your own file without _devtools_ prefix
# ============================================================================

# eza (modern ls)
if command -v eza &> /dev/null; then
  alias ls='eza --icons --git'
  alias ll='eza --icons --git -lah --sort=modified --reverse'
  alias dir='eza --icons --git -lah --sort=modified --reverse'
  alias la='eza --icons --git -a'
  alias lt='eza --icons --git --tree --level=2'
  alias l='eza --icons --git -lh'
  alias ltr='eza --icons --git -la --sort modified'
  alias lsr='/bin/ls -ltr'
  alias llr='/bin/ls -la'
else
  alias ll='ls -latro'
  alias dir='ls -latro'
  alias ltr='ls -ltr'
  alias lsr='ls -ltr'
  alias llr='ls -la'
fi

# bat (modern cat)
if command -v bat &> /dev/null; then
  alias cat='bat --style=auto'
  alias rawcat='/bin/cat'
  alias plaincat='bat --plain'
  alias catp='/bin/cat'
else
  alias catp='/bin/cat'
fi

# ripgrep (modern grep)
if command -v rg &> /dev/null; then
  alias rgrep="rg"
  alias greps='rg -i'
  alias grepi='rg -i'
  alias grip='rg -i'
else
  alias greps='grep -i'
  alias grepi='grep -i'
  alias grip='grep -i'
fi

# fd (modern find)
if command -v fd &> /dev/null; then
  alias find='fd'
fi

# zoxide history search
if command -v zoxide &> /dev/null; then
  alias h='history -100 | fzf --tac --no-sort | sed "s/^ *[0-9]* *//"'
fi
