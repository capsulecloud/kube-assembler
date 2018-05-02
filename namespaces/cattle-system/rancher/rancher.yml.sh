#!/bin/bash

NAMESPACE=${NAMESPACE:-cattle-system}

cat <<EOL
kind: ServiceAccount
apiVersion: v1
metadata:
  name: cattle-admin

--- 

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cattle-crb
subjects:
- kind: ServiceAccount
  name: cattle-admin
  namespace: $NAMESPACE
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io

---

apiVersion: v1
kind: Service
metadata:
  name: cattle-service
  labels:
    app: cattle
spec:
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  - port: 443
    targetPort: 443
    protocol: TCP
    name: https
  selector:
    app: cattle

---

kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: cattle
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: cattle
    spec:
      serviceAccountName: cattle-admin
      containers:
      - image: rancher/rancher:master
        imagePullPolicy: Always
        name: cattle-server
        ports:
        - containerPort: 80
          protocol: TCP
        - containerPort: 443
          protocol: TCP
EOL