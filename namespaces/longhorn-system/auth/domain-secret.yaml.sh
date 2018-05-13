#!/bin/bash

CLIENT_ID=${CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
CLIENT_SECRET=${CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
COOKIE_SECRET=${COOKIE_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXX}

base64_client_id=$(eval "echo -n \"${CLIENT_ID}\"" | base64)
base64_client_id=`echo ${base64_client_id} | sed -e "s/ //g"`
base64_client_secret=$(eval "echo -n \"${CLIENT_SECRET}\"" | base64)
base64_client_secret=`echo ${base64_client_secret} | sed -e "s/ //g"`
base64_cookie_secret=$(eval "echo -n \"${COOKIE_SECRET}\"" | base64)
base64_cookie_secret=`echo ${base64_cookie_secret} | sed -e "s/ //g"`

cat <<EOL
apiVersion: v1
kind: Secret
metadata:
  name: domain-secret
data:
  clientID: $base64_client_id
  clientSecret: $base64_client_secret
  cookieSecret: $base64_cookie_secret
EOL