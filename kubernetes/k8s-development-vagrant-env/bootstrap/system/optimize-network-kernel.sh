#!/bin/bash

set -xe

sudo -E -s -- <<"EOF"

sysctl -w "net.ipv4.tcp_tw_recycle=1"
sysctl -w "net.ipv4.tcp_tw_reuse=1"
sysctl -w "net.ipv4.ip_local_port_range=10240   65535"
sysctl -w "net.core.somaxconn=65535"

echo never > /sys/kernel/mm/transparent_hugepage/enabled

EOF