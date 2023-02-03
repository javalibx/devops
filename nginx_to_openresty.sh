#!/bin/bash

# 进入一个下载目录
# 下载
wget https://openresty.org/download/openresty-1.21.4.1.tar.gz
# 解压
tar -zxf openresty-1.21.4.1.tar.gz

# 进入解压目录
cd openresty-1.21.4.1

# 查看原来 nginx 的编译信息
# nginx -V
# --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx 
# --with-compat --with-debug --with-file-aio --with-google_perftools_module --with-http_addition_module --with-http_auth_request_module 
# --with-http_dav_module --with-http_degradation_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module 
# --with-http_image_filter_module=dynamic --with-http_mp4_module --with-http_perl_module=dynamic --with-http_random_index_module 
# --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module 
# --with-http_sub_module --with-http_v2_module --with-http_xslt_module=dynamic --with-mail=dynamic --with-mail_ssl_module --with-pcre 
# --with-pcre-jit --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-threads 
# 上面 nginx 的配置参数后面添加 --with-luajit
./configure --with-compat --with-debug --with-file-aio --with-google_perftools_module --with-http_addition_module --with-http_auth_request_module \
 --with-http_dav_module --with-http_degradation_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module \
 --with-http_image_filter_module=dynamic --with-http_mp4_module --with-http_perl_module=dynamic --with-http_random_index_module \
 --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module \
 --with-http_sub_module --with-http_v2_module --with-http_xslt_module=dynamic --with-mail=dynamic --with-mail_ssl_module --with-pcre \
 --with-pcre-jit --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-threads --with-luajit

## 注意：Openresty 基于 Nginx，所以天然支持 HTTP2，但默认情况下并未启用，
## 需要在编译前的 configure 时使用选项 “--with-http_v2_module” 开启
## 因为 HTTP2 保持了对 HTTP1.0/1.1 的高度兼容性，多路复用、头部压缩等工作都是在底层进行的，
## 所以使用 Openresty 开发 HTTP2 应用没有任何难度，与开发普通的 HTTP 或 HTTPS 应用一样。

# 安装
gmake && gmake install

# 验证 openresty 安装成功

/usr/local/openresty/nginx/sbin/nginx -V

# 使用 openresty 替换 nginx
# 转移配置文件
rm -rf /usr/local/openresty/nginx/conf/*
cp -r /etc/nginx/* /usr/local/openresty/nginx/conf

# 将 openresty 配置文件目录链接至 /etc/nginx 目录下(非必要)
ln -s /usr/local/openresty/nginx/ /etc/nginx/

# 停止原 nginx 并启动 openresty
nginx -s stop && /usr/local/openresty/nginx/sbin/nginx

# 卸载原 nginx (根据 linux 发行版不同有所区别)
yum remove nginx

# 将 openresty 二进制执行文件（/usr/local/openresty/nginx/sbin/nginx）链接至 /usr/sbin/nginx (非必要)
ln -s /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx

# 设置开机启动（CentOS7系统）

# 在路径 /usr/lib/systemd/system/ 路径下新建文件 nginx.service
# 

# 配置 systemctl 开启启动
systemctl enable nginx.service
systemctl start nginx.service
