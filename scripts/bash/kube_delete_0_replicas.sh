#!/bin/bash

delete_zero() {
	local namespace="default"
	while [[ $# -gt 0 ]]; do
		case "$1" in
		-n | --namespace)
			namespace="$2"
			shift 2
			;;
		-h | --help)
			echo "Usage: delete_zero [--namespace <namespace>]"
			echo "  -n, --namespace   Base Github URL (default: $namespace)"
			echo "  -h, --help    Show this help message"
			return 0
			;;
		*)
			echo "Unknown argument: $1"
			echo "Use -h or --help for usage information."
			return 1
			;;
		esac
	done
	export namespace
	echo "Deleteing replicasets with 0 replicas in namespace: ${namespace}"
	kubectl -n $namespace get replicaset -o json |
		jq -r '.items[] | select(.spec.replicas == 0) | .metadata.name' |
		xargs kubectl -n $namespace delete replicaset
}
