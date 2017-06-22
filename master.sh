#!/bin/bash

USERNAME=$1
PASSWORD=$2

yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion docker httpd-tools

mkdir -p /etc/origin/master
htpasswd -cb /etc/origin/master/htpasswd.dist ${USERNAME} ${PASSWORD}

sed -i -e "s#^OPTIONS='--selinux-enabled'#OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0/16'#" /etc/sysconfig/docker
                                                                                         
cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdc
VG=docker-vg
EOF

docker-storage-setup  
systemctl enable docker-cleanup
systemctl enable docker