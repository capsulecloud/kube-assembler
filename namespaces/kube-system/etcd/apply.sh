#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-kube-system}
eval "kubectl create namespace ${NAMESPACE}"

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""
KUBE_APPLY="${KUBECTL} apply -f -"

# Deploy
eval "NAMESPACE=${NAMESPACE} ./etcd-operator-rbac.yaml.sh" | eval "${KUBE_APPLY}"
eval "./etcd-operator.yaml.sh" | eval "${KUBE_APPLY}"
until [ "$(eval "${KUBECTL} get crd | grep etcdclusters.etcd.database.coreos.com | awk '{print \$1}'")" != "" ]; do sleep 1s; done
eval "./etcd-cluster.yaml.sh" | eval "${KUBE_APPLY}"

