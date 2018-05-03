#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-sustainability}
eval "kubectl create namespace \"${NAMESPACE}\""

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "TARGET_DOMAIN=${TARGET_DOMAIN} ./kube-registry.yaml.sh" | eval "${KUBECTL} apply -f -"
