# Helm fzf-tab previews

### helm list: full release info ###
zstyle ':fzf-tab:complete:helm:list' fzf-preview \
"helm get all \$word 2>/dev/null || echo 'No preview available'"

### helm get values: values preview ###
zstyle ':fzf-tab:complete:helm:get-values' fzf-preview \
"helm get values \$word 2>/dev/null || echo 'No preview available'"

### helm history: release history ###
zstyle ':fzf-tab:complete:helm:history' fzf-preview \
"helm history \$word 2>/dev/null || echo 'No preview available'"


