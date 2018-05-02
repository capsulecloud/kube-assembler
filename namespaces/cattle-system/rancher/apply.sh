#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-cattle-system}
eval "kubectl create namespace ${NAMESPACE}"

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""
KUBE_APPLY="${KUBECTL} apply -f -"

# Deploy
eval "NAMESPACE=${NAMESPACE} ./rancher.yml.sh" | eval "${KUBE_APPLY}"

## Wait until rancher available
echo 'Wait until rancher available'
while :
do
  if [ $(eval "${KUBECTL} get po | grep cattle | awk 'NR==1{print \$3}' | grep -e 'Running'") ]; then
    break    
  fi
  sleep 1s;
done