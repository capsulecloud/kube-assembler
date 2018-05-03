#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
WEB_MASTER=${WEB_MASTER:-webmaster}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-sustainability}
eval "kubectl create namespace \"${NAMESPACE}\""

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Create webmaster
master_secret=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
eval "${KUBECTL} create secret generic webmaster --from-literal=user=${WEB_MASTER} --from-literal=password=${master_secret}"

# Deploy
eval "NAMESPACE=${NAMESPACE} TARGET_DOMAIN=${TARGET_DOMAIN} ./configmap.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "./postgres.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "./gogs.yaml.sh" | eval "${KUBECTL} apply -f -"

## Wait until gogs available
echo 'Wait until gogs available'
while :
do
  if [ $(eval "${KUBECTL} get po | grep gogs | awk 'NR==1{print \$3}' | grep -e 'Running'") ]; then
    break    
  fi
  sleep 1s;
done

## Create user
webmaster=$(eval "${KUBECTL} get secret webmaster -o jsonpath='{.data.user}' | base64 -d")
secret=$(eval "${KUBECTL} get secret webmaster -o jsonpath='{.data.password}' | base64 -d")
eval "${KUBECTL} exec \$(${KUBECTL} get po | grep gogs | awk '{print \$1}') -- bash -c 'USER=git /app/gogs/gogs admin create-user --name ${webmaster} --password ${secret} --admin --email ${webmaster}@${TARGET_DOMAIN}'"
eval "${KUBECTL} exec \$(${KUBECTL} get po | grep gogs | awk '{print \$1}') -- bash -c 'chown -R git:git /data/git/gogs-repositories'"
