FROM atlassian/jira-software:8.20

COPY ./jar/atlassian-agent.jar /opt/atlassian/jira/atlassian-agent.jar
COPY ./jar/mysql-connector-java-8.0.28.jar /opt/atlassian/jira/lib/mysql-connector-java-8.0.28.jar

# 设置启动加载代理包
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/jira/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/jira/bin/setenv.sh