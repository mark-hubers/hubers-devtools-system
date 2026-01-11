# Terraform fzf-tab previews

### terraform state list: resource summary ###
zstyle ':fzf-tab:complete:terraform:state:list' fzf-preview \
"terraform state show \$word 2>/dev/null || echo 'No preview available'"

### terraform state show: same, explicit ###
zstyle ':fzf-tab:complete:terraform:state:show' fzf-preview \
"terraform state show \$word 2>/dev/null || echo 'No preview available'"

