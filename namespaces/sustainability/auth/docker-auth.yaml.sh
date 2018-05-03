#!/bin/bash

cat <<EOL
apiVersion: v1
kind: Service
metadata:
  name: docker-auth
spec:
  ports:
  - port: 80
    targetPort: 5001
  selector:
    k8s-app: docker-auth

---

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    k8s-app: docker-auth
  name: docker-auth
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: docker-auth
  template:
    metadata:
      labels:
        k8s-app: docker-auth
    spec:
      containers:
      - args: [ "/config/auth_config.yml" ]
        image: cesanta/docker_auth
        imagePullPolicy: IfNotPresent
        name: docker-auth
        volumeMounts:
        - name: config-volume
          mountPath: /config
        - name: domain-tls
          mountPath: /certs
        ports:
        - containerPort: 5001
          protocol: TCP
      volumes:
        - name: config-volume
          configMap:
            name: docker-auth
            items:
            - key: AuthConfig
              path: auth_config.yml
        - name: domain-tls
          secret:
            secretName: domain-tls
EOL