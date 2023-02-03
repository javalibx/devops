FROM atlassian/confluence:7.11

LABEL maintainer="Jonathan <jianyang1209@outlook.com>"

COPY ./jar/atlassian-agent.jar /opt/atlassian/confluence/atlassian-agent.jar
COPY ./jar/mysql-connector-java-8.0.28.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-8.0.28.jar

# 设置启动加载代理包
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/confluence/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/confluence/bin/setenv.sh