#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

GITHUB_ORG=${GITHUB_ORG:-example-org}
REGISTRY_CLIENT_ID=${REGISTRY_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
REGISTRY_CLIENT_SECRET=${REGISTRY_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-sustainability}
eval "kubectl create namespace \"${NAMESPACE}\""

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "GITHUB_ORG=${GITHUB_ORG} REGISTRY_CLIENT_ID=${REGISTRY_CLIENT_ID} REGISTRY_CLIENT_SECRET=${REGISTRY_CLIENT_SECRET} ./docker-auth-configmap.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "./docker-auth.yaml.sh" | eval "${KUBECTL} apply -f -"

