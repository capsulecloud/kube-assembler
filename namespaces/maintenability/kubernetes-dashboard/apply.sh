#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

print_green() {
  printf '%b' "\033[92m$1\033[0m\n"
}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-maintenability}
eval "kubectl create namespace \"${NAMESPACE}\""

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "NAMESPACE=${NAMESPACE} ./kubernetes-dashboard-rbac.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "./kubernetes-dashboard.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "NAMESPACE=${NAMESPACE} ./kubernetes-dashboard-account.yaml.sh" | eval "${KUBECTL} apply -f -"

print_green "kubernetes-dashboard login token is"
eval "${KUBECTL} get secret \$(${KUBECTL} get secret | grep webmaster | awk '{print \$1}') -o jsonpath='{.data.token}' && echo"

## Wait until kubernetes-dashboard available
echo 'Wait until kubernetes-dashboard available'
while :
do
  if [ $(eval "${KUBECTL} get po | grep dashboard | awk 'NR==1{print \$3}' | grep -e 'Running'") ]; then
    break    
  fi
  sleep 1s;
done