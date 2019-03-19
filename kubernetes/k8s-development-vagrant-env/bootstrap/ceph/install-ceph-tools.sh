#!/bin/bash

set -xe


#source: http://docs.ceph.com/docs/mimic/install/get-packages/
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

#sudo apt-add-repository 'deb https://download.ceph.com/debian-nautilus/ $(lsb_release -sc) main' || true
echo deb https://download.ceph.com/debian-luminous/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list

sudo apt update || true
sudo apt install ceph-deploy -y || true