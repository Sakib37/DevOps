#!/bin/bash

set -xe

# source the ubuntu global env file to make kubernetes-platform variables available to this session
source /etc/environment


# if encryption key already exists, do nothing
if [ -f /vagrant/conf/data-encryption-config.yaml ]
then
    echo "API Server data encryption config generation already exists. Skipping..."
else
    ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

    cat > /vagrant/conf/data-encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

echo "Kubernetes Api Server data encryption key created successfully"

fi


exit 0
