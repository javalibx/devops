#--------------------------------------------------------------------------
# Image Setup | 如果需要skywalking请使用alpine3.16
#--------------------------------------------------------------------------
FROM php:fpm-alpine3.16

LABEL maintainer="jonathan <jianyang1209@outlook.com>"

RUN set -ex; \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories; \
    apk update; \
    mkdir -p /run/nginx; \
    apk add --no-cache nginx supervisor tzdata; \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone; \
    apk del tzdata

COPY php/redis-5.3.7.tgz /tmp/redis-5.3.7.tgz

RUN set -ex; \
    apk add --no-cache --virtual .build-deps autoconf gcc g++ make \
    && cd /tmp \
    && pecl install redis-5.3.7.tgz && docker-php-ext-enable redis \
    && apk add --no-cache icu-dev libpng-dev libjpeg-turbo-dev freetype-dev libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd bcmath opcache pdo_mysql intl pcntl sockets zip \
    && rm -rf /tmp/* \
    && apk del .build-deps

# copy crontabs,php,nginx,supervisor configration
COPY crontabs/root /etc/crontabs/root
COPY php/conf.d /usr/local/etc/php/conf.d
COPY php/fpm.d /usr/local/etc/php-fpm.d
COPY nginx/http.d /etc/nginx/http.d
COPY supervisord.conf /etc/supervisord.conf
COPY supervisor.d /etc/supervisor.d

CMD ["supervisord", "-n"]
