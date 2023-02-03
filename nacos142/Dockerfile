FROM openjdk:8-jre-slim

ENV MODE="cluster" \
    PREFER_HOST_MODE="ip"\
    BASE_DIR="/home/nacos" \
    CLASSPATH=".:/home/nacos/conf:$CLASSPATH" \
    CLUSTER_CONF="/home/nacos/conf/cluster.conf" \
    FUNCTION_MODE="all" \
    NACOS_USER="nacos" \
    JAVA="/usr/local/openjdk-8/bin/java" \
    JVM_XMS="512m" \
    JVM_XMX="512m" \
    JVM_XMN="256m" \
    JVM_MS="128m" \
    JVM_MMS="320m" \
    NACOS_DEBUG="n" \
    TOMCAT_ACCESSLOG_ENABLED="false" \
    TZ=Asia/Shanghai

WORKDIR $BASE_DIR

COPY target/nacos-server-1.4.2.jar target/nacos-server.jar
ADD conf/application.properties conf/application.properties
ADD conf/nacos-logback.xml conf/nacos-logback.xml

# copy nacos bin
ADD bin/docker-startup.sh bin/docker-startup.sh
RUN chmod +x bin/docker-startup.sh

# set startup log dir
RUN mkdir -p logs \
    && cd logs \
    && touch start.out \
    && ln -sf /dev/stdout start.out \
    && ln -sf /dev/stderr start.out

EXPOSE 8848
ENTRYPOINT ["bin/docker-startup.sh"]