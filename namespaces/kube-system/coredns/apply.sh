#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

print_green() {
  printf '%b' "\033[92m$1\033[0m\n"
}

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
TARGET_HOSTS=${TARGET_HOSTS:-1.1.1.1,2.2.2.2,3.3.3.3}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-kube-system}
if [ "$(eval "kubectl get ns | grep \"${NAMESPACE}\" | awk '{print \$1}'")" != "${NAMESPACE}" ]; then
  eval "kubectl create namespace \"${NAMESPACE}\""
fi

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

# Deploy
eval "NAMESPACE=${NAMESPACE} ./coredns-rbac.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "NAMESPACE=${NAMESPACE} ./coredns-configmap.yaml.sh" | eval "${KUBECTL} apply -f -"
eval "${KUBECTL} apply -f coredns.yaml"

## Wait until etcd-cluster available
echo 'Wait until etcd-cluster available'
while :
do
  if [ $(eval "${KUBECTL} get po | grep etcd-cluster | awk 'NR==1{print \$3}' | grep -e 'Running'") ]; then
    break    
  fi
  sleep 1s;
done

sleep 60s;

## Create etcd path
domain=(`echo $TARGET_DOMAIN | tr -s '.' ' '`)
reverse=""
for (( idx=${#domain[@]}-1 ; idx>=0 ; idx-- )) ; do
    reverse="$reverse/${domain[idx]}"
done

## Set NameServer A records
arr=(`echo $TARGET_HOSTS | tr -s ',' ' '`)
for i in "${!arr[@]}"; do
  print_green "ns$((i+1)).ns.dns.$TARGET_DOMAIN"
  eval "${KUBECTL} exec \$(${KUBECTL} get po | grep etcd-cluster | awk 'NR==1{print \$1}') -- etcdctl set /skydns$reverse/dns/ns/ns$((i+1)) '{\"host\":\"${arr[i]}\"}'"
  sleep 3s;
done

