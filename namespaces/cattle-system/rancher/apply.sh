#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-cattle-system}
if [ "$(eval "kubectl get ns | grep \"${NAMESPACE}\" | awk '{print \$1}'")" != "${NAMESPACE}" ]; then
  eval "kubectl create namespace \"${NAMESPACE}\""
fi

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "NAMESPACE=${NAMESPACE} ./rancher.yml.sh" | eval "${KUBECTL} apply -f -"

## Wait until rancher available
echo 'Wait until rancher available'
while :
do
  if [ $(eval "${KUBECTL} get po | grep cattle | awk 'NR==1{print \$3}' | grep -e 'Running'") ]; then
    break    
  fi
  sleep 1s;
done