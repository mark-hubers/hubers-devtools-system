# System/tooling fzf-tab previews

### cd: directory listing ###
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
"ls -la --color=always \$realpath 2>/dev/null || echo 'No preview available'"

### ls: file/dir info ###
zstyle ':fzf-tab:complete:ls:*' fzf-preview \
"ls -la --color=always \$realpath 2>/dev/null || echo 'No preview available'"

### rm: show what you’re about to delete ###
zstyle ':fzf-tab:complete:rm:*' fzf-preview \
"ls -lh --color=always \$realpath 2>/dev/null || echo 'No preview available'"

### mv: show source file/dir info ###
zstyle ':fzf-tab:complete:mv:*' fzf-preview \
"ls -lh --color=always \$realpath 2>/dev/null || echo 'No preview available'"

### chmod: show target before changing ###
zstyle ':fzf-tab:complete:chmod:*' fzf-preview \
"ls -l --color=always \$realpath 2>/dev/null || echo 'No preview available'"

### chown: show target before changing ###
zstyle ':fzf-tab:complete:chown:*' fzf-preview \
"ls -l --color=always \$realpath 2>/dev/null || echo 'No preview available'"

