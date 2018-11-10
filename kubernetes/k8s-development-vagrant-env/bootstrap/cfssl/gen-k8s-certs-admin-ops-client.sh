#!/bin/bash

set -xe


export CFSSL_TLS_GUEST_FOLDER=${1}
export HOSTNAME=$(hostname)
export IP_ADDRESSES=$(hostname -i)
export CERT_NAME=admin

# source the ubuntu global env file to make cfssl variables available to this session
source /etc/environment

if [ -f ${CFSSL_TLS_GUEST_FOLDER}/kubernetes/${CERT_NAME}-csr.json ] && [ -f ${CFSSL_TLS_GUEST_FOLDER}/kubernetes/${CERT_NAME}-key.pem ]
then

    echo "Skipping Admin client certificate generation - it already exists"

else

mkdir -p ${CFSSL_TLS_GUEST_FOLDER}/kubernetes


# generate admin operator certificate signing request

cat - > ${CFSSL_TLS_GUEST_FOLDER}/kubernetes/${CERT_NAME}-csr.json <<EOF
{
  "CN": "${CERT_NAME}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "DE",
      "L": "Berlin",
      "O": "system:masters",
      "OU": "Kubernetes Development Cluster",
      "ST": "Berlin"
    }
  ]
}
EOF


# generate signed client certificate for admin operator

cfssl gencert -ca=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem -ca-key=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-key.pem -config=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-config.json -profile=client-server ${CFSSL_TLS_GUEST_FOLDER}/kubernetes/${CERT_NAME}-csr.json | cfssljson -bare ${CFSSL_TLS_GUEST_FOLDER}/kubernetes/${CERT_NAME}


# verify generated client certificate
openssl x509 -noout -text -in ${CFSSL_TLS_GUEST_FOLDER}/kubernetes/${CERT_NAME}.pem

# verify certificate functionality for client and server authentication
echo "verifying with ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem for ssl client functionality"
openssl verify -purpose sslclient -CAfile ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem ${CFSSL_TLS_GUEST_FOLDER}/kubernetes/${CERT_NAME}.pem

#sudo chmod 644 ${CFSSL_TLS_GUEST_FOLDER}/kubernetes/admin-key.pem

echo "Kubernetes Admin Operator Client certificates successfully generated"

fi

exit 0
