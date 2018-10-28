#!/bin/bash

set -xe

sudo -E -s -- <<EOF
cat > /etc/default/dex <<"EOL"
export DEX_VERSION=2.10.0
export DEX_HOME=/var/lib/dex
export DEX_USER=dex
export DEX_USER_ID=1700
export DEX_GROUP=dex
export DEX_GROUP_ID=1700
export DEX_DOWNLOAD_URL=https://github.com/coreos/dex/archive/v${DEX_VERSION}.tar.gz
EOL
EOF

# add a line which sources /etc/default/dex in the ubuntu global env /etc/environment file
grep -q -F '. /etc/default/dex' /etc/environment || echo '. /etc/default/dex' >> /etc/environment

# source the ubuntu global env file to make dex variables available to this session
source /etc/environment

sudo -E -s -- <<EOF

# create the dex users
groupadd -g ${DEX_GROUP_ID} ${DEX_GROUP} || echo group already exists
useradd -r -u ${DEX_USER_ID} -g ${DEX_GROUP_ID} -m -c "${DEX_USER} role account" \
-d ${DEX_HOME} -s /bin/bash ${DEX_USER} || echo ${DEX_USER} user already exists

usermod -aG root ${DEX_USER}
usermod -aG sudo ${DEX_USER}
usermod -aG vagrant ${DEX_USER}

# set the current PATH to include the go binaries in $GOROOT
export PATH=$PATH:$GOROOT/bin

# fetch the dex libraries
go get github.com/coreos/dex

# build dex
cd $GOPATH/src/github.com/coreos/dex
make

# copy dex to a system path
cp bin/dex /usr/local/bin/
chmod +x /usr/local/bin/dex

# create the dex home folder
mkdir -p ${DEX_HOME}

# copy web folder to the dex home folder
cp -R web ${DEX_HOME}

chown -R ${DEX_USER}:${DEX_GROUP} ${DEX_HOME}

EOF

echo "Dex successfully installed"

exit 0