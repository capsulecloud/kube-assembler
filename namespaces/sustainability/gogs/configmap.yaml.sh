#!/bin/bash

NAMESPACE=${NAMESPACE:-sustainability}
TARGET_DOMAIN=${TARGET_DOMAIN:-example.com}
GOGS_DOMAIN=${GOGS_DOMAIN:-gogs.$TARGET_DOMAIN}
user=$(eval "kubectl -n ${NAMESPACE} get secret webmaster -o jsonpath='{.data.user}' | base64 -d")
secret=$(eval "kubectl -n ${NAMESPACE} get secret webmaster -o jsonpath='{.data.password}' | base64 -d")

cat <<EOL
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
data:
  db_name: gogs
  db_user: $user
  db_pass: $secret
  data_dir: /var/lib/postgresql/data/pgdata

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: gogs-config
data:
  app.ini: |
    APP_NAME = Gogs
    RUN_USER = git
    RUN_MODE = prod

    [database]
    DB_TYPE  = postgres
    HOST     = postgres.$NAMESPACE.svc.cluster.local:5432
    NAME     = gogs
    USER     = $user
    PASSWD   = $secret
    SSL_MODE = disable
    PATH     = data/gogs.db

    [repository]
    ROOT = /data/git/gogs-repositories
    FORCE_PRIVATE = true

    [server]
    DOMAIN           = $GOGS_DOMAIN
    HTTP_PORT        = 3000
    ROOT_URL         = https://$GOGS_DOMAIN/
    DISABLE_SSH      = true
    SSH_PORT         = 22
    START_SSH_SERVER = false
    OFFLINE_MODE     = false

    [mailer]
    ENABLED = false

    [service]
    REGISTER_EMAIL_CONFIRM = false
    ENABLE_NOTIFY_MAIL     = false
    DISABLE_REGISTRATION   = true
    ENABLE_CAPTCHA         = true
    REQUIRE_SIGNIN_VIEW    = true

    [picture]
    DISABLE_GRAVATAR        = false
    ENABLE_FEDERATED_AVATAR = false

    [session]
    PROVIDER = file

    [log]
    MODE      = file
    LEVEL     = Info
    ROOT_PATH = /app/gogs/log

    [security]      
    INSTALL_LOCK = true      
    SECRET_KEY   = $secret
EOL