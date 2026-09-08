# ============================================================================
# aliases.zsh — shell aliases & helper functions (sourced from ~/.zshrc)
# ============================================================================

# ----------------------------------------------------------------------------
# Kubernetes & infrastructure
# ----------------------------------------------------------------------------
# Requires: kubectl, kubectx (provides `kubectx` + `kubens`), fzf.
# All installed via the Brewfile.

# k — the workhorse. `k get pods`, `k apply -f x.yaml`, etc.
alias k="kubectl"

# kc — kubectl config. Manage contexts/clusters/users.
#   kc get-contexts        list all contexts
#   kc use-context <ctx>   switch context
alias kc="kubectl config"

# kx — switch kube CONTEXT (which cluster you talk to).
#   kx            interactive picker (fzf) of all contexts
#   kx <context>  switch directly
alias kx="kubectx"

# kn — switch kube NAMESPACE for the current context.
#   kn            interactive picker of namespaces
#   kn <ns>       switch directly
alias kn="kubens"

# kpod — list pod NAMES matching a pattern (one name per line).
# Pipes `kubectl get pods` through grep_pod (below).
#   kpod api           -> names of all pods containing "api"
#   kpod ""            -> names of every pod
alias kpod="kubectl get pods | grep_pod"

# grep_pod — filter a `kubectl get pods` stream to just the pod name column.
#   kubectl get pods | grep_pod <pattern>
grep_pod() {
  grep "$1" | awk '{print $1}'
}

# grep_copy_pod — same as grep_pod but copies the matched name to the clipboard.
#   kubectl get pods | grep_copy_pod <pattern>
grep_copy_pod() {
  grep "$1" | awk '{print $1}' | pbcopy
}

# kexec — exec into a pod by name pattern (opens a shell, or runs a command).
# If the pattern matches multiple pods, fzf lets you pick one.
#   kexec api                      # /bin/bash in the "api" pod
#   kexec api -c sidecar           # /bin/bash in the "sidecar" container
#   kexec api -c sidecar ls /tmp   # run `ls /tmp` in that container
#   kexec api sh                   # (no -c) run a custom cmd in the default container
kexec() {
  # kexec <pod-pattern> [-c <container>] [cmd...]
  local pod
  pod=$(kpod "$1")
  # Multiple replicas can match; let fzf pick one.
  [[ $(echo "$pod" | wc -l) -gt 1 ]] && pod=$(echo "$pod" | fzf --layout=reverse)

  if [[ "$2" == "-c" ]]; then
    local container="$3"
    if [[ -z "$4" ]]; then
      kubectl exec -it "$pod" -c "$container" -- /bin/bash
    else
      kubectl exec -it "$pod" -c "$container" -- "${@:4}"
    fi
    return
  fi

  if [[ -z "$2" ]]; then
    kubectl exec -it "$pod" -- /bin/bash
  else
    kubectl exec -it "$pod" -- "${@:2}"
  fi
}
