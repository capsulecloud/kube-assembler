#!/bin/bash

NAMESPACE=${NAMESPACE:-maintenability}

cat <<EOL
apiVersion: v1
kind: ServiceAccount
metadata:
  name: webmaster

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: webmaster
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: webmaster
  namespace: $NAMESPACE
EOL