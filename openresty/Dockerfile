FROM alpine:3.15

LABEL maintainer="Jonathan <jianyang1209@outlook.com>"

ARG RESTY_APK_KEY_URL="http://openresty.org/package/admin@openresty.com-5ea678a6.rsa.pub"
ARG RESTY_APK_REPO_URL="https://openresty.org/package/alpine/v3.15/main"

RUN set ex; \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories; \
    wget -O "/etc/apk/keys/$(basename ${RESTY_APK_KEY_URL})" "${RESTY_APK_KEY_URL}" \
    && echo "${RESTY_APK_REPO_URL}" >> /etc/apk/repositories \
    && apk update \
    && apk add openresty \
    && mkdir -p /var/run/openresty \
    && mkdir -p /var/log/nginx \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log 

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT