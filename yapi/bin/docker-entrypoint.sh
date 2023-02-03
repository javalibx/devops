#!/bin/sh
set -x

# 安装程序会初始化数据库索引和管理员账号，管理员账号名可在 config.json 配置
# TODO 判断是否已初始化
#npm run install-server

# 启动服务器后，请访问 127.0.0.1:{config.json配置的端口}，初次运行会有个编译的过程，请耐心等候
node server/app.js