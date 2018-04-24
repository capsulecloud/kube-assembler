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

# OAuth Client for openfaas
FAAS_CLIENT_ID=${FAAS_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
FAAS_CLIENT_SECRET=${FAAS_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

## Assemble objectstorage
print_green "Starting setup minio"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./object-storage/ingress/apply.sh"
eval "TARGET_DOMAIN=${BASE_DOMAIN} ./object-storage/minio/apply.sh"

## Assemble faas
print_green "Starting setup openfaas"
eval "TARGET_DOMAIN=${BASE_DOMAIN} TARGET_HOSTS=${TARGET_HOSTS} ./openfaas/ingress/apply.sh"
eval "GITHUB_ORG=${GITHUB_ORG} CLIENT_ID=${FAAS_CLIENT_ID} CLIENT_SECRET=${FAAS_CLIENT_SECRET} COOKIE_SECRET=${cookie_secret} ./openfaas/auth/apply.sh"
eval "./openfaas/faas-netes/apply.sh"

## Finish
print_green "Congratulations!"
print_green "open https://rancher.${BASE_DOMAIN}/"
print_green "open https://longhorn.${BASE_DOMAIN}/"