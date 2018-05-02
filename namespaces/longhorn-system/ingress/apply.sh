#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
TARGET_HOSTS=${TARGET_HOSTS:-1.1.1.1,2.2.2.2,3.3.3.3}
ORIGIN_NAMESPACE=${ORIGIN_NAMESPACE:-kube-system}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-longhorn-system}
eval "kubectl create namespace ${NAMESPACE}"

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""
KUBE_APPLY="${KUBECTL} apply -f -"

# Deploy
eval "kubectl --namespace ${ORIGIN_NAMESPACE} get secrets domain-tls -o json" | eval "jq '.metadata.namespace = \"${NAMESPACE}\"'" | eval "${KUBE_APPLY}"
eval "NAMESPACE=${NAMESPACE} TARGET_DOMAIN=${TARGET_DOMAIN} ./external-dns.yaml.sh" | eval "${KUBE_APPLY}"
eval "TARGET_DOMAIN=${TARGET_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./ingress.yaml.sh" | eval "${KUBE_APPLY}"
