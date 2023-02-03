# 多层构建能够将前置阶段中的文件拷贝到后边的阶段中
FROM kabunx/skywalking:alpine AS skywalking

FROM openjdk:8-jre-slim

LABEL maintainer="jonathan <jianyang1209@outlook.com>"

COPY --from=skywalking /skywalking/java-agent /skywalking/java-agent

ENV JAVA_TOOL_OPTIONS=-javaagent:/skywalking/java-agent/skywalking-agent.jar

RUN mkdir -p /var/www

WORKDIR /var/www