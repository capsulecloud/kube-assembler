#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
ISSUER_EMAIL=${ISSUER_EMAIL:-webmaster@example.com}
ACME_ENDPOINT=${ACME_ENDPOINT:-https://acme-staging-v02.api.letsencrypt.org/directory}

# Create namespace if not exist
NAMESPACE=${NAMESPACE:-kube-system}
if [ "$(eval "kubectl get ns | grep \"${NAMESPACE}\" | awk '{print \$1}'")" != "${NAMESPACE}" ]; then
  eval "kubectl create namespace \"${NAMESPACE}\""
fi

# Set command scope
KUBECTL="kubectl --namespace=\"${NAMESPACE}\""

## issue certificate
certbot certonly --manual \
-d *.$TARGET_DOMAIN \
-d *.faas.$TARGET_DOMAIN \
-m $ISSUER_EMAIL \
--agree-tos \
--keep-until-expiring \
--no-eff-email \
--manual-public-ip-logging-ok \
--preferred-challenges dns-01 \
--manual-auth-hook ./pre-validation.sh \
--manual-cleanup-hook ./post-validation.sh \
--server $ACME_ENDPOINT

## register certificate
eval "${KUBECTL} create secret generic domain-tls --from-file=tls.crt=/etc/letsencrypt/live/${TARGET_DOMAIN}/fullchain.pem --from-file=tls.key=/etc/letsencrypt/live/${TARGET_DOMAIN}/privkey.pem"
