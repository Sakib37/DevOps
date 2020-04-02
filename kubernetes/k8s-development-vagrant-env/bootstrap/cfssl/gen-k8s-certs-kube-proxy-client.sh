#!/bin/bash

set -xe


export CFSSL_TLS_GUEST_FOLDER=${1}
export GATEWAY_IP=${2}
export GATEWAY_HOSTNAME=${3}
export HOSTNAME=$(hostname)
export IP_ADDRESSES=$(hostname -i)
export CERT_NAME=${HOSTNAME}-kube-proxy

# source the ubuntu global env file to make cfssl variables available to this session
source /etc/environment

mkdir -p ${CFSSL_TLS_GUEST_FOLDER}/kube-proxy

separator=
formatted_ip_addresses=

for one in $IP_ADDRESSES
do
    formatted_ip_addresses=$formatted_ip_addresses$separator\"$one\"
    separator=", "
done


# generate kube-proxy client certificate signing request for this vm

cat - > ${CFSSL_TLS_GUEST_FOLDER}/kube-proxy/${CERT_NAME}-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "hosts": [
      ${formatted_ip_addresses},
      "127.0.0.1",
      "10.0.2.15",
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
      "O": "system:node-proxier",
      "OU": "Kubernetes Development Cluster",
      "ST": "Berlin"
    }
  ]
}
EOF

# generate signed kube-proxy client certificates for the vm

cfssl gencert -ca=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem \
    -ca-key=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-key.pem \
    -config=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-config.json \
    -profile=kubernetes \
    ${CFSSL_TLS_GUEST_FOLDER}/kube-proxy/${CERT_NAME}-csr.json | cfssljson -bare ${CFSSL_TLS_GUEST_FOLDER}/kube-proxy/${CERT_NAME}


# verify generated client certificate
openssl x509 -noout -text -in ${CFSSL_TLS_GUEST_FOLDER}/kube-proxy/${CERT_NAME}.pem

# verify certificate functionality for client authentication
echo "verifying with ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem for ssl client functionality"
openssl verify -purpose sslclient -CAfile ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem ${CFSSL_TLS_GUEST_FOLDER}/kube-proxy/${CERT_NAME}.pem

#sudo chmod 644 ${CFSSL_TLS_GUEST_FOLDER}/kube-proxy/$(hostname)-kube-proxy-key.pem

echo "Kube Proxy Client Certificates successfully generated"

exit 0