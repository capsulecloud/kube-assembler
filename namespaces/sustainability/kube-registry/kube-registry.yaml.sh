#!/bin/bash

TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
AUTH_DOMAIN=${AUTH_DOMAIN:-auth.$TARGET_DOMAIN}

cat <<EOL
apiVersion: v1
kind: Service
metadata:
  name: registry
spec:
  ports:
  - port: 80
    targetPort: 5000
  selector:
    k8s-app: kube-registry

---

apiVersion: v1
kind: ReplicationController
metadata:
  name: kube-registry-v0
  labels:
    k8s-app: kube-registry
    version: v0
    kubernetes.io/cluster-service: "true"
spec:
  replicas: 1
  selector:
    k8s-app: kube-registry
    version: v0
  template:
    metadata:
      labels:
        k8s-app: kube-registry
        version: v0
        kubernetes.io/cluster-service: "true"
    spec:
      containers:
      - name: registry
        image: registry:2
        resources:
          limits:
            cpu: 100m
            memory: 100Mi
        env:
        - name: REGISTRY_HTTP_ADDR
          value: :5000
        - name: REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY
          value: /var/lib/registry
        - name: REGISTRY_AUTH
          value: token
        - name: REGISTRY_AUTH_TOKEN_REALM
          value: https://$AUTH_DOMAIN/auth
        - name: REGISTRY_AUTH_TOKEN_SERVICE
          value: "Docker registry"
        - name: REGISTRY_AUTH_TOKEN_ISSUER
          value: "Auth Service"
        - name: REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE
          value: /certs/tls.crt
        volumeMounts:
        - name: image-store
          mountPath: /var/lib/registry
        - name: domain-tls
          mountPath: /certs
        ports:
        - containerPort: 5000
          name: registry
          protocol: TCP
      volumes:
      - name: image-store
        flexVolume:
          driver: "rancher.io/longhorn"
          fsType: "ext4"
          options:
            size: "2Gi"
            numberOfReplicas: "3"
            staleReplicaTimeout: "20"
            fromBackup: ""
      - name: domain-tls
        secret:
          secretName: domain-tls
EOL