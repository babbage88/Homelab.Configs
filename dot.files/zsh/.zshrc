autoload -U compinit
compinit

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration
ZSH_THEME=robbyrussell

# set PATH so it includes /usr/local/go/bin if it exists
if [ -d "/usr/local/go/bin" ] ; then
    PATH="/usr/local/go/bin:$PATH"
fi

PATH="$HOME/.local/bin:$PATH"

alias lsz="ls -l --block-size=G"

#alias grab-token="export TEST_TOKEN=$(curl -s -X POST http://localhost:8993/login -H 'Content-Type: application/json' -d '{"username": "jt", "password": "testpw"}' | jq -r .token)"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform

# >>> b2 autocomplete >>>
# This section is managed by b2 . Manual edit may break automated updates.
if [[ -z "$_comps" ]] && [[ -t 0 ]]; then autoload -Uz compinit && compinit -i -D; fi
source /home/jtrahan/.zsh/completion/_b2

# <<< b2 autocomplete <<<
source <(kubectl completion zsh)

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

export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

alias cls='clear'
