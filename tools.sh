#!/bin/bash
set -e

apt update
apt install -y net-tools

apt install -y net-tools openssh-server
systemctl status ssh

sudo apt install -y zsh
# 改用zsh
chsh -s /bin/zsh

# 默认已经安装了rsync screen 工具

unalias cp

cp -f prod-ymtd.lua.bak prod-ymtd.lua && nginx -s reload