#!/bin/bash

## Set TimeZone to Asia/Ho_Chi_Minh
echo ">>>>> [TASK] Set TimeZone to Asia/Ho_Chi_Minh"
timedatectl set-timezone Asia/Ho_Chi_Minh

## Update the system >/dev/null 2>&1
echo ">>>>> [TASK] Update the system"
yum install -y epel-release >/dev/null 2>&1
yum update -y >/dev/null 2>&1

## Install ultilities packages
echo ">>>>> [TASK] Install ultilities packages"
yum install -y telnet htop net-tools wget nano >/dev/null 2>&1

## Enable password authentication
echo ">>>>> [TASK] Enabled SSH password authentication"
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
systemctl reload sshd

## Disable Password authentication
#echo ">>>>> [TASK] Disabled SSH password authentication"
#sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
#systemctl reload sshd

## Set Root Password
echo ">>>>> [TASK] Set root password"
echo "centos" | passwd --stdin root >/dev/null 2>&1

## Disable and Stop firewalld
echo ">>>>> [TASK] Disable and stop firewalld"
systemctl disable firewalld
systemctl stop firewalld

## Disable SELinux
echo ">>>>> [TASK] Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

## Install docker from Docker-ce repository
echo ">>>>> [TASK] Install docker container engine"
yum install -y -q yum-utils device-mapper-persistent-data lvm2 > /dev/null 2>&1
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo > /dev/null 2>&1
yum install -y -q docker-ce >/dev/null 2>&1

## Enable docker service
echo ">>>>> [TASK] Enable & start docker service"
systemctl daemon-reload
systemctl enable docker >/dev/null 2>&1
systemctl start docker

## Add vagrant user to docker group
echo ">>>>> [TASK] Add vagrant user to docker group"
usermod -aG docker vagrant

## Update hosts file
echo ">>>>> [TASK] Update host file /etc/hosts"
cat >>/etc/hosts<<EOF
192.168.16.161 gitlab1.testlab.local gitlab1
192.168.16.151 docker1.testlab.local docker1
192.168.16.141 jenkins1.testlab.local jenkins1
192.168.16.130 kmaster.testlab.local kmaster
192.168.16.131 kworker1.testlab.local kworker1
192.168.16.132 kworker2.testlab.local kworker2
EOF

## Install Python3.x & pip3 & git & awscli
echo ">>>>> [TASk] Install Python3.x & pip & git & awscli"
yum install -y git >/dev/null 2>&1
yum install -y centos-release-scl >/dev/null 2>&1
yum install -y rh-python36 >/dev/null 2>&1
yum install -y python3-pip >/dev/null 2>&1
pip3 install awscli >/dev/null 2>&1

## Cleanup system >/dev/null 2>&1
echo ">>>>> [TASK] Cleanup system"
package-cleanup -y --oldkernels --count=1 >/dev/null 2>&1
yum -y autoremove >/dev/null 2>&1
yum clean all >/dev/null 2>&1
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp
#dd if=/dev/zero of=/EMPTY bs=1M
#rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c

## Rebooting Server
echo ">>>>> [TASK] Rebooting server"
echo ""
echo "########## Finished ##########"
sudo reboot now
