#!/bin/bash

set -xe

export KUBECONFIG_FOLDER=${1}
export TLS_GUEST_FOLDER=${2}
export KUBERNETES_SERVER_PROXY_IP=${3}
export KUBERNETES_CLUSTER_NAME=${4}
export HOSTNAME=$(hostname)
export CLIENT_CERT=${TLS_GUEST_FOLDER}/kube-proxy/${HOSTNAME}-kube-proxy.pem
export CLIENT_CERT_KEY=${TLS_GUEST_FOLDER}/kube-proxy/${HOSTNAME}-kube-proxy-key.pem

# source the ubuntu global env file to make kubernetes variables available to this session
source /etc/environment

mkdir -p ${KUBECONFIG_FOLDER}/${HOSTNAME}


# generate kube-proxy kubernetes configuration file


kubectl config set-cluster ${KUBERNETES_CLUSTER_NAME} \
    --certificate-authority=${TLS_GUEST_FOLDER}/ca/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_SERVER_PROXY_IP}:6443 \
    --kubeconfig=${KUBECONFIG_FOLDER}/${HOSTNAME}/${HOSTNAME}-kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
    --client-certificate=${CLIENT_CERT} \
    --client-key=${CLIENT_CERT_KEY} \
    --embed-certs=true \
    --kubeconfig=${KUBECONFIG_FOLDER}/${HOSTNAME}/${HOSTNAME}-kube-proxy.kubeconfig

kubectl config set-context default \
    --cluster=${KUBERNETES_CLUSTER_NAME} \
    --user=system:kube-proxy \
    --kubeconfig=${KUBECONFIG_FOLDER}/${HOSTNAME}/${HOSTNAME}-kube-proxy.kubeconfig


kubectl config use-context default --kubeconfig=${KUBECONFIG_FOLDER}/${HOSTNAME}/${HOSTNAME}-kube-proxy.kubeconfig

usermod -aG vagrant kubernetes
chmod g+r ${KUBECONFIG_FOLDER}/${HOSTNAME}/${HOSTNAME}-kube-proxy.kubeconfig

echo "Kube-Proxy Kubernetes Configuration File (kubeconfig) successfully created for ${HOSTNAME}"

exit 0