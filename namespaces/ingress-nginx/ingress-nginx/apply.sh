#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

DNS_NAMESPACE=${DNS_NAMESPACE:-kube-system}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-ingress-nginx}
eval "kubectl create namespace ${NAMESPACE}"

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""
KUBE_APPLY="${KUBECTL} apply -f -"

# Deploy
eval "DNS_NAMESPACE=${DNS_NAMESPACE} ./ingress-nginx-configmap.yaml.sh" | eval "${KUBE_APPLY}"
