#!/bin/bash

cat <<EOL
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
    service: database
  annotations:
    'prometheus.io/scrape': 'true'
spec:
  ports:
  - name: mysql
    protocol: TCP
    port: 3306
    targetPort: 3306
  selector:
    app: mysql
    service: database
  clusterIP: None

---

apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: mysql
  labels:
    app: mysql
    service: database
spec:
  serviceName: mysql
  replicas: 1
  template:
    metadata:
      labels:
        app: mysql
        service: database
    spec:
      containers:
      - name: mysql
        image: mysql:5.6
        ports:
        - name: mysql
          containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            configMapKeyRef:
              name: mysql-config
              key: root_pass
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: mysql-config
              key: db_name
        resources:
          requests:
            cpu: "0.01"
        volumeMounts:
        - name: mysql-cicd-data
          mountPath: /var/lib/mysql
      restartPolicy: Always
  volumeClaimTemplates:
  - metadata:
      name: mysql-cicd-data
    spec:
      # storageClassName: rook-block
      storageClassName: longhorn
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
EOL