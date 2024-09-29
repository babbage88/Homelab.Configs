#!/usr/bin/sh
# Function to start an interactive shell in the specified pod
podterm() {
    local pod_name=$1
    if [[ -z "$pod_name" ]]; then
        echo "Please specify the pod name."
        return 1
    fi
    kubectl exec --stdin --tty "$pod_name" -- /bin/sh
}

# Auto-completion for pod names
_podterm_completion() {
    local pods=($(kubectl get pods --no-headers -o custom-columns=:metadata.name 2>/dev/null))
    _describe 'pods' pods
}

# Register the auto-completion for the podterm function
compdef _podterm_completion podterm

# Function to list pods on a specific node
nodepods() {
    local node_name=$1
    if [[ -z "$node_name" ]]; then
        echo "Please specify the node name."
        return 1
    fi
    kubectl get pods --field-selector spec.nodeName="$node_name"
}

# Auto-completion for node names
_nodepods_completion() {
    local nodes=($(kubectl get nodes --no-headers -o custom-columns=:metadata.name 2>/dev/null))
    _describe 'nodes' nodes
}

# Register the auto-completion for the nodepods function
compdef _nodepods_completion nodepods