# Git fzf-tab previews

### git checkout: branch graph ###
zstyle ':fzf-tab:complete:git:checkout' fzf-preview \
"git log --oneline --graph --decorate --color \$word | head -n 25 2>/dev/null || echo 'No preview available'"

### git switch: branch graph ###
zstyle ':fzf-tab:complete:git:switch' fzf-preview \
"git log --oneline --graph --decorate --color \$word | head -n 25 2>/dev/null || echo 'No preview available'"

### git status: file diff preview ###
zstyle ':fzf-tab:complete:git:status' fzf-preview \
"git diff --color=always -- \$word 2>/dev/null || echo 'No diff available'"

### git add: file diff preview ###
zstyle ':fzf-tab:complete:git:add' fzf-preview \
"git diff --color=always -- \$word 2>/dev/null || echo 'No diff available'"

### git restore: file diff preview ###
zstyle ':fzf-tab:complete:git:restore' fzf-preview \
"git diff --color=always -- \$word 2>/dev/null || echo 'No diff available'"

### git show: commit preview ###
zstyle ':fzf-tab:complete:git:show' fzf-preview \
"git show --color=always --stat \$word 2>/dev/null || echo 'No preview available'"

### git blame: snippet around line (when using file:line targets) ###
zstyle ':fzf-tab:complete:git:blame' fzf-preview \
"git blame -L 1,120 --color-lines -- \$word 2>/dev/null || echo 'No preview available'"

### git stash: stash content preview ###
zstyle ':fzf-tab:complete:git:stash:pop' fzf-preview \
"git stash show --color=always -p \$word 2>/dev/null || echo 'No preview available'"

zstyle ':fzf-tab:complete:git:stash:apply' fzf-preview \
"git stash show --color=always -p \$word 2>/dev/null || echo 'No preview available'"

