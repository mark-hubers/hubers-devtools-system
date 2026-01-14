#!/bin/zsh
# ============================================================================
# Kubernetes Aliases
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# For custom aliases, create your own file without _devtools_ prefix
# ============================================================================

# Core
alias k='kubectl'

# Get resources
alias kg='kubectl get'
alias kga='kubectl get all'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kgd='kubectl get deployments'
alias kgr='kubectl get rs'
alias kgi='kubectl get ingress'
alias kgcm='kubectl get configmap'
alias kgsec='kubectl get secret'
alias kgns='kubectl get namespaces'
alias kgpv='kubectl get pv'
alias kgpvc='kubectl get pvc'
alias kgcrd='kubectl get crd'
alias kgcr='kubectl get customresourcedefinition'

# Describe resources
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kdn='kubectl describe node'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe svc'
alias kdi='kubectl describe ingress'
alias kdcm='kubectl describe configmap'
alias kdsec='kubectl describe secret'
alias kdcr='kubectl describe customresourcedefinition'

# Delete resources
alias kdel='kubectl delete'
alias kdelp='kubectl delete pod'
alias kdeld='kubectl delete deployment'
alias kdels='kubectl delete svc'
alias kdeli='kubectl delete ingress'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# Exec
alias kex='kubectl exec -it'

# Apply/Create/Edit
alias ka='kubectl apply -f'
alias kc='kubectl create -f'
alias ke='kubectl edit'

# Context/Namespace
alias kcn='kubectl config set-context --current --namespace'
# kctx defined as function in functions.d (kubectx wrapper)
alias kctxs='kubectl config get-contexts'

# Rollout
alias kro='kubectl rollout'
alias kros='kubectl rollout status'
alias krou='kubectl rollout undo'

# Port forward
alias kpf='kubectl port-forward'

# Top (resource usage)
alias ktp='kubectl top pod'
alias ktn='kubectl top node'

# Kustomize
alias kky='kubectl kustomize'
