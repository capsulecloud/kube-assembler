#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-kube-system}
if [ "$(eval "kubectl get ns | grep \"${NAMESPACE}\" | awk '{print \$1}'")" != "${NAMESPACE}" ]; then
  eval "kubectl create namespace \"${NAMESPACE}\""
fi

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "NAMESPACE=${NAMESPACE} ./etcd-operator-rbac.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "${KUBECTL} apply -f etcd-operator.yaml"
until [ "$(eval "${KUBECTL} get crd | grep etcdclusters.etcd.database.coreos.com | awk '{print \$1}'")" != "" ]; do sleep 1s; done
eval "${KUBECTL} apply -f etcd-cluster.yaml"

