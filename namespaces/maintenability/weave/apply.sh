#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-maintenability}
eval "kubectl create namespace \"${NAMESPACE}\""

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "./weave-scope.yaml.sh" | eval "${KUBECTL} apply -f -"

## Wait until weave-scope available
echo 'Wait until weave-scope available'
while :
do
  if [ $(eval "${KUBECTL} get po | grep weave-scope-app | awk 'NR==1{print \$3}' | grep -e 'Running'") ]; then
    break    
  fi
  sleep 1s;
done