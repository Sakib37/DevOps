#!/bin/bash

set -xe


export CFSSL_TLS_GUEST_FOLDER=${1}
export GATEWAY_IP=${2}
export GATEWAY_HOSTNAME=${3}
export HOSTNAME=$(hostname)
export IP_ADDRESSES=$(hostname -i)
export CERT_NAME=dex-grpc

# source the ubuntu global env file to make cfssl variables available to this session
source /etc/environment

mkdir -p ${CFSSL_TLS_GUEST_FOLDER}/auth

separator=
formatted_ip_addresses=

for one in $IP_ADDRESSES
do
    formatted_ip_addresses=$formatted_ip_addresses$separator\"$one\"
    separator=", "
done


# generate dex server certificate signing request for this vm

cat - > ${CFSSL_TLS_GUEST_FOLDER}/auth/${CERT_NAME}-csr.json <<EOF
{
  "CN": "${HOSTNAME}",
  "hosts": [
    ${formatted_ip_addresses},
    "localhost",
    "${HOSTNAME}",
    "${GATEWAY_IP}",
    "${GATEWAY_HOSTNAME}"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "DE",
      "L": "Berlin",
      "O": "dex",
      "OU": "Kubernetes Development Cluster",
      "ST": "Berlin"
    }
  ]
}
EOF

# generate signed openldap server certificates for the vm

cfssl gencert -ca=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem -ca-key=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-key.pem -config=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-config.json -profile=client-server ${CFSSL_TLS_GUEST_FOLDER}/auth/${CERT_NAME}-csr.json | cfssljson -bare ${CFSSL_TLS_GUEST_FOLDER}/auth/${CERT_NAME}


# verify generated client certificate
openssl x509 -noout -text -in ${CFSSL_TLS_GUEST_FOLDER}/auth/${CERT_NAME}.pem

# verify certificate functionality for client authentication
echo "verifying with ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem for ssl client functionality"
openssl verify -purpose sslclient -CAfile ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem ${CFSSL_TLS_GUEST_FOLDER}/auth/${CERT_NAME}.pem

# change mode of the tls certificates to allow dex and other custom users to access them
chmod g+r ${CFSSL_TLS_GUEST_FOLDER}/auth/*-key.pem

echo "Dex grpc Certificates successfully generated"

exit 0