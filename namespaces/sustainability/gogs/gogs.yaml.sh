#!/bin/bash

cat <<EOL
apiVersion: v1
kind: Service
metadata:
  name: gogs
  labels:
    app: gogs
    service: vcs
  annotations:
    'prometheus.io/scrape': 'true'
spec:
  ports:
  - name: ssh
    protocol: TCP
    port: 22
    targetPort: 22
  - name: http
    protocol: TCP
    port: 3000
    targetPort: 3000
  selector:
    app: gogs
    service: vcs
  type: ClusterIP

---

apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: gogs
  labels:
    app: gogs
    service: vcs
spec:
  serviceName: gogs
  replicas: 1
  template:
    metadata:
      labels:
        app: gogs
        service: vcs
    spec:
      securityContext:
        fsGroup: 1000
      containers:
      - name: gogs
        image: gogs/gogs
        command: []
        ports:
        - name: ssh
          containerPort: 22
        - name: http
          containerPort: 3000
        livenessProbe:
          tcpSocket:
            port: 3000
          initialDelaySeconds: 1
          timeoutSeconds: 5
        readinessProbe:
          tcpSocket:
            port: 3000
          initialDelaySeconds: 1
          timeoutSeconds: 5
        resources:
          requests:
            cpu: "0.01"
        volumeMounts:
        - name: gogs-data
          mountPath: /data
        - name: gogs-config
          mountPath: /data/gogs/conf
      restartPolicy: Always
      volumes:
      - name: gogs-config
        configMap:
          name: gogs-config
  volumeClaimTemplates:
  - metadata:
      name: gogs-data
    spec:
      storageClassName: longhorn
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 5Gi
EOL