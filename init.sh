#!/bin/bash
echo "修改为清华源"
# 备份配置文件：
cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
# 配置下列方案
sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

function install_jq() {
  echo "检查jq......"
  if jq --help; then
    echo "检查到jq已安装!"
  else
    apt -y install jq
  fi
}

function install_docker() {
  echo "检查Docker......"
  if docker -v; then
    echo "检查到Docker已安装!"
  else
    echo "开始安装Docker"
    # 判断是否已安装docker
    # 1、Uninstall old versions
  fi
  # docker镜像源
  if [[ ! -f /etc/docker/daemon.json ]]; then
    cp -f /home/zz/local/docker/daemon.json /etc/docker/daemon.json
  fi
}

function install_screen() {
  echo "检查Screen......"
  if screen -v; then
    echo "检查到Screen已安装!"
  else
    echo "开始安装Screen..."
    apt install -y screen
  fi
}

install_docker
install_jq
install_screen