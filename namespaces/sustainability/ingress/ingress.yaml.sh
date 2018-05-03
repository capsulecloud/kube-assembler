#!/bin/bash

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
DRONE_DOMAIN=${DRONE_DOMAIN:-drone.$TARGET_DOMAIN}
GOGS_DOMAIN=${GOGS_DOMAIN:-gogs.$TARGET_DOMAIN}
REGISTRY_DOMAIN=${REGISTRY_DOMAIN:-registry.$TARGET_DOMAIN}
AUTH_DOMAIN=${AUTH_DOMAIN:-auth.$TARGET_DOMAIN}
TARGET_HOSTS=${TARGET_HOSTS:-1.2.3.4,5.6.7.8}

cat <<EOL
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: drone
  annotations:
    kubernetes.io/ingress.class: "nginx"
    external-dns.alpha.kubernetes.io/target: $TARGET_HOSTS
spec:
  tls:
  - hosts:
    - $DRONE_DOMAIN
    secretName: domain-tls
  rules:
  - host: $DRONE_DOMAIN
    http:
      paths:
      - backend:
          serviceName: drone-server
          servicePort: 8000

---

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: gogs
  annotations:
    kubernetes.io/ingress.class: "nginx"
    external-dns.alpha.kubernetes.io/target: $TARGET_HOSTS
spec:
  tls:
  - hosts:
    - $GOGS_DOMAIN
    secretName: domain-tls
  rules:
  - host: $GOGS_DOMAIN
    http:
      paths:
      - backend:
          serviceName: gogs
          servicePort: 3000

---

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: registry
  annotations:
    kubernetes.io/ingress.class: "nginx"
    external-dns.alpha.kubernetes.io/target: $TARGET_HOSTS
    nginx.ingress.kubernetes.io/proxy-buffering: "on"
    nginx.ingress.kubernetes.io/client-body-buffer-size: 1000m
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
spec:
  tls:
  - hosts:
    - $REGISTRY_DOMAIN
    secretName: domain-tls
  rules:
  - host: $REGISTRY_DOMAIN
    http:
      paths:
      - path: /
        backend:
          serviceName: registry
          servicePort: 80

---

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: docker-auth
  annotations:
    kubernetes.io/ingress.class: "nginx"
    external-dns.alpha.kubernetes.io/target: $TARGET_HOSTS
spec:
  tls:
  - hosts:
    - $AUTH_DOMAIN
    secretName: domain-tls
  rules:
  - host: $AUTH_DOMAIN
    http:
      paths:
      - path: /
        backend:
          serviceName: docker-auth
          servicePort: 80
EOL