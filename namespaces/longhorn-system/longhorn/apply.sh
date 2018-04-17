#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-longhorn-system}
if [ "$(eval "kubectl get ns | grep \"${NAMESPACE}\" | awk '{print \$1}'")" != "${NAMESPACE}" ]; then
  eval "kubectl create namespace \"${NAMESPACE}\""
fi

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "${KUBECTL} create --save-config -f longhorn-crd.yaml"
eval "./longhorn-rbac.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "${KUBECTL} create --save-config -f longhorn.yaml"
eval "${KUBECTL} create --save-config -f longhorn-storageclass.yaml"

## Wait until longhorn available
echo 'Wait until longhorn available'
while :
do
  if [ $(eval "${KUBECTL} get po | grep longhorn-ui | awk 'NR==1{print \$3}' | grep -e 'Running'") ]; then
    break    
  fi
  sleep 1s;
done