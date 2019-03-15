#!/usr/bin/env bash

# Author: Mohammad Badruzzaman (https://github.com/sakib37)

echo "#################################################"
echo "   This script install Golang in a Linux amd64"
echo "#################################################"

# source the ubuntu global env file to make cfssl variables available to this session
source /etc/environment

# This scripts considers that $HOME/go will be the workspace for golang
mkdir -p /home/vagrant/go/{bin,src,pkg}

# Change the version number according to your requirement
GOLANG_VERSION=1.12.1
GOROOT=/usr/local/go
GOPATH=/home/vagrant/go
GOBIN=${GOPATH}/bin
GO_DOWNLOAD_URL=https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz
GO_BINARY_VM_LOCATION=/vagrant/temp_downloaded/go${GOLANG_VERSION}.linux-amd64.tar.gz

# Install gcc for compilation of glang
echo "Installing gcc ..."
sudo apt update; sudo apt install gcc -y > /dev/null 2>&1

# Download golang binary in /vagrant/temp_downloaded  directory
if ! [ -f ${GO_BINARY_VM_LOCATION} ]
then 
	wget -q ${GO_DOWNLOAD_URL} -O ${GO_BINARY_VM_LOCATION} &>/dev/null
fi

sudo tar -C /usr/local/ -xzf ${GO_BINARY_VM_LOCATION} &>/dev/null

if grep -Fxq "# Env for golang" /etc/environment
then
    echo "Golang environment is already set"
else
    echo -e "\n# Env for golang"  >> /etc/environment
    echo "export GOROOT=${GOROOT}" >> /etc/environment
    echo "export GOPATH=${GOPATH}" >> /etc/environment
    echo "export PATH=${PATH}:${GOROOT}/bin:${GOPATH}/bin" >>  /etc/environment
    echo "" >>  /etc/environment
fi

chown -R vagrant:vagrant ${GOPATH}

echo "Golang v${GOLANG_VERSION} downloaded successfully"

exit 0
