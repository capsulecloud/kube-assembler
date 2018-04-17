#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

# Create TXT record
CREATE_DOMAIN="_acme-challenge.$CERTBOT_DOMAIN"

NAMESPACE=${NAMESPACE:-kube-system}
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

## Create etcd path
domain=(`echo $CREATE_DOMAIN | tr -s '.' ' '`)
reverse=""
for (( idx=${#domain[@]}-1 ; idx>=0 ; idx-- )) ; do
    reverse="$reverse/${domain[idx]}"
done

eval "${KUBECTL} exec \$(${KUBECTL} get po | grep etcd-cluster | awk 'NR==1{print \$1}') etcdctl set /skydns$reverse '{\"text\":\"${CERTBOT_VALIDATION}\"}'"

sleep 26s