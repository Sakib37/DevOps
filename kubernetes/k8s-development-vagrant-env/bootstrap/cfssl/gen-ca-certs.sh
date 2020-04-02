#!/bin/bash

set -xe


export CFSSL_TLS_GUEST_FOLDER=${1}

# source the ubuntu global env file to make cfssl variables available to this session
source /etc/environment


# shellcheck disable=SC2086
if [ -f "${CFSSL_TLS_GUEST_FOLDER}"/ca/ca-config.json ] && [ -f ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-csr.json ]
then

    echo "Skipping CA certificate generation - it already exists"

else

mkdir -p "${CFSSL_TLS_GUEST_FOLDER}"/ca

# generate certificate signing request ca-csr.json

cat - > "${CFSSL_TLS_GUEST_FOLDER}"/ca/ca-csr.json <<'EOF'
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "ca": {
    "expiry": "262800h",
    "pathlen": 1
  },
  "names": [
    {
      "C": "DE",
      "L": "Berlin",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Berlin"
    }
  ]
}
EOF

# generate root ca-config.json

cat - > ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-config.json <<'EOF'
{
   "signing":{
      "default":{
         "usages":[
            "signing",
            "key encipherment",
            "cert sign",
            "crl sign"
         ],
         "expiry":"262800h",
         "ca_constraint":{
            "is_ca":true,
            "max_path_len":0,
            "max_path_len_zero":true
         }
      },
      "profiles": {
         "kubernetes": {
            "usages": ["signing", "key encipherment", "server auth", "client auth"],
            "expiry": "8760h"
         }
      }
   }
}
EOF


# generate root ca certificate
cfssl gencert -initca ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-csr.json | cfssljson -bare ${CFSSL_TLS_GUEST_FOLDER}/ca/ca

# verify root ca certificate
openssl x509 -noout -text -in ${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem

# create ca certificate chain by concatenating root certificate and any available intermediate certificate
cat ${CFSSL_TLS_GUEST_FOLDER}/ca/ca.pem > ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem

fi


# if the ca-chain.crt file is not already installed in the guest VM then create it

sudo -E -s <<EOL
if [ ! -f /usr/local/share/ca-certificates/ca-chain.crt ]
then
    cp ${CFSSL_TLS_GUEST_FOLDER}/ca/ca-chain.pem /usr/local/share/ca-certificates/ca-chain.crt
    update-ca-certificates
fi
EOL

chmod 400 "${CFSSL_TLS_GUEST_FOLDER}"/ca/*-key.pem


echo "CA Certificates successfully generated and installed on VM"

exit 0
