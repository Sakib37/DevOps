#!/bin/bash

set -xe


export CFSSL_TLS_GUEST_FOLDER=${1}
export GATEWAY_IP=${2}
export GATEWAY_HOSTNAME=${3}
export HOSTNAME=$(hostname)
export IP_ADDRESSES=$(hostname -i)
export CERT_NAME=${HOSTNAME}-apiserver

# source the ubuntu global env file to make cfssl variables available to this session
source /etc/environment


mkdir -p ${CFSSL_TLS_GUEST_FOLDER}/kube-api

HOSTNAME=$(hostname)

separator=
formatted_ip_addresses=

for one in $IP_ADDRESSES
do
    formatted_ip_addresses=$formatted_ip_addresses$separator\"$one\"
    separator=", "
done


# generate Kubernetes server certificate signing request for this vm

cat - > ${CFSSL_TLS_GUEST_FOLDER}/kube-api/${CERT_NAME}-csr.json <<EOF
{
  "CN": "${CERT_NAME}",
  "hosts": [
    ${formatted_ip_addresses},
    "127.0.0.1",
    "localhost",
    "${HOSTNAME}",
    "kubernetes.local",
    "kubernetes.default",
    "${GATEWAY_IP}",
    "${GATEWAY_HOSTNAME}",
    "10.77.0.1",
    "10.0.2.2",
    "10.0.2.15"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "DE",
      "L": "Berlin",
      "O": "Kubernetes",
      "OU": "Kubernetes Development Cluster",
      "ST": "Berlin"
    }
  ]
}
EOF

# generate signed server certificate for kubernetes vm using the csr from above

cfssl gencert -ca=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem -ca-key=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-key.pem -config=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-config.json -profile=client-server ${CFSSL_TLS_GUEST_FOLDER}/kube-api/${CERT_NAME}-csr.json | cfssljson -bare ${CFSSL_TLS_GUEST_FOLDER}/kube-api/${CERT_NAME}


# verify generated server certificate
openssl x509 -noout -text -in ${CFSSL_TLS_GUEST_FOLDER}/kube-api/${CERT_NAME}.pem

# verify certificate functionality for client and server authentication
echo "verifying with ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem for ssl client functionality"
openssl verify -purpose sslclient -CAfile ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem ${CFSSL_TLS_GUEST_FOLDER}/kube-api/${CERT_NAME}.pem

echo "verifying with ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem for tls server functionality"
openssl verify -purpose sslserver -CAfile ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem ${CFSSL_TLS_GUEST_FOLDER}/kube-api/${CERT_NAME}.pem

#sudo chmod 644 ${CFSSL_TLS_GUEST_FOLDER}/kube-api/$(hostname)-apiserver-key.pem

echo "Kubernetes Server Certificates successfully generated"

exit 0