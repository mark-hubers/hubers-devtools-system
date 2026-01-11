# Docker fzf-tab previews

### docker ps: container inspect (image + basic info) ###
zstyle ':fzf-tab:complete:docker:ps' fzf-preview \
"docker inspect \$word 2>/dev/null | jq '[.[0] | {Name: .Name, Image: .Config.Image, State: .State}]' 2>/dev/null || echo 'No preview available'"

### docker images: image inspect ###
zstyle ':fzf-tab:complete:docker:images' fzf-preview \
"docker inspect \$word 2>/dev/null | jq '[.[0] | {Id: .Id, RepoTags: .RepoTags, Size: .Size}]' 2>/dev/null || echo 'No preview available'"

### docker logs: last 50 lines with reminder ###
zstyle ':fzf-tab:complete:docker:logs' fzf-preview \
"(docker logs \$word 2>/dev/null | tail -n 50; \
echo ''; \
echo '---'; \
echo 'Showing last 50 lines. Run: docker logs '\$word' for full output.') \
2>/dev/null || echo 'No preview available'"

