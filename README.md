## 查看系统
```
# 查看Linux内核版本命令
cat /proc/version
# 查看Linux系统版本的命令
lsb_release -a
cat /proc/version
```

## 免密登陆远程服务器

## Docker

```
# 删除所有镜像
docker rmi $(docker images -q)
```


## Openresty


## Atlassian

```
# 激活JIRA Software
java -jar /opt/atlassian/jira/atlassian-agent.jar -d -m jianyang1209@outlook.com -n DEV -p jira -o https://jira.kabunx.dev -s B7QM-1NK7-NWGU-AUCR
# 激活Confluence
java -jar /opt/atlassian/confluence/atlassian-agent.jar -d -m jianyang1209@outlook.com -n DEV -p conf -o https://confluence.kabunx.dev -s BXM9-BYKC-J1TN-GY4G



java -jar /opt/atlassian/jira/atlassian-agent.jar -d -m jianyang1209@outlook.com -n DEV -p com.brizoit.gantt -o https://jira.kabunx.dev -s B7QM-1NK7-NWGU-AUCR


java -jar /opt/atlassian/jira/atlassian-agent.jar -d -m jianyang1209@outlook.com -n DEV -p plugin.jep -o https://jira.kabunx.dev -s B7QM-1NK7-NWGU-AUCR


java -jar /opt/atlassian/confluence/atlassian-agent.jar -d -m jianyang1209@outlook.com -n DEV -p com.mxgraph.confluence.plugins.diagramly -o https://confluence.kabunx.dev -s BXM9-BYKC-J1TN-GY4G

SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

## SkyWalking

### Idea 中
#### Windows
-javaagent:D:\Tools\skywalking-agents\kywalking-agent.jar
#### Linux
-javaagent:/skywalking/java-agent/skywalking-agent.jar