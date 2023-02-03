FROM node:12-alpine as builder

WORKDIR /yapi

COPY releases/yapi-1.12.0.tar.gz yapi-1.12.0.tar.gz

RUN set -ex \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache python make \
    && tar -zxf yapi-1.12.0.tar.gz  \
    && mv yapi-1.12.0 vendors \
    && cd vendors \
    && rm -rf package-lock.json \
    && npm install --production --registry https://registry.npm.taobao.org

FROM node:12-alpine

LABEL maintainer="jonathan <jianyang1209@outloook>"

ENV TZ="Asia/Shanghai"

WORKDIR /yapi/vendors

COPY --from=builder /yapi/vendors /yapi/vendors
COPY bin/docker-entrypoint.sh docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]