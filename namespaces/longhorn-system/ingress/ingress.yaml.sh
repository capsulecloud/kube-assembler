#!/bin/bash

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
LONGHORN_DOMAIN=${LONGHORN_DOMAIN:-longhorn.$TARGET_DOMAIN}
TARGET_HOSTS=${TARGET_HOSTS:-1.1.1.1,2.2.2.2,3.3.3.3}

cat <<EOL
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: longhorn
  annotations:
    kubernetes.io/ingress.class: "nginx"
    external-dns.alpha.kubernetes.io/target: $TARGET_HOSTS
    nginx.ingress.kubernetes.io/auth-signin: https://$LONGHORN_DOMAIN/oauth2/start
    nginx.ingress.kubernetes.io/auth-url: https://$LONGHORN_DOMAIN/oauth2/auth
spec:
  tls:
  - hosts:
    - $LONGHORN_DOMAIN
    secretName: domain-tls
  rules:
  - host: $LONGHORN_DOMAIN
    http:
      paths:
      - backend:
          serviceName: longhorn-frontend
          servicePort: 80
        
---

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: oauth2-proxy
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  tls:
  - hosts:
    - $LONGHORN_DOMAIN
    secretName: domain-tls
  rules:
  - host: $LONGHORN_DOMAIN
    http:
      paths:
      - backend:
          serviceName: oauth2-proxy
          servicePort: 4180
        path: /oauth2
EOL