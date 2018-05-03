#!/bin/bash

NAMESPACE=${NAMESPACE:-sustainability}
TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
DRONE_DOMAIN=${DRONE_DOMAIN:-drone.$TARGET_DOMAIN}

ADMIN_USER_BASE64=${ADMIN_USER_BASE64:-YWRtaW4K}
ADMIN_SECRET_BASE64=${ADMIN_SECRET_BASE64:-YWRtaW5wYXNzd2QK}
admin_user=$(eval "echo $ADMIN_USER_BASE64 | base64 -d")
admin_secret=$(eval "echo $ADMIN_SECRET_BASE64 | base64 -d")

cat <<EOL
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  db_name: drone
  root_pass: $admin_secret

---

apiVersion: v1
kind: Secret
metadata:
  name: drone
data:
  gogs_git_user: $ADMIN_USER_BASE64
  gogs_git_pass: $ADMIN_SECRET_BASE64
  drone_agent_secret: $ADMIN_SECRET_BASE64

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: drone
data:
  drone_host: https://$DRONE_DOMAIN
  docker_api_version: '1.23'
  gogs: 'true'
  gogs_private_mode: 'true'
  gogs_url: http://gogs.$NAMESPACE.svc.cluster.local:3000
  drone_open: 'true'
  drone_db_driver: mysql
  drone_db_datasource: root:$admin_secret@tcp(mysql.$NAMESPACE.svc.cluster.local:3306)/drone?parseTime=true
  gin_mode: release
  drone_server: drone-server.$NAMESPACE.svc.cluster.local:9000
  remote_driver: gogs
EOL