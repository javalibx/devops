#!/bin/bash
set -x
export JAVA_HOME
export JAVA="$JAVA_HOME/bin/java"
#===========================================================================================
# JVM Configuration
# -Xss 规定了每个线程堆栈的大小。一般情况下256K是足够了。影响了此进程中并发线程数大小。
# -Xms：初始堆大小，堆内存的最小 Heap 值，默认为物理内存的1/64，但小于1G。默认当空余堆内存大于指定阈值时，JVM 会减小 heap 的大小到 -Xms 指定的大小。
# -Xmx：最大堆大小，堆内存的最大 Heap 值，默认为物理内存的1/4。默认当空余堆内存小于指定阈值时，JVM 会增大 Heap 到 -Xmx 指定的大小。
# -Xmn：年轻代大小(1.4)整个 JVM 内存大小 = 年轻代大小 + 年老代大小 + 持久代大小。
#       持久代一般固定大小为64m,所以增大年轻代后,将会减小年老代大小。
#       此值对系统性能影响较大，Sun 官方推荐配置为整个堆的3/8
# 在实际中，我们通常会设置的更大一些
# 下面的参数，需要根据机器配置做出相对应的调整
#===========================================================================================
echo "${MODE}"
if [[ "${MODE}" == "test" ]]; then
  JAVA_OPT="${JAVA_OPT} -server -Xms1024m -Xmx1024m -Xmn384m"
elif [[ "${MODE}" == "prod" ]]; then
  JAVA_OPT="${JAVA_OPT} -server -Xms2048m -Xmx2048m -Xmn768m"
fi

#==========================================================================================
# 垃圾回收
#==========================================================================================
JAVA_OPT="${JAVA_OPT} -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:G1MaxNewSizePercent=30 -XX:+DisableExplicitGC"
JAVA_OPT="${JAVA_OPT} -XX:+PrintGCTimeStamps -XX:+PrintGCCause -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dump.hprof"

#===========================================================================================
# Skywalking
# {appName} 选填，子应用，为全局概念，在应用下面子文件夹。
# {env} 选填，环境，主要用于环境过滤
# {envTag} 选填，环境标签，主要用于环境过滤，多个环境打上相同的环境标签，在web页面上可以通过标签将这些环境过滤出来。
# {business} 选填，应用英文名称，为全局概念。
#===========================================================================================
AGENT_FILE=/skywalking/java-agent/skywalking-agent.jar
if [[ -f ${AGENT_FILE} ]]; then
  JAVA_OPT="${JAVA_OPT} -javaagent:${AGENT_FILE}"
fi

#===========================================================================================
# Setting system properties
#===========================================================================================
# java version
JAVA_MAJOR_VERSION=$($JAVA -version 2>&1 | sed -E -n 's/.* version "([0-9]*).*$/\1/p')
if [[ "$JAVA_MAJOR_VERSION" -ge "9" ]] ; then
  echo "java version is ${JAVA_MAJOR_VERSION}"
else
  echo "java version is ${JAVA_MAJOR_VERSION}"
fi

JAVA_OPT="${JAVA_OPT} -jar ${BASE_DIR}/${SERVER_NAME}.jar"

case ${MODE} in
"dev")
  JAVA_OPT="${JAVA_OPT} --spring.profiles.active=dev"
  ;;
"test")
  JAVA_OPT="${JAVA_OPT} --spring.profiles.active=test"
  ;;
"prod")
  JAVA_OPT="${JAVA_OPT} --spring.profiles.active=prod"
  ;;
esac

# 手动配置 IP 
if [[ -n ${LOCAL_IP} ]]; then
  JAVA_OPT="${JAVA_OPT} --spring.cloud.nacos.discovery.ip=${LOCAL_IP}"
fi

if [[ -n ${SERVER_PORT} ]]; then
  JAVA_OPT="${JAVA_OPT} --server.port=${SERVER_PORT}"
fi

LOGBACK_XML=${BASE_DIR}/config/logback.xml
if [[ -f ${LOGBACK_XML} ]]; then
  JAVA_OPT="${JAVA_OPT} --logging.config=${LOGBACK_XML}"
fi

LOG_DIR=/var/log/${SERVER_NAME}
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
fi

echo "${SERVER_NAME} boot is starting, you can docker logs your container."

exec ${JAVA} ${JAVA_OPT}