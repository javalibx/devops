FROM kabunx/skywalking:alpine AS skywalking

WORKDIR /skywalking/apm

RUN set -eux; \
    rm -rf "config" && rm -rf "oap-libs"

# 自定义配置与启动
COPY config/logback.xml webapp/logback.xml
COPY docker-entrypoint.sh docker-entrypoint.sh

RUN set -eux; \
    chmod +x docker-entrypoint.sh

FROM openjdk:8-jre-slim

LABEL maintainer="jonathan <jianyang1209@outlook.com>"

COPY --from=skywalking /skywalking/apm /skywalking

ENV SW_OAP_ADDRESS="http://skywalking-oap:12800"

WORKDIR /skywalking

EXPOSE 8080

ENTRYPOINT ["./docker-entrypoint.sh"]