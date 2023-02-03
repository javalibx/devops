#!/bin/bash

set -ex
export LOGGING_CONFIG="webapp/logback.xml"

JAVA_OPTS="${JAVA_OPT} -Xms512m -Xmx512m"

exec java ${JAVA_OPTS} -cp webapp/skywalking-webapp.jar:webapp org.apache.skywalking.oap.server.webapp.ApplicationStartUp "$@"