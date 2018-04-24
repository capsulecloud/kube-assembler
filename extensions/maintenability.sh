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

## Assemble cattle-system
print_green "Starting setup kubernetes-dashboard"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./kube-system/ingress/apply.sh"
eval "./kube-system/kubernetes-dashboard/apply.sh"

## Assemble cattle-system
print_green "Starting setup weave"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./weave/ingress/apply.sh"
eval "GITHUB_ORG=${GITHUB_ORG} CLIENT_ID=${WEAVE_CLIENT_ID} CLIENT_SECRET=${WEAVE_CLIENT_SECRET} COOKIE_SECRET=${cookie_secret} ./weave/auth/apply.sh"
eval "./weave/weave/apply.sh"

## Finish
print_green "Congratulations!"
print_green "open https://rancher.${BASE_DOMAIN}/"
print_green "open https://longhorn.${BASE_DOMAIN}/"