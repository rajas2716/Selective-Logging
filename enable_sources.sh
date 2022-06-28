#!/bin/bash
set -ex

#Setting command line arguments
SOURCE_NAME=$1
FILE_NAME=$2

#Declaring global variables
DISABLE_DIR=/etc/td-agent/history

VALID_DEFAULT_SOURCES=("AmbariAuditLog" "AuthLog")
DEFAULT_FILE_NAMES=("AmbariAuditLog.conf" "AuthLog.conf")

VALID_SPARK_SOURCES=("MRJobSummary" "ResourceManager" "TimelineServer" "NodeManager" "JupyterLog" "LivyLog" "SparkThriftDriverLog" "SparkExecutorLog" "SparkDriverLog" "OozieLog")
SPARK_FILE_NAMES=("YarnMRJobSummaryLog.conf" "YarnResourceManagerLog.conf" "YarnTimelineServerLog.conf" "YarnNodeManagerLog.conf" "SparkJupyterLog.conf" "SparkLivyLog.conf" "SparkThriftDriverLog.conf" "SparkExecutorLog.conf" "SparkDriverLog.conf" "OozieLog.conf")

#Sources/ Log Types in HBase Cluster
VALID_HBASE_SOURCES=("MRJobSummary" "ResourceManager" "TimelineServer" "NodeManager" "HDFSGarbageCollectorLog" "HDFSNameNodeLog" "PhoenixServerLog" "HBaseRegionServerLog" "HBaseRestServerLog" "HBaseMasterLog")
HBASE_FILE_NAMES=("YarnMRJobSummaryLog.conf" "YarnResourceManagerLog.conf" "YarnTimelineServerLog.conf" "YarnNodeManagerLog.conf" "HBaseHDFSGarbageCollectorLog.conf" "HBaseHDFSNameNodeLog.conf" "HBasePhoenixServerLog.conf" "HBaseRegionServerLog.conf" "HBaseRestServerLog.conf" "HBaseMasterLog.conf")

#Sources/ Log Types in interactive cluster
VALID_INTERACTIVE_SOURCES=("MRJobSummary" "ResourceManager" "TimelineServer" "NodeManager" "InteractiveHiveMetastoreLog" "ZeppelinLog" "InteractiveHiveHSILog")
INTERACTIVE_FILE_NAMES=("YarnMRJobSummaryLog.conf" "YarnResourceManagerLog.conf" "YarnTimelineServerLog.conf" "YarnNodeManagerLog.conf" "InteractiveHiveMetastoreLog.conf" "InteractiveHiveZeppelinLog.conf" "InteractiveHiveHSILog.conf")

#Sources/ Log Types in Hadoop Cluster
VALID_HADOOP_SOURCES=("MRJobSummary" "ResourceManager" "TimelineServer" "NodeManager" "HiveMetastoreLog" "HiveServer2Log" "WebHcatLog")
HADOOP_FILE_NAMES=("YarnMRJobSummaryLog.conf" "YarnResourceManagerLog.conf" "YarnTimelineServerLog.conf" "YarnNodeManagerLog.conf" "HiveMetastoreLog.conf" "HiveServer2Log.conf" "HiveWebHcatLog.conf")

if [[ $FILE_NAME == *"default"* ]]
then
    #Checks if the output configuration file is already in history directory or not.
    #If not then it is moved there hence disabled
    for i in ${!VALID_DEFAULT_SOURCES[@]}; do
    if [[ $SOURCE_NAME == *"${VALID_DEFAULT_SOURCES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${DEFAULT_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Reenabling ${SOURCE_NAME}"
            sudo mv "/etc/td-agent/history/${DEFAULT_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsSourceConfigurations/${DEFAULT_FILE_NAMES[$i]}"
        else
            echo "${SOURCE_NAME} is already enabled"
        fi
        fi
    done
elif [[ $FILE_NAME == *"spark"* ]]
then
    #Checks if the output configuration file is already in history directory or not.
    #If not then it is moved there hence disabled
    for i in ${!VALID_SPARK_SOURCES[@]}; do
    if [[ $SOURCE_NAME == *"${VALID_SPARK_SOURCES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${SPARK_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Enabling ${SOURCE_NAME}"
            sudo mv "/etc/td-agent/history/${SPARK_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsSourceConfigurations/${SPARK_FILE_NAMES[$i]}"
        else
            echo "${SOURCE_NAME} is already enabled"
        fi
        fi
    done
elif [[ $FILE_NAME == *"interactivehive"* ]]
then
    for i in ${!VALID_INTERACTIVE_SOURCES[@]}; do
    if [[ $SOURCE_NAME == *"${VALID_INTERACTIVE_SOURCES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${INTERACTIVE_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Enabling ${SOURCE_NAME}"
            sudo mv "/etc/td-agent/history/${INTERACTIVE_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsSourceConfigurations/${INTERACTIVE_FILE_NAMES[$i]}"
        else
            echo "${SOURCE_NAME} is already enabled"
        fi
        fi
    done
elif [[ $FILE_NAME == *"hbase"* ]]
then
    #Checks if the output configuration file is already in history directory or not.
    #If not then it is moved there hence disabled
    for i in ${!VALID_HBASE_SOURCES[@]}; do
    if [[ $SOURCE_NAME == *"${VALID_HBASE_SOURCES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${HBASE_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Enabling ${SOURCE_NAME}"
            sudo mv "/etc/td-agent/history/${HBASE_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsSourceConfigurations/${HBASE_FILE_NAMES[$i]}"
        else
            echo "${SOURCE_NAME} is already enabled"
        fi
        fi
    done
elif [[ $FILE_NAME == *"hadoop"* ]]
then
    for i in ${!VALID_HADOOP_SOURCES[@]}; do
    if [[ $SOURCE_NAME == *"${VALID_HADOOP_SOURCES[$i]}"* ]]
    then
        FILE="/etc/td-agent/history/${HADOOP_FILE_NAMES[$i]}"
        if test -f "$FILE"; then
            echo "Enabling ${SOURCE_NAME}"
            sudo mv "/etc/td-agent/history/${HADOOP_FILE_NAMES[$i]}" "/etc/td-agent/CurrentLogAnalyticsSourceConfigurations/${HADOOP_FILE_NAMES[$i]}"
        else
            echo "${SOURCE_NAME} is already enabled"
        fi
        fi
    done
else
    echo "$FILE_NAME is not supported"
fi