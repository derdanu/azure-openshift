#!/bin/bash

USERNAME=$1
HOSTNAME=$2 #fqdn of masters (web console address)
NODECOUNT=$3
ROUTEREXTIP=$4 #ip address of infranodes (must to be public ip address if access from internet needed)
MASTERCOUNT=$5
INFRACOUNT=$6

#yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion httpd-tools
yum -y install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel install ansible pyOpenSSL

# Workaround for Ansible 2.2.1.0 Bug
yum -y erase ansible
yum install -y "@Development Tools" openssl-devel python-devel
yum -y --enablerepo=epel install python2-pip
pip install -Iv ansible==2.2.0.0
mkdir /etc/ansible
###

git clone https://github.com/openshift/openshift-ansible /opt/openshift-ansible
yum -y install docker
sed -i -e "s#^OPTIONS='--selinux-enabled'#OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0/16'#" /etc/sysconfig/docker

cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdc
VG=docker-vg
EOF

docker-storage-setup
systemctl enable docker-cleanup
systemctl enable docker

cat <<EOF > /etc/ansible/hosts
[OSEv3:children]
masters
nodes

[OSEv3:vars]
ansible_ssh_user=${USERNAME}
ansible_become=yes
debug_level=2
deployment_type=origin
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]

openshift_master_cluster_method=native
openshift_master_cluster_hostname=${HOSTNAME}
openshift_master_cluster_public_hostname=${HOSTNAME}

openshift_master_default_subdomain=${ROUTEREXTIP}.xip.io
openshift_use_dnsmasq=False

openshift_disable_check=disk_availability,memory_availability

[masters]
master[1:${MASTERCOUNT}] openshift_public_hostname=${HOSTNAME}

[etcd]
master[1:${MASTERCOUNT}]

[nodes]
master[1:${MASTERCOUNT}]
node[01:${NODECOUNT}] openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
infranode[1:${INFRACOUNT}] openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
EOF

cat <<EOF > /home/${USERNAME}/openshift-install.sh
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook playbook.yml 
ansible-playbook /opt/openshift-ansible/playbooks/byo/config.yml
for i in $(seq -s " " 1 ${MASTERCOUNT}); do ssh -q -t -o StrictHostKeyChecking=no master\$i sudo cp /etc/origin/master/htpasswd.dist /etc/origin/master/htpasswd; done;
EOF

cat <<EOF > /home/${USERNAME}/playbook.yml
- hosts: all
  tasks:
    - service: name=docker state=started
      become: yes
      become_method: sudo
EOF

chmod 755 /home/${USERNAME}/openshift-install.sh
