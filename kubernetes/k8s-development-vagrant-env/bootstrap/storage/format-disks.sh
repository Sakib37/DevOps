#!/bin/bash

sudo bash -E -s <<"EOL"

apt update -qq --yes
apt install -qq kpartx nfs-common --yes

for one in sdc sdd
do
    mkfs.ext4 /dev/${one}
    #mkdir -p /rook-${one}
    #mount /dev/${one} /rook-${one}
    # add a to /etc/fstab
    #FSTAB_MOUNT="/dev/${one} /rook-${one} ext4 defaults 0 0"
    #grep -q -F "${FSTAB_MOUNT}" /etc/fstab || echo "${FSTAB_MOUNT}" >> /etc/fstab
    #kpartx -aufvs /dev/${one}
done
EOL