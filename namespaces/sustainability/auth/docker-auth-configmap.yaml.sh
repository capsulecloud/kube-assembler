#!/bin/bash

GITHUB_ORG=${GITHUB_ORG:-example-org}
REGISTRY_CLIENT_ID=${REGISTRY_CLIENT_ID:-XXXXXXXXXXXXXXXXXXX}
REGISTRY_CLIENT_SECRET=${REGISTRY_CLIENT_SECRET:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

cat <<EOL
apiVersion: v1
kind: ConfigMap
metadata:
  name: docker-auth
data:
  AuthConfig: |
    server:
      addr: ":5001"

    token:
      issuer: "Auth Service"  # Must match issuer in the Registry config.
      expiration: 900
      certificate: "/certs/tls.crt"
      key: "/certs/tls.key"

    acl:
      - match: {account: "/.+/", name: "\${account}/*"}
        actions: ["*"]
        comment: "Logged in users have full access to images that are in their 'namespace'"
      - match: {account: "/.+/", type: "registry", name: "catalog"}
        actions: ["*"]
        comment: "Logged in users can query the catalog."
      - match: {account: "/.+/"}
        actions: ["pull"]
        comment: "Logged in users can pull all images."
    
    github_auth:
      organization: "$GITHUB_ORG"   # Optional. If set, only logins from this organization are accepted.
      client_id: "$REGISTRY_CLIENT_ID"
      client_secret: "$REGISTRY_CLIENT_SECRET"
      token_db: "/tmp/github_tokens.ldb"
EOL