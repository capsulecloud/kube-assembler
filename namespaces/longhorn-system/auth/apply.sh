#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

GITHUB_ORG=${GITHUB_ORG:-YOUR_GIRHUB_ORG}
CLIENT_ID=${CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
CLIENT_SECRET=${CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
COOKIE_SECRET=${COOKIE_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXX}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-longhorn-system}
eval "kubectl create namespace ${NAMESPACE}"

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""
KUBE_APPLY="${KUBECTL} apply -f -"

# Deploy
eval "CLIENT_ID=${CLIENT_ID} CLIENT_SECRET=${CLIENT_SECRET} COOKIE_SECRET=${COOKIE_SECRET} ./domain-secret.yaml.sh" | eval "${KUBE_APPLY}"
eval "GITHUB_ORG=${GITHUB_ORG} ./oauth2-proxy.yaml.sh" | eval "${KUBE_APPLY}"