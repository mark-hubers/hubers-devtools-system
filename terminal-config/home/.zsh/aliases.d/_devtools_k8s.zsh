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
# kgp - defined as function in functions.d (has namespace arg support)
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

# Logs - defined as functions in functions.d (with extra features)
# kl, klf - see functions.d/_devtools_k8s.zsh

# Exec - defined as function in functions.d (with command default)
# kex - see functions.d/_devtools_k8s.zsh

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

# Port forward - defined as function in functions.d
# kpf - see functions.d/_devtools_k8s.zsh

# Top (resource usage)
alias ktp='kubectl top pod'
alias ktn='kubectl top node'

# Kustomize
alias kky='kubectl kustomize'
