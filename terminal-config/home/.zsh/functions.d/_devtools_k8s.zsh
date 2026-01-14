#!/bin/zsh
# ============================================================================
# Kubernetes Helper Functions
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# For custom functions, create your own file without _devtools_ prefix
# ============================================================================

# Clear conflicting aliases (may be defined in aliases.d or oh-my-zsh)
unalias kctx kns kgp kgpa kl klf kex kdesc kpf kwatch klogs kgetl 2>/dev/null

# kns - Switch Kubernetes namespace (wrapper for kubens)
# Usage: kns [namespace]
kns() {
    if ! command -v kubens &>/dev/null; then
        echo "kubens not installed. Install with: brew install kubectx"
        return 1
    fi
    kubens "$@"
}

# kctx - Switch Kubernetes context (wrapper for kubectx)
# Usage: kctx [context]
kctx() {
    if ! command -v kubectx &>/dev/null; then
        echo "kubectx not installed. Install with: brew install kubectx"
        return 1
    fi
    kubectx "$@"
}

# kgp - Get pods (short alias)
# Usage: kgp [namespace]
kgp() {
    if [[ -n "$1" ]]; then
        kubectl get pods -n "$1"
    else
        kubectl get pods
    fi
}

# kgpa - Get all pods in all namespaces
# Usage: kgpa
kgpa() {
    kubectl get pods --all-namespaces
}

# kl - Get logs from pod
# Usage: kl <pod> [-f] [-n namespace]
kl() {
    kubectl logs "$@"
}

# klf - Follow logs from pod
# Usage: klf <pod> [-n namespace]
klf() {
    kubectl logs -f "$@"
}

# kex - Exec into pod
# Usage: kex <pod> [command]
kex() {
    local pod="$1"
    shift
    local cmd="${@:-/bin/sh}"
    kubectl exec -it "$pod" -- $cmd
}

# kdesc - Describe resource
# Usage: kdesc <resource-type> <name>
kdesc() {
    kubectl describe "$@"
}

# kpf - Port forward
# Usage: kpf <pod> <local:remote>
kpf() {
    kubectl port-forward "$@"
}

# kwatch - Watch pods
# Usage: kwatch [namespace]
kwatch() {
    if [[ -n "$1" ]]; then
        kubectl get pods -n "$1" -w
    else
        kubectl get pods -w
    fi
}

# klogs - Follow logs with tail (alias for klf)
klogs() {
    kubectl logs -f "$1" --tail=100
}

# kgetl - Get pods by label
kgetl() {
    kubectl get pods -l "$1"
}

# ============================================================================
# Self-test function (used by devsetup test)
# ============================================================================
_test_devtools_k8s() {
    local passed=0 failed=0 warned=0

    # Test that functions are defined
    for func in kns kctx kgp kgpa kl klf kex kdesc kpf kwatch; do
        if typeset -f "$func" > /dev/null 2>&1; then
            ((passed++))
        else
            echo "FAIL: $func not defined"
            ((failed++))
        fi
    done

    # Test kubectl is available
    if command -v kubectl > /dev/null 2>&1; then
        ((passed++))
    else
        echo "WARN: kubectl not installed"
        ((warned++))
    fi

    # Check optional tools
    if ! command -v kubectx > /dev/null 2>&1; then
        echo "WARN: kubectx not installed (kctx won't work)"
        ((warned++))
    fi
    if ! command -v kubens > /dev/null 2>&1; then
        echo "WARN: kubens not installed (kns won't work)"
        ((warned++))
    fi

    echo "K8s functions: $passed passed, $failed failed, $warned warnings"
    return $failed
}
