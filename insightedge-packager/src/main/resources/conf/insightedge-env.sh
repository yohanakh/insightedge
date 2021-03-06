#!/bin/bash
# ***********************************************************************************************************
# * This script is used to initialize common environment to GigaSpaces InsightEdge platform.                *
# * It is highly recommended NOT TO MODIFY THIS SCRIPT, to simplify future upgrades.                        *
# * If you need to override the defaults, please modify $XAP_HOME\bin\setenv-overrides.sh or set           *
# * the XAP_SETTINGS_FILE environment variable to your custom script.                                       *
# * For more information see http://docs.gigaspaces.com/xap/12.2/dev-java/common-environment-variables.html *
# ***********************************************************************************************************
# Source XAP environment:
DIRNAME=$(dirname ${BASH_SOURCE[0]})
source "${DIRNAME}/../../bin/setenv.sh"

# Set InsightEdge defaults:
export INSIGHTEDGE_CLASSPATH="${XAP_HOME}/insightedge/lib/*:${XAP_HOME}/lib/required/*:${XAP_HOME}/lib/optional/spatial/*"

if [ -n "${INSIGHTEDGE_CLASSPATH_EXT}" ]; then
    export INSIGHTEDGE_CLASSPATH="${INSIGHTEDGE_CLASSPATH_EXT}:${INSIGHTEDGE_CLASSPATH}"
fi

# Set SPARK_HOME if not set
if [ -z "${SPARK_HOME}" ]; then
    export SPARK_HOME="${XAP_HOME}/insightedge/spark"
fi

# Spark Submit
if [ -z "$SPARK_SUBMIT_OPTS" ]; then
    export SPARK_SUBMIT_OPTS="-Dspark.driver.extraClassPath=${INSIGHTEDGE_CLASSPATH} -Dspark.executor.extraClassPath=${INSIGHTEDGE_CLASSPATH}"
fi

# Zeppelin
export ZEPPELIN_INTP_CLASSPATH_OVERRIDES="${INSIGHTEDGE_CLASSPATH}"

if [ -z "${ZEPPELIN_PORT}" ]; then
    export ZEPPELIN_PORT=9090
fi

if [ -z "${ZEPPELIN_LOG_DIR}" ]; then
	export ZEPPELIN_LOG_DIR="${XAP_HOME}/logs/"
fi

if [ -z "${INSIGHTEDGE_SPACE_NAME}" ]; then
    export INSIGHTEDGE_SPACE_NAME="insightedge-space"
fi