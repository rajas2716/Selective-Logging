#!/bin/bash
set -ex

#Removing existing folder if it exists for a clean start
DIR="/etc/automation_script"
if [ -d "$DIR" ]; then
    printf '%s\n' "Removing Lock ($DIR)"
    sudo rm -rf "$DIR"
fi

#Creating Directories
sudo mkdir /etc/automation_script
sudo mkdir /etc/automation_script/disable
sudo mkdir /etc/automation_script/enable

#Downloading utilities and other important files
LOCAL_CHECK_TABLE="/etc/automation_script/check_table.py"
REMOTE_CHECK_TABLE_URI="https://automationscripttable.blob.core.windows.net/scriptfiles/check_table.py"
wget $REMOTE_CHECK_TABLE_URI -O $LOCAL_CHECK_TABLE

LOCAL_DISABLE_TABLE_UTILITIES="/etc/automation_script/disable_table_utilities.sh"
REMOTE_DISABLE_TABLE_UTILITIES="https://automationscripttable.blob.core.windows.net/scriptfiles/disable_table_utilities.sh"
wget $REMOTE_DISABLE_TABLE_UTILITIES -O $LOCAL_DISABLE_TABLE_UTILITIES

LOCAL_LOG_ANALYTICS_UTILITIES_PY="/etc/automation_script/log_analytics_utilities.py"
REMOTE_LOG_ANALYTICS_UTILITIES_PY="https://automationscripttable.blob.core.windows.net/scriptfiles/log_analytics_utilities.py"
wget $REMOTE_LOG_ANALYTICS_UTILITIES_PY -O $LOCAL_LOG_ANALYTICS_UTILITIES_PY

LOCAL_DISABLE_TABLES="/etc/automation_script/disable/disable_tables.sh"
REMOTE_DISABLE_TABLES="https://automationscripttable.blob.core.windows.net/scriptfiles/disable_tables.sh"
wget $REMOTE_DISABLE_TABLES -O $LOCAL_DISABLE_TABLES

LOCAL_ENABLE_TABLES="/etc/automation_script/enable/enable_tables.sh"
REMOTE_ENABLE_TABLES="https://automationscripttable.blob.core.windows.net/scriptfiles/enable_tables.sh"
wget $REMOTE_ENABLE_TABLES -O $LOCAL_ENABLE_TABLES

LOCAL_DISABLE_SOURCES="/etc/automation_script/disable/disable_sources.sh"
REMOTE_DISABLE_SOURCES="https://automationscripttable.blob.core.windows.net/scriptfiles/disable_sources.sh"
wget $REMOTE_DISABLE_SOURCES -O $LOCAL_DISABLE_SOURCES

LOCAL_ENABLE_SOURCES="/etc/automation_script/enable/enable_sources.sh"
REMOTE_ENABLE_SOURCES="https://automationscripttable.blob.core.windows.net/scriptfiles/enable_sources.sh"
wget $REMOTE_ENABLE_SOURCES -O $LOCAL_ENABLE_SOURCES

#importing functions in disable_table_utilities
. /etc/automation_script/disable_table_utilities.sh

#Setting command line arguments
COMMAND_LINE_ARGUMENTS=$@

#Setting global variables
DOMAIN_NAME="$(hostname)"
get_node_and_cluster_type $DOMAIN_NAME #Function used to set NODE_TYPE and CLUSTER_TYPE

STORAGE_ACCT="hdiconfigactions"
STORAGE_ENDPOINT_SUFFIX_AZURE="core.windows.net"

REMOTE_CONFIG_LIST_URI="https://${STORAGE_ACCT}.blob.${STORAGE_ENDPOINT_SUFFIX_AZURE}/loganalyticsmonitoring/node_type_configurations/${CLUSTER_TYPE}/${CLUSTER_TYPE}${NODE_TYPE}.json"
FILE_NAME="${CLUSTER_TYPE}${NODE_TYPE}.json"
LOCAL_CONFIG_LIST="/etc/automation_script/${FILE_NAME}"

if [[ ! -f "$LOCAL_CONFIG_LIST" ]]; then  
    wget $REMOTE_CONFIG_LIST_URI -O $LOCAL_CONFIG_LIST
fi

python /etc/automation_script/check_table.py $COMMAND_LINE_ARGUMENTS $FILE_NAME