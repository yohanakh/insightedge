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
# Set SPARK_HOME if not set
if [ -z "${SPARK_HOME}" ]; then
    export SPARK_HOME="${XAP_HOME}/insightedge/spark"
fi

export INSIGHTEDGE_CORE_CP="${XAP_HOME}/insightedge/lib/*:${XAP_HOME}/lib/required/*:${XAP_HOME}/lib/optional/spatial/*"

# Spark Submit
export SPARK_SUBMIT_OPTS="-Dscala.usejavacp=true -Dspark.driver.extraClassPath=${INSIGHTEDGE_CORE_CP} -Dspark.executor.extraClassPath=${INSIGHTEDGE_CORE_CP}"

# Zeppelin
export ZEPPELIN_INTP_CLASSPATH_OVERRIDES="${INSIGHTEDGE_CORE_CP}"
#export SPARK_SUBMIT_OPTIONS="--conf spark.executor.extraClassPath=${INSIGHTEDGE_CORE_CP}"
