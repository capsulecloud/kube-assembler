#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-sustainability}
eval "kubectl create namespace \"${NAMESPACE}\""

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Get gogs webmaster
ADMIN_USER_BASE64=$(eval "${KUBECTL} get secret webmaster -o jsonpath='{.data.user}'")
ADMIN_SECRET_BASE64=$(eval "${KUBECTL} get secret webmaster -o jsonpath='{.data.password}'")

# Deploy
eval "NAMESPACE=${NAMESPACE} TARGET_DOMAIN=${TARGET_DOMAIN} ADMIN_USER_BASE64=${ADMIN_USER_BASE64} ADMIN_SECRET_BASE64=${ADMIN_SECRET_BASE64} ./configmap.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "./mysql.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "./drone-server.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "./drone-agent.yaml.sh" | eval "${KUBECTL} apply -f -"

## Wait until drone-server available
echo 'Wait until drone-server available'
while :
do
  if [ $(eval "${KUBECTL} get po | grep drone-server | awk 'NR==1{print \$3}' | grep -e 'Running'") ]; then
    break    
  fi
  sleep 1s;
done