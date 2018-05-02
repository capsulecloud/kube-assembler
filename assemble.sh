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

if [ ! $SKIP_NODE_SETUP ]; then
  ## Parse IPs
  nodes=(`echo $TARGET_HOSTS | tr -s ',' ' '`)

  ## Setup nodes
  for i in "${!nodes[@]}"; do
      ssh -o StrictHostKeyChecking=no $HOST_USER@${nodes[$i]} "curl $INSTALL_DOCKER | sh" # Install Docker
      ssh $HOST_USER@${nodes[$i]} "sudo usermod -aG docker $HOST_USER" # Add user to Docker group
      ssh $HOST_USER@${nodes[$i]} "sudo apt-get install -y ntp && sudo ntpq -p" # Enabling ntpd time sync
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
fi

## Extensions

### Add rancher.sh
LONGHORN_CLIENT_ID=${LONGHORN_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
LONGHORN_CLIENT_SECRET=${LONGHORN_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
eval "GITHUB_ORG=${GITHUB_ORG} LONGHORN_CLIENT_ID=${LONGHORN_CLIENT_ID} LONGHORN_CLIENT_SECRET=${LONGHORN_CLIENT_SECRET} extensions/rancher.sh"

# ### Add maintenability.sh
# WEAVE_CLIENT_ID=${WEAVE_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
# WEAVE_CLIENT_SECRET=${WEAVE_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
# eval "GITHUB_ORG=${GITHUB_ORG} WEAVE_CLIENT_ID=${WEAVE_CLIENT_ID} WEAVE_CLIENT_SECRET=${WEAVE_CLIENT_SECRET} extensions/maintenability.sh"

# ### Add sustainability.sh
# REGISTRY_CLIENT_ID=${REGISTRY_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
# REGISTRY_CLIENT_SECRET=${REGISTRY_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
# eval "GITHUB_ORG=${GITHUB_ORG} REGISTRY_CLIENT_ID=${REGISTRY_CLIENT_ID} REGISTRY_CLIENT_SECRET=${REGISTRY_CLIENT_SECRET} extensions/sustainability.sh"

# ### Add productivity.sh
# FAAS_CLIENT_ID=${FAAS_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
# FAAS_CLIENT_SECRET=${FAAS_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
# eval "GITHUB_ORG=${GITHUB_ORG} FAAS_CLIENT_ID=${FAAS_CLIENT_ID} FAAS_CLIENT_SECRET=${FAAS_CLIENT_SECRET} extensions/productivity.sh"