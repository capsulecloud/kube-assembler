#!/bin/bash

GITHUB_ORG=${GITHUB_ORG:-YOUR_GIRHUB_ORG}

cat <<EOL
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: oauth2-proxy
  name: oauth2-proxy
spec:
  ports:
  - name: http
    port: 4180
    protocol: TCP
    targetPort: 4180
  selector:
    k8s-app: oauth2-proxy

---

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    k8s-app: oauth2-proxy
  name: oauth2-proxy
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: oauth2-proxy
  template:
    metadata:
      labels:
        k8s-app: oauth2-proxy
    spec:
      containers:
      - args:
        - --provider=gitlab
        - --email-domain=*
        - --upstream=file:///dev/null
        - --http-address=0.0.0.0:4180
        - --login-url=https://gitlab.com/oauth/authorize 
        - --redeem-url=https://gitlab.com/oauth/token 
        - --validate-url=https://gitlab.com/api/v4/user
        env:
        - name: OAUTH2_PROXY_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: domain-secret
              key: clientID
        - name: OAUTH2_PROXY_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: domain-secret
              key: clientSecret
        # python -c 'import os,base64; print base64.b64encode(os.urandom(16))'
        - name: OAUTH2_PROXY_COOKIE_SECRET
          valueFrom:
            secretKeyRef:
              name: domain-secret
              key: cookieSecret
        image: a5huynh/oauth2_proxy:2.2-debian
        imagePullPolicy: Always
        name: oauth2-proxy
        ports:
        - containerPort: 4180
          protocol: TCP
EOL