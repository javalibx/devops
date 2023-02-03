#!/bin/bash

set -e

echo "[Entrypoint] Apache SkyWalking Docker Image"

JAVA_OPTS="${JAVA_OPT} -Xms512m -Xmx512m"

EXT_CONFIG_DIR=/skywalking/ext-config
# Override configuration files
if [ "$(ls -A $EXT_CONFIG_DIR)" ]; then
  cp -vfRL ${EXT_CONFIG_DIR}/* config/
fi

CLASSPATH="config:$CLASSPATH"
for i in oap-libs/*.jar
do
    CLASSPATH="$i:$CLASSPATH"
done

EXT_LIB_DIR=/skywalking/ext-libs
for i in "${EXT_LIB_DIR}"/*.jar
do
    CLASSPATH="$i:$CLASSPATH"
done

set -ex

exec java ${JAVA_OPTS} -classpath ${CLASSPATH} org.apache.skywalking.oap.server.starter.OAPServerStartUp "$@"