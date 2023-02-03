FROM kabunx/skywalking:alpine as skywalking

WORKDIR /skywalking/apm

RUN set -eux; \
    rm -rf "config/log4j2.xml" && rm -rf "webapp" && \
    mkdir ext-config && mkdir ext-libs

COPY config/log4j2.xml config/log4j2.xml
COPY docker-entrypoint.sh docker-entrypoint.sh

RUN set -eux; \
    chmod +x docker-entrypoint.sh

FROM openjdk:8-jre-slim

LABEL maintainer="jonathan <jianyang1209@outlook.com>"

COPY --from=skywalking /skywalking/apm /skywalking
COPY --from=skywalking /skywalking/cli-bin/swctl /skywalking/bin/swctl

WORKDIR /skywalking

EXPOSE 12800 11800 1234

ENTRYPOINT ["./docker-entrypoint.sh"]