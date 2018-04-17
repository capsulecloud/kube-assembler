#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

DNS_NAMESPACE=${DNS_NAMESPACE:-kube-system}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-ingress-nginx}
if [ "$(eval "kubectl get ns | grep \"${NAMESPACE}\" | awk '{print \$1}'")" != "${NAMESPACE}" ]; then
  eval "kubectl create namespace \"${NAMESPACE}\""
fi

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "DNS_NAMESPACE=${DNS_NAMESPACE} ./ingress-nginx-configmap.yaml.sh" | eval "${KUBECTL} apply -f -"
