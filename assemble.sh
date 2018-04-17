#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

### ENV
HOST_USER=${HOST_USER:-root}
TARGET_HOSTS=${TARGET_HOSTS:-1.1.1.1,2.2.2.2,3.3.3.3}
INSTALL_DOCKER=${INSTALL_DOCKER:-https://releases.rancher.com/install-docker/17.03.sh}
ACME_ENDPOINT=${ACME_ENDPOINT:-https://acme-v02.api.letsencrypt.org/directory}
BASE_DOMAIN=${BASE_DOMAIN:-example.com}
ISSUER_EMAIL=${ISSUER_EMAIL:-webmaster@example.com}
GITHUB_ORG=${GITHUB_ORG:-YOUR_GIRHUB_ORG}
LONGHORN_CLIENT_ID=${LONGHORN_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
LONGHORN_CLIENT_SECRET=${LONGHORN_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

## Parse IPs
nodes=(`echo $TARGET_HOSTS | tr -s ',' ' '`)

## generate COOKIE_SECRET
cookie_secret=$(date +%s | sha256sum | base64 | head -c 32 ; echo)

## Setup nodes
for i in "${!nodes[@]}"; do
    ssh -o StrictHostKeyChecking=no $HOST_USER@${nodes[$i]} "curl $INSTALL_DOCKER | sh" # Install Docker
    ssh $HOST_USER@${nodes[$i]} "sudo usermod -aG docker $HOST_USER" # Add user to Docker group
    ssh $HOST_USER@${nodes[$i]} "sudo apt-get install -y open-iscsi" # Install open-iscsi for longhorn dependency
done

## Write RKE config (cluster.yml)
eval "NODE01=${nodes[0]} NODE02=${nodes[1]} NODE03=${nodes[2]} HOST_USER=${HOST_USER} ./cluster.yml.sh > cluster.yml"

## Startup cluster
eval "rke up"

## Check nodes
eval "kubectl get node -o wide"

## Assemble kube-system
eval "./namespaces/kube-system/etcd/apply.sh"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./namespaces/kube-system/coredns/apply.sh"
eval "./namespaces/ingress-nginx/ingress-nginx/apply.sh"

## Wait until PublicDNS available
echo 'Wait until PublicDNS available'
while :
do
  if [ $(dig a +noall +answer +short ns1.ns.dns.${BASE_DOMAIN} | grep -e "${nodes[0]}") ]; then
    break    
  fi
  sleep 1s;
done

## Challenge to DNS-01 
eval "ISSUER_EMAIL=${ISSUER_EMAIL} TARGET_DOMAIN=${BASE_DOMAIN} ACME_ENDPOINT=${ACME_ENDPOINT} ./namespaces/kube-system/certbot/apply.sh"

## Assemble cattle-system
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./namespaces/cattle-system/ingress/apply.sh"
eval "TARGET_DOMAIN=${BASE_DOMAIN} ./namespaces/cattle-system/rancher/apply.sh"

## Assemble longhorn-system with OAuth
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./namespaces/longhorn-system/ingress/apply.sh"
eval "GITHUB_ORG=${GITHUB_ORG} CLIENT_ID=${LONGHORN_CLIENT_ID} CLIENT_SECRET=${LONGHORN_CLIENT_SECRET} COOKIE_SECRET=${cookie_secret} ./namespaces/longhorn-system/auth/apply.sh"
eval "./namespaces/longhorn-system/longhorn/apply.sh"

echo "Congratulations!"
echo "open https://rancher.${BASE_DOMAIN}/"
echo "open https://longhorn.${BASE_DOMAIN}/"