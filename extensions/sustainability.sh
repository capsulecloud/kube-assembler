#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

print_red() {
  printf '%b' "\033[91m$1\033[0m\n"
}

print_green() {
  printf '%b' "\033[92m$1\033[0m\n"
}

BASE_DOMAIN=${BASE_DOMAIN:-example.com}
TARGET_HOSTS=${TARGET_HOSTS:-1.1.1.1,2.2.2.2,3.3.3.3}
GITHUB_ORG=${GITHUB_ORG:-YOUR_GIRHUB_ORG}

## Generate COOKIE_SECRET
cookie_secret=$(date +%s | sha256sum | base64 | head -c 32 ; echo)

# OAuth Client for registry
REGISTRY_CLIENT_ID=${REGISTRY_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
REGISTRY_CLIENT_SECRET=${REGISTRY_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

## Assemble cattle-system
print_green "Starting setup registry"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./registry/ingress/apply.sh"
eval "GITHUB_ORG=${GITHUB_ORG} REGISTRY_CLIENT_ID=${REGISTRY_CLIENT_ID} REGISTRY_CLIENT_SECRET=${REGISTRY_CLIENT_SECRET} ./registry/auth/apply.sh"
eval "TARGET_DOMAIN=${BASE_DOMAIN} ./registry/kube-registry/apply.sh"

## Assemble cattle-system
print_green "Starting setup gogs"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./vsc/ingress/apply.sh"
eval "TARGET_DOMAIN=${BASE_DOMAIN} ./vsc/gogs/apply.sh"

## Assemble cattle-system
print_green "Starting setup drone"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./cicd/ingress/apply.sh"
eval "TARGET_DOMAIN=${BASE_DOMAIN} ./cicd/drone/apply.sh"

## Finish
print_green "Congratulations!"
print_green "open https://rancher.${BASE_DOMAIN}/"
print_green "open https://longhorn.${BASE_DOMAIN}/"