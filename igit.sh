#!/usr/bin/env bash

yum install git -y
useradd git
chown -R git.git /srv/webroot

su git
cd /home/git

ssh-keygen -t rsa -C 784855684@qq.com
git config --global user.name lich4ung
git config --global user.email 784855684@qq.com
git config --global core.autocrlf false

cat /home/git/.ssh/id_rsa.pub > /home/git/.ssh/authorized_keys
