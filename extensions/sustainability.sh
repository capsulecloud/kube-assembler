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

## Assemble sustainability
print_green "Starting setup ingress"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ../namespaces/sustainability/ingress/apply.sh"
eval "GITHUB_ORG=${GITHUB_ORG} REGISTRY_CLIENT_ID=${REGISTRY_CLIENT_ID} REGISTRY_CLIENT_SECRET=${REGISTRY_CLIENT_SECRET} ../namespaces/sustainability/auth/apply.sh"

print_green "Starting setup registry"
eval "TARGET_DOMAIN=${BASE_DOMAIN} ../namespaces/sustainability/kube-registry/apply.sh"

print_green "Starting setup gogs"
eval "TARGET_DOMAIN=${BASE_DOMAIN} ../namespaces/sustainability/gogs/apply.sh"

# print_green "Starting setup drone"
# eval "TARGET_DOMAIN=${BASE_DOMAIN} ../namespaces/sustainability/drone/apply.sh"

## Finish
print_green "Congratulations!"
print_green "open https://auth.${BASE_DOMAIN}/github_auth"
print_green "open https://gogs.${BASE_DOMAIN}/"
# print_green "open https://drone.${BASE_DOMAIN}/"