#!/bin/bash

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
WEAVE_DOMAIN=${WEAVE_DOMAIN:-weave.$TARGET_DOMAIN}
DASHBOARD_DOMAIN=${DASHBOARD_DOMAIN:-dashboard.$TARGET_DOMAIN}
TARGET_HOSTS=${TARGET_HOSTS:-1.2.3.4,5.6.7.8}

cat <<EOL
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: dashboard
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/secure-backends: "true"
    external-dns.alpha.kubernetes.io/target: $TARGET_HOSTS
spec:
  tls:
  - hosts:
    - $DASHBOARD_DOMAIN
    secretName: domain-tls
  rules:
  - host: $DASHBOARD_DOMAIN
    http:
      paths:
      - path: /
        backend:
          serviceName: kubernetes-dashboard
          servicePort: 443

---

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: weave
  annotations:
    kubernetes.io/ingress.class: "nginx"
    external-dns.alpha.kubernetes.io/target: $TARGET_HOSTS
    nginx.ingress.kubernetes.io/auth-signin: https://$WEAVE_DOMAIN/oauth2/start
    nginx.ingress.kubernetes.io/auth-url: https://$WEAVE_DOMAIN/oauth2/auth
spec:
  tls:
  - hosts:
    - $WEAVE_DOMAIN
    secretName: domain-tls
  rules:
  - host: $WEAVE_DOMAIN
    http:
      paths:
      - backend:
          serviceName: weave-scope-app
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
    - $WEAVE_DOMAIN
    secretName: domain-tls
  rules:
  - host: $WEAVE_DOMAIN
    http:
      paths:
      - backend:
          serviceName: oauth2-proxy
          servicePort: 4180
        path: /oauth2
EOL