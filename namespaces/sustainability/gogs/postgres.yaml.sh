#!/bin/bash

cat <<EOL
apiVersion: v1
kind: Service
metadata:
  name: postgres
  labels:
    app: postgres
    service: database
  annotations:
    'prometheus.io/scrape': 'true'
spec:
  ports:
  - name: http
    protocol: TCP
    port: 5432
    targetPort: 5432
  selector:
    app: postgres
    service: database
  clusterIP: None

---

apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: postgres
  labels:
    app: postgres
    service: database
spec:
  serviceName: postgres
  replicas: 1
  template:
    metadata:
      labels:
        app: postgres
        service: database
    spec:
      containers:
      - name: postgres
        image: postgres
        ports:
        - name: postgres
          containerPort: 5432
        env:
        - name: PGDATA
          valueFrom:
            configMapKeyRef:
              name: postgres-config
              key: data_dir
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: postgres-config
              key: db_name
        - name: POSTGRES_USER
          valueFrom:
            configMapKeyRef:
              name: postgres-config
              key: db_user
        - name: POSTGRES_PASSWORD
          valueFrom:
            configMapKeyRef:
              name: postgres-config
              key: db_pass
        resources:
          requests:
            cpu: "0.01"
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
      restartPolicy: Always
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      storageClassName: longhorn
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
EOL