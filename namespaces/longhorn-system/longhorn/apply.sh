#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-longhorn-system}
eval "kubectl create namespace ${NAMESPACE}"

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""
KUBE_APPLY="${KUBECTL} apply -f -"

# Deploy
eval "./longhorn-crd.yaml" | eval "${KUBE_APPLY}"
eval "./longhorn-rbac.yaml.sh" | eval "${KUBE_APPLY}"
eval "./longhorn.yaml" | eval "${KUBE_APPLY}"
eval "./longhorn-storageclass.yaml" | eval "${KUBE_APPLY}"

## Wait until longhorn available
echo 'Wait until longhorn available'
while :
do
  if [ $(eval "${KUBECTL} get po | grep longhorn-ui | awk 'NR==1{print \$3}' | grep -e 'Running'") ]; then
    break    
  fi
  sleep 1s;
done