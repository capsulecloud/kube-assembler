#!/bin/bash

cat <<EOL
apiVersion: v1
kind: Service
metadata:
  name: drone-agent
  labels:
    app: drone-agent
    service: cicd
  annotations:
    'prometheus.io/scrape': 'true'
spec:
  ports:
  - name: http
    protocol: TCP
    port: 8000
    targetPort: 8000
  selector:
    app: drone-agent
    service: cicd
  type: ClusterIP

---

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: drone-agent
  labels:
    app: drone-agent
    service: cicd
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: drone-agent
        service: cicd
    spec:
      containers:
      - name: drone-agent
        args:
        - agent
        image: drone/drone:0.8
        ports:
        - name: http
          containerPort: 8000
        securityContext:
          capabilities: {}
          privileged: true
        env:
        - name: DRONE_HOST
          valueFrom:
            configMapKeyRef:
              name: drone
              key: drone_host
        - name: REMOTE_DRIVER
          valueFrom:
            configMapKeyRef:
              name: drone
              key: remote_driver
        - name: REMOTE_CONFIG
          valueFrom:
            configMapKeyRef:
              name: drone
              key: gogs_url
        - name: DRONE_SERVER
          valueFrom:
            configMapKeyRef:
              name: drone
              key: drone_server
        - name: DRONE_DATABASE_DATASOURCE
          valueFrom:
            configMapKeyRef:
              name: drone
              key: drone_db_datasource
        - name: DRONE_GOGS
          valueFrom:
            configMapKeyRef:
              name: drone
              key: gogs
        - name: DRONE_GOGS_PRIVATE_MODE
          valueFrom:
            configMapKeyRef:
              name: drone
              key: gogs_private_mode
        - name: DRONE_DATABASE_DRIVER
          valueFrom:
            configMapKeyRef:
              name: drone
              key: drone_db_driver
        - name: DOCKER_API_VERSION
          valueFrom:
            configMapKeyRef:
              name: drone
              key: docker_api_version
        - name: GIN_MODE
          valueFrom:
            configMapKeyRef:
              name: drone
              key: gin_mode
        # sensitive data
        - name: DRONE_GOGS_GIT_USERNAME
          valueFrom:
            secretKeyRef:
              name: drone
              key: gogs_git_user
        - name: DRONE_GOGS_GIT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: drone
              key: gogs_git_pass
        - name: DRONE_SECRET
          valueFrom:
            secretKeyRef:
              name: drone
              key: drone_agent_secret
        volumeMounts:
        - name: dockersocket
          mountPath: /var/run/docker.sock
      restartPolicy: Always
      volumes:
      - name: dockersocket
        hostPath:
          path: /var/run/docker.sock
EOL