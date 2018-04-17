#!/bin/bash

NAMESPACE=${NAMESPACE:-kube-system}
TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}

cat <<EOL
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
data:
  Corefile: |
    .:53 {
      etcd $TARGET_DOMAIN {
        path /skydns
        endpoint http://etcd-cluster-client.$NAMESPACE.svc.cluster.local:2379
      }
      errors
      log
    }
EOL