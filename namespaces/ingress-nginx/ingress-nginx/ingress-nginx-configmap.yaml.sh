#!/bin/bash

DNS_NAMESPACE=${DNS_NAMESPACE:-kube-system}

cat <<EOL
apiVersion: v1
data:
  "53": "$DNS_NAMESPACE/public-dns:53"
kind: ConfigMap
metadata:
  name: tcp-services

---

apiVersion: v1
data:
  "53": "$DNS_NAMESPACE/public-dns:53"
kind: ConfigMap
metadata:
  name: udp-services
EOL