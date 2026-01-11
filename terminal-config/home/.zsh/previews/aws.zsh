# AWS fzf-tab previews

### EC2: describe instance ###
zstyle ':fzf-tab:complete:aws:ec2:describe-instances' fzf-preview \
"aws ec2 describe-instances --instance-ids \$word --output yaml 2>/dev/null || echo 'No preview available'"

### S3: list bucket contents (summary) ###
zstyle ':fzf-tab:complete:aws:s3:ls' fzf-preview \
"aws s3 ls s3://\$word --recursive --human-readable --summarize 2>/dev/null || echo 'No preview available'"

### IAM: user info ###
zstyle ':fzf-tab:complete:aws:iam:list-users' fzf-preview \
"aws iam get-user --user-name \$word --output yaml 2>/dev/null || echo 'No preview available'"


