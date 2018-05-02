#!/bin/bash

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
RANCHER_DOMAIN=${RANCHER_DOMAIN:-rancher.$TARGET_DOMAIN}
TARGET_HOSTS=${TARGET_HOSTS:-1.1.1.1,2.2.2.2,3.3.3.3}

cat <<EOL
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: cattle-ingress-http
  annotations:
    kubernetes.io/ingress.class: "nginx"
    external-dns.alpha.kubernetes.io/target: $TARGET_HOSTS
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "30"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "1800"   # Max time in seconds for ws to remain shell window open
    nginx.ingress.kubernetes.io/proxy-send-timeout: "1800"   # Max time in seconds for ws to remain shell window openspec:
spec:
  tls:
  - hosts:
    - $RANCHER_DOMAIN
    secretName: domain-tls
  rules:
  - host: $RANCHER_DOMAIN
    http:
      paths:
      - backend:
          serviceName: cattle-service
          servicePort: 80
      - backend:
          serviceName: cattle-service
          servicePort: 443
EOL