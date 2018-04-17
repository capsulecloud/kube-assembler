#!/bin/bash

NAMESPACE=${NAMESPACE:-longhorn-system}
TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
ETCD_NAMESPACE=${ETCD_NAMESPACE:-kube-system}
LOGLEVEL=${LOGLEVEL:-info}

cat <<EOL
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: $NAMESPACE:external-dns
rules:
- apiGroups:
  - ""
  resources:
  - services
  verbs:
  - get
  - watch
  - list
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch

---

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: $NAMESPACE:external-dns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: $NAMESPACE:external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: $NAMESPACE

---

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: exeternal-dns
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: dev
    spec:
      serviceAccount: external-dns
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: yamazawa/external-dns:coredns
        args:
        - --source=ingress
        - --namespace=$NAMESPACE
        - --domain-filter=$TARGET_DOMAIN
        - --provider=coredns
        - --registry=txt
        - --txt-owner-id=$NAMESPACE
        - --log-level=$LOGLEVEL
        env:
        - name: ETCD_URLS
          value: http://etcd-cluster-client.$ETCD_NAMESPACE.svc.cluster.local:2379
EOL