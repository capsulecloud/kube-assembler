#!/bin/bash

cat <<EOL
apiVersion: v1
kind: Service
metadata:
  name: drone-server
  labels:
    app: drone-server
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
    app: drone-server
    service: cicd
  type: ClusterIP

---

apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: drone-server
  labels:
    app: drone-server
    service: cicd
spec:
  serviceName: drone-server
  replicas: 1
  template:
    metadata:
      labels:
        app: drone-server
        service: cicd
    spec:
      containers:
      - name: drone-server
        image: drone/drone:0.8
        ports:
        - name: http
          containerPort: 8000
        - name: drone
          containerPort: 9000
        securityContext:
          capabilities: {}
          privileged: true
        env:
        - name: DRONE_HOST
          valueFrom:
            configMapKeyRef:
              name: drone
              key: drone_host
        - name: DOCKER_API_VERSION
          valueFrom:
            configMapKeyRef:
              name: drone
              key: docker_api_version
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
        - name: DRONE_GOGS_URL
          valueFrom:
            configMapKeyRef:
              name: drone
              key: gogs_url
        - name: DRONE_OPEN
          valueFrom:
            configMapKeyRef:
              name: drone
              key: drone_open
        - name: DRONE_DATABASE_DRIVER
          valueFrom:
            configMapKeyRef:
              name: drone
              key: drone_db_driver
        - name: DRONE_DATABASE_DATASOURCE
          valueFrom:
            configMapKeyRef:
              name: drone
              key: drone_db_datasource
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
        - name: DRONE_AGENT_SECRET
          valueFrom:
            secretKeyRef:
              name: drone
              key: drone_agent_secret
        volumeMounts:
        - name: drone-data
          mountPath: /var/lib/drone
      restartPolicy: Always
  volumeClaimTemplates:
  - metadata:
      name: drone-data
    spec:
      # storageClassName: rook-block
      storageClassName: longhorn
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
EOL