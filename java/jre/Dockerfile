# 这里我将添加skywalking
# 多层构建能够将前置阶段中的文件拷贝到后边的阶段中
FROM kabunx/skywalking:alpine AS skywalking

FROM openjdk:8-jre-slim

LABEL maintainer="jonathan<jianyang1209@outloook.com>"

# 切换镜像源（请注意这里使用 apt 部分机器需求替换为 apt-get）
RUN set -ex; \
    cp /etc/apt/sources.list /etc/apt/sources.list.bak; \
    echo " " > /etc/apt/sources.list; \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list; \
    apt update && apt -y install curl

WORKDIR /var

# 安装 skywalking
COPY --from=skywalking /skywalking/java-agent /skywalking/java-agent

# set environment
ENV BASE_DIR="/var/spring" \
    MODE="test" \
    TZ="Asia/Shanghai"

WORKDIR $BASE_DIR

# startup
ADD bin/docker-startup.sh bin/docker-startup.sh
RUN chmod +x bin/docker-startup.sh

# 服务端口&监控端口
EXPOSE 5001 15001
ENTRYPOINT ["bin/docker-startup.sh"]