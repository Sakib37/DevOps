#!/bin/bash

set -xe

source /etc/environment

sudo -E -s <<"EOF"

# create dex config file
cat > /var/lib/dex/config.yaml <<"EOL"
# The base path of dex and the external name of the OpenID Connect service.
# This is the canonical URL that all clients MUST use to refer to dex. If a
# path is provided, dex's HTTP service will listen at a non-root URL.
issuer: https://k8s-auth-1:5556

# The storage configuration determines where dex stores its state. Supported
# options include SQL flavors and Kubernetes third party resources.
#
# See the storage document at Documentation/storage.md for further information.
storage:
  type: sqlite3
  config:
    file: /var/lib/dex/dex.db

# Configuration for the HTTP endpoints.
web:
  http: 0.0.0.0:5556
  https: 0.0.0.0:5554
  tlsCert: ${CFSSL_TLS_GUEST_FOLDER}/auth/dex-web.pem
  tlsKey: ${CFSSL_TLS_GUEST_FOLDER}/auth/dex-web-key.pem

# Configuration for telemetry
telemetry:
  http: 0.0.0.0:5558

# Configuration for the gRPC API
grpc:
  addr: 0.0.0.0:5557
  tlsCert: ${CFSSL_TLS_GUEST_FOLDER}/auth/dex-grpc.pem
  tlsKey: ${CFSSL_TLS_GUEST_FOLDER}/auth/dex-grpc-key.pem
  tlsClientCA: ${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem


# Configuration for the UI
frontend:
  dir: /var/lib/dex/web
  theme: "coreos"
  issuer: "PCIT Kubernetes Production"
  issuerUrl: "https://k8s-auth-1:5556"
  logoUrl: https://example.com/images/logo-250x25.png

expiry:
  signingKeys: "6h"
  idTokens: "24h"

logger:
  level: debug
  format: text

oauth2:
  responseTypes: ["code", "token", "id_token"]
  skipApprovalScreen: true

# Remember you can have multiple connectors of the same 'type' (with different 'id's)
# If you need e.g. logins with groups for two different Microsoft 'tenants'
connectors:
# GitHub configure 'OAuth Apps' -> 'New OAuth App', add callback URL
# https://github.com/settings/developers
- type: github
  id: github
  name: GitHub
  config:
    clientID: $GITHUB_CLIENT_ID
    clientSecret: $GITHUB_CLIENT_SECRET
    redirectURI: https://dex.example.com/callback
    # 'orgs' can be used to map groups from Github
    # https://github.com/coreos/dex/blob/master/Documentation/connectors/github.md
    #orgs:
    #- name: foo
    #  teams:
    #  - team-red
    #  - team-blue
    #- name: bar
# Google APIs account, 'Create Credentials' -> 'OAuth Client ID', add callback URL
# https://console.developers.google.com/apis/credentials
- type: oidc
  id: google
  name: Google
  config:
    issuer: https://accounts.google.com
    clientID: $GOOGLE_CLIENT_ID
    clientSecret: $GOOGLE_CLIENT_SECRET
    redirectURI: https://dex.example.com/callback
    # Google supports whitelisting allowed domains when using G Suite
    # (Google Apps). The following field can be set to a list of domains
    # that can log in:
    # hostedDomains:
    #  - example.com
    #  - other.example.com
# Microsoft App Dev account, 'Add an app'
# 'Application Secrets' -> 'Generate new password'
# 'Platforms' -> 'Add Platform' -> 'Web', add the callback URL
# https://apps.dev.microsoft.com/
- type: microsoft
  id: microsoft
  name: Microsoft
  config:
    clientID: $MICROSOFT_APPLICATION_ID
    clientSecret: $MICROSOFT_CLIENT_SECRET
    redirectURI: https://dex.example.com/callback
    # Restrict access to one tenant
    # tenant: <tenant name> or <tenant uuid>
    # Restrict access to certain groups
    # groups:
    # - group-red
    # - group-blue
# These may not match the schema used by your LDAP server
# https://github.com/coreos/dex/blob/master/Documentation/connectors/ldap.md
- type: ldap
  id: ldap
  name: "LDAP"
  config:
    host: k8s-auth-1:389

    # Following field is required if the LDAP host is not using TLS (port 389).
    # Because this option inherently leaks passwords to anyone on the same network
    # as dex, THIS OPTION MAY BE REMOVED WITHOUT WARNING IN A FUTURE RELEASE.
    #
    insecureNoSSL: false

    # If a custom certificate isn't provide, this option can be used to turn on
    # TLS certificate checks. As noted, it is insecure and shouldn't be used outside
    # of explorative phases.
    #
    insecureSkipVerify: false

    # When connecting to the server, connect using the ldap:// protocol then issue
    # a StartTLS command. If unspecified, connections will use the ldaps:// protocol
    #
    startTLS: true

    # Path to a trusted root certificate file. Default: use the host's root CA.
    #
    rootCA: ${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem

    # The DN and password for an application service account. The connector uses
    # these credentials to search for users and groups. Not required if the LDAP
    # server provides access for anonymous auth.
    # Please note that if the bind password contains a `$`, it has to be saved in an
    # environment variable which should be given as the value to `bindPW`.
    #
    bindDN: cn=admin,dc=example,dc=org
    bindPW: admin

    # The attribute to display in the provided password prompt. If unset, will
    # display "Username"
    usernamePrompt: SSO Username

    userSearch:
      baseDN: ou=People,dc=example,dc=org
      filter: "(objectClass=person)"
      username: mail
      # "DN" (case sensitive) is a special attribute name. It indicates that
      # this value should be taken from the entity's DN not an attribute on
      # the entity.
      idAttr: DN
      emailAttr: mail
      nameAttr: cn

    groupSearch:
      baseDN: ou=Groups,dc=example,dc=org
      filter: "(objectClass=groupOfNames)"

      # A user is a member of a group when their DN matches
      # the value of a "member" attribute on the group entity.
      userAttr: DN
      groupAttr: member

      # The group name should be the "cn" value.
      nameAttr: cn

# The 'name' must match the k8s API server's 'oidc-client-id'
staticClients:
- id: pcit-k8s-vagrant
  name: "pcit-k8s-vagrant"
  secret: "pUBnBOY80SnXgjibTYM9ZWNzY2xreNGQok"
  redirectURIs:
  - https://k8s-auth-1:5555/callback/pcit-k8s-vagrant

# Let dex keep a list of passwords which can be used to login to dex.
enablePasswordDB: True

# A static list of passwords to login the end user. By identifying here, dex
# won't look in its underlying storage for passwords.
#
# If this option isn't chosen users may be added through the gRPC API.
staticPasswords:
- email: "admin@kubernetes.vagrant.compute.k8s.pcit.takeawaydata.io"
  # bcrypt hash of the string "password"
  hash: "$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"
  username: "admin"
  userID: "08a8684b-db88-4b73-90a9-3cd1661f5466"

EOL

# create dex systemd config file
cat > /etc/default/dex.conf << EOL
DEX_CONFIG_FILE=/var/lib/dex/config.yaml
DEX_USER=dex
DEX_GROUP=dex
GOMAXPROCS=$(nproc)
EOL

# add a line which sources /etc/default/dex.conf in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/dex.conf' /etc/environment || echo '. /etc/default/dex.conf' >> /etc/environment

# source the ubuntu global env file to make dex variables available to this session
source /etc/environment

chown ${DEX_USER}:${DEX_GROUP} /etc/default/dex.conf

cat > /etc/systemd/system/dex.service <<"EOL"
[Unit]
Description=Dex
Documentation=https://github.com/coreos/dex

[Service]
User=dex
EnvironmentFile=/etc/default/dex.conf
ExecStart=/usr/local/bin/dex \
    serve ${DEX_CONFIG_FILE}


Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL

#systemctl daemon-reload && systemctl enable dex.service && systemctl start dex.service

EOF

echo "Dex Server v${DEX_VERSION} configured successfully"

exit 0
