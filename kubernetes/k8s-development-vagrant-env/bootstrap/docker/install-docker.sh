#!/bin/bash

set -xe


DOCKER_ENGINE_VERSION=19.03.6
DOCKER_BINARY_VM_LOCATION=/vagrant/temp_downloaded/docker-${DOCKER_ENGINE_VERSION}.tgz
DOCKER_BINARY_DOWNLOAD_URL=https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_ENGINE_VERSION}.tgz
DOCKER_USER=vagrant

cat > /etc/default/docker-engine.conf <<"EOL"
DOCKER_ENGINE_VERSION=19.03.6
DOCKER_OPTS=
EOL

# add a line which sources /etc/default/docker-engine.conf in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/docker-engine.conf' /etc/environment || echo '. /etc/default/docker-engine.conf' >> /etc/environment

# source the ubuntu global env file to make docker-engine variables available to this session
source /etc/environment


# Install the docker engine

sudo -E -s -- <<EOF

# install dependencies
#add-apt-repository -y ppa:alexlarsson/flatpak
#apt-get update -qq --yes
#apt-get install -qq --yes socat libgpgme11 libostree-1-1 conntrack ipset udev swapspace

if ! [ -f ${DOCKER_BINARY_VM_LOCATION} ]
then
    echo "Downloading Docker ${DOCKER_ENGINE_VERSION} ..."
    wget -q ${DOCKER_BINARY_DOWNLOAD_URL} -O ${DOCKER_BINARY_VM_LOCATION} &>/dev/null
fi

tar xzf ${DOCKER_BINARY_VM_LOCATION} --strip-components=1 -C /usr/local/bin/ &>/dev/null

cat > /etc/systemd/system/docker.service <<"EOL"
[Unit]
Description=Docker Container Runtime Engine
Documentation=http://docs.docker.io

[Service]
EnvironmentFile=/etc/default/docker-engine.conf
ExecStart=/usr/local/bin/dockerd \
  --iptables=false \
  --ip-masq=false \
  --host=unix:///var/run/docker.sock \
  --host=unix:///var/run/dockershim.sock \
  --log-level=error \
  --storage-driver=overlay ${DOCKER_OPTS}
Restart=always
RestartSec=10s
LimitNOFILE=40000
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL



systemctl daemon-reload && systemctl enable docker.service && systemctl restart docker.service

EOF

sudo groupadd docker
sudo usermod -aG docker ${DOCKER_USER}
sudo usermod -aG docker ${KUBERNETES_PLATFORM_USER}
# Make user entry to group 'docker' effective without restart
sudo bash -c "/usr/bin/newgrp docker"


# Bash completion for docker
sudo curl -L https://raw.githubusercontent.com/docker/compose/1.22.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose


echo "Docker Engine v${DOCKER_ENGINE_VERSION} downloaded successfully"