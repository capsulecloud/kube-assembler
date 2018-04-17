#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
TARGET_HOSTS=${TARGET_HOSTS:-1.1.1.1,2.2.2.2,3.3.3.3}
ORIGIN_NAMESPACE=${ORIGIN_NAMESPACE:-kube-system}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-longhorn-system}
if [ "$(eval "kubectl get ns | grep \"${NAMESPACE}\" | awk '{print \$1}'")" != "${NAMESPACE}" ]; then
  eval "kubectl create namespace \"${NAMESPACE}\""
fi

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "kubectl --namespace ${ORIGIN_NAMESPACE} get secrets domain-tls -o json" | eval "jq '.metadata.namespace = \"${NAMESPACE}\"'" | eval "kubectl create -f  -"
eval "NAMESPACE=${NAMESPACE} TARGET_DOMAIN=${TARGET_DOMAIN} ./external-dns.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "TARGET_DOMAIN=${TARGET_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./ingress.yaml.sh" | eval "${KUBECTL} apply -f -"
