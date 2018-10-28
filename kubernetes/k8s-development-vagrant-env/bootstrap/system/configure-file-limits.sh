#!/bin/bash

set -xe

cat > /tmp/ulimitsconf <<"EOL"
root soft nofile 65536
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536
EOL

sudo -E -s -- <<"EOF"

target_file=/etc/security/limits.conf
search_text=$(cat /tmp/ulimitsconf)
search_result=$(grep "${search_text}" ${target_file})

if [[ "${search_text}" != "${search_result}" ]]
then

echo "limits configuration not yet in ${target_file}"

cat >> /etc/security/limits.conf <<EOL
root soft nofile 65536
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536
EOL

echo "limits configuration successfully set in ${target_file}"

else

echo "limits configuration already set"

fi

EOF