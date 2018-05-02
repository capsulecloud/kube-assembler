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

# OAuth Client for weave
WEAVE_CLIENT_ID=${WEAVE_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
WEAVE_CLIENT_SECRET=${WEAVE_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

## Assemble maintenability
print_green "Starting setup maintenability"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ../namespaces/maintenability/ingress/apply.sh"
eval "../namespaces/maintenability/kubernetes-dashboard/apply.sh"
eval "GITHUB_ORG=${GITHUB_ORG} CLIENT_ID=${WEAVE_CLIENT_ID} CLIENT_SECRET=${WEAVE_CLIENT_SECRET} COOKIE_SECRET=${cookie_secret} ../namespaces/maintenability/auth/apply.sh"
eval "../namespaces/maintenability/weave/apply.sh"

## Finish
print_green "Congratulations!"
print_green "open https://dashboard.${BASE_DOMAIN}/"
print_green "open https://weave.${BASE_DOMAIN}/"