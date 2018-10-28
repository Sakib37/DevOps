#!/bin/bash

set -xe

export KUBECONFIG_FOLDER=${1}
export TLS_GUEST_FOLDER=${2}
export KUBERNETES_SERVER_PROXY_IP=${3}
export KUBERNETES_CLUSTER_NAME=${4}
export CLIENT_CERT=${TLS_GUEST_FOLDER}/kubernetes/admin
export CLIENT_CERT_KEY=${TLS_GUEST_FOLDER}/kubernetes/admin-key

# source the ubuntu global env file to make kubernetes variables available to this session
source /etc/environment

mkdir -p ${KUBECONFIG_FOLDER}

if [ -f ${KUBECONFIG_FOLDER}/admin.kubeconfig ]
then
    echo "Skipping admin kubernetes configuration file generation - it already exists"
else

# generate admin kubernetes configuration file

kubectl config set-cluster ${KUBERNETES_CLUSTER_NAME} \
    --certificate-authority=${TLS_GUEST_FOLDER}/ca/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_SERVER_PROXY_IP}:6443 \
    --kubeconfig=${KUBECONFIG_FOLDER}/admin.kubeconfig

kubectl config set-credentials admin \
    --client-certificate=${CLIENT_CERT}.pem \
    --client-key=${CLIENT_CERT_KEY}.pem \
    --embed-certs=true \
    --kubeconfig=${KUBECONFIG_FOLDER}/admin.kubeconfig

kubectl config set-context default \
    --cluster=${KUBERNETES_CLUSTER_NAME} \
    --user=admin \
    --kubeconfig=${KUBECONFIG_FOLDER}/admin.kubeconfig


kubectl config use-context default --kubeconfig=${KUBECONFIG_FOLDER}/admin.kubeconfig

echo "Admin Kubernetes Configuration File (kubeconfig) successfully created for ${HOSTNAME}"

fi


exit 0