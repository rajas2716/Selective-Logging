#!/bin/bash
set -ex

#Setting Command Line arguments
TABLE_NAME=$1
FILE_NAME=$2

#Declaring global variables
#Default Tables which are present in all the clusters
VALID_DEFAULT_TABLES=("AmbariClusterAlerts" "AmbariSystemMetrics" "SecurityLog")
DEFAULT_FILE_NAMES=("AmbariClusterAlertsOutput.conf" "AmbariSystemMetricsOutput.conf" "SecurityLogOutput.conf")

#Tables which are present in spark cluster
VALID_SPARK_TABLES=("SparkLogs" "YarnLogs" "YarnMetrics" "OozieLog")
SPARK_FILE_NAMES=("SparkLogOutput.conf" "YarnLogOutput.conf" "YarnMetricsOutput.conf" "OozieLogOutput.conf")

#Tables which are present in hbase cluster
VALID_HBASE_TABLES=("YarnLogs" "HBaseLogs" "HBaseMetrics" "YarnMetrics")
HBASE_FILE_NAMES=("YarnLogOutput.conf" "HBaseLogOutput.conf" "HBaseMetricsOutput.conf" "YarnMetricsOutput.conf")

#Tables which are present in interactivehive cluster
VALID_INTERACTIVE_TABLES=("YarnLogs" "YarnMetrics" "HiveAndLLAPLogs" "HiveAndLLAPMetrics" "HiveTezAppStats")
INTERACTIVE_FILE_NAMES=("YarnLogOutput.conf" "YarnMetricsOutput.conf" "InteractiveHiveLogOutput.conf" "InteractiveHiveMetricsOutput.conf" "AppStatsHiveTezOutput.conf")

#Tables which are present in hadoop cluster
VALID_HADOOP_TABLES=("YarnLogs" "YarnMetrics" "HiveAndLLAPLogs" "HiveAndLLAPMetrics")
HADOOP_FILE_NAMES=("YarnLogOutput.conf" "YarnMetricsOutput.conf" "HiveLogOutput.conf" "HiveMetricsOutput.conf")

#Declaring global variables
DISABLE_DIR=/etc/td-agent/history

#Checking cluster type and disabling according to that
#Here default means tables which are present in all the clusters
if [[ $FILE_NAME == *"default"* ]]
then
    #Checks if the output configuration file is already in history directory or not.
    #If not then it is moved there hence disabled
    for i in ${!VALID_DEFAULT_TABLES[@]}; do
    if [[ $TABLE_NAME == *"${VALID_DEFAULT_TABLES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${DEFAULT_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Reenabling ${TABLE_NAME}"
            sudo mv "/etc/td-agent/history/${DEFAULT_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsOutputConfigurations/${DEFAULT_FILE_NAMES[$i]}"
        else
            echo "${TABLE_NAME} is already enabled"
        fi
        fi
    done
elif [[ $FILE_NAME == *"spark"* ]]
then
    #Checks if the output configuration file is already in history directory or not.
    #If not then it is moved there hence disabled
    for i in ${!VALID_SPARK_TABLES[@]}; do
    if [[ $TABLE_NAME == *"${VALID_SPARK_TABLES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${SPARK_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Enabling ${TABLE_NAME}"
            sudo mv "/etc/td-agent/history/${SPARK_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsOutputConfigurations/${SPARK_FILE_NAMES[$i]}"
        else
            echo "${TABLE_NAME} is already enabled"
        fi
        fi
    done
elif [[ $FILE_NAME == *"interactivehive"* ]]
then
    for i in ${!VALID_INTERACTIVE_TABLES[@]}; do
    if [[ $TABLE_NAME == *"${VALID_INTERACTIVE_TABLES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${INTERACTIVE_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Enabling ${TABLE_NAME}"
            sudo mv "/etc/td-agent/history/${INTERACTIVE_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsOutputConfigurations/${INTERACTIVE_FILE_NAMES[$i]}"
        else
            echo "${TABLE_NAME} is already enabled"
        fi
        fi
    done
elif [[ $FILE_NAME == *"hbase"* ]]
then
    for i in ${!VALID_HBASE_TABLES[@]}; do
    if [[ $TABLE_NAME == *"${VALID_HBASE_TABLES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${HBASE_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Enabling ${TABLE_NAME}"
            sudo mv "/etc/td-agent/history/${HBASE_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsOutputConfigurations/${HBASE_FILE_NAMES[$i]}"
        else
            echo "${TABLE_NAME} is already enabled"
        fi
        fi
    done
elif [[ $FILE_NAME == *"hadoop"* ]]
then
    for i in ${!VALID_HADOOP_TABLES[@]}; do
    if [[ $TABLE_NAME == *"${VALID_HADOOP_TABLES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${HADOOP_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Enabling ${TABLE_NAME}"
            sudo mv "/etc/td-agent/history/${HADOOP_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsOutputConfigurations/${HADOOP_FILE_NAMES[$i]}"
        else
            echo "${TABLE_NAME} is already enabled"
        fi
        fi
    done
else
    echo "$FILE_NAME is not supported"
fi