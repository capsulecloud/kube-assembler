#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-maintenability}
eval "kubectl create namespace \"${NAMESPACE}\""

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "./weave-scope.yaml.sh" | eval "${KUBECTL} apply -f -"
