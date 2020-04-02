#!/bin/bash

set -xe


export CFSSL_TLS_GUEST_FOLDER=${1}
export HOSTNAME=$(hostname)
export IP_ADDRESSES=$(hostname -i)

# source the ubuntu global env file to make cfssl variables available to this session
source /etc/environment


mkdir -p ${CFSSL_TLS_GUEST_FOLDER}/etcd

HOSTNAME=$(hostname)

separator=
formatted_ip_addresses=

for one in $IP_ADDRESSES
do
    formatted_ip_addresses=$formatted_ip_addresses$separator\"$one\"
    separator=", "
done


# generate Etcd certificate signing request config for this VM

cat - > "${CFSSL_TLS_GUEST_FOLDER}"/etcd/"${HOSTNAME}"-csr.json <<EOF
{
  "CN": "${HOSTNAME}",
  "hosts": [
    ${formatted_ip_addresses},
    "127.0.0.1",
    "10.0.2.15",
    "localhost",
    "${HOSTNAME}"
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

# generate signed server certificate for etcd vm using the above csr

cfssl gencert -ca="${CFSSL_TLS_GUEST_FOLDER}"/ca/ca.pem \
    -ca-key=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-key.pem  \
    -config=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-config.json  \
    -profile=kubernetes \
    ${CFSSL_TLS_GUEST_FOLDER}/etcd/${HOSTNAME}-csr.json | cfssljson -bare "${CFSSL_TLS_GUEST_FOLDER}"/etcd/${HOSTNAME}-client

cfssl gencert -ca=${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem \
    -ca-key=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-key.pem \
    -config=${CFSSL_TLS_GUEST_FOLDER}/ca/ca-config.json \
    -profile=kubernetes \
    ${CFSSL_TLS_GUEST_FOLDER}/etcd/${HOSTNAME}-csr.json | cfssljson -bare ${CFSSL_TLS_GUEST_FOLDER}/etcd/${HOSTNAME}-peer

# verify generated server certificates
openssl x509 -noout -text -in ${CFSSL_TLS_GUEST_FOLDER}/etcd/${HOSTNAME}-client.pem
openssl x509 -noout -text -in ${CFSSL_TLS_GUEST_FOLDER}/etcd/${HOSTNAME}-peer.pem

# verify certificate functionality for client and server authentication
echo "verifying with ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem for ssl client functionality"
openssl verify -purpose sslclient -CAfile ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem ${CFSSL_TLS_GUEST_FOLDER}/etcd/${HOSTNAME}-client.pem

echo "verifying with ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem for tls server functionality"
openssl verify -purpose sslserver -CAfile ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem ${CFSSL_TLS_GUEST_FOLDER}/etcd/${HOSTNAME}-peer.pem


#sudo chmod 644 ${CFSSL_TLS_GUEST_FOLDER}/etcd/$(hostname)-client-key.pem
#sudo chmod 644 ${CFSSL_TLS_GUEST_FOLDER}/etcd/$(hostname)-peer-key.pem

echo "Etcd Certificates successfully generated"

exit 0
