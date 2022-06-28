# Selective Logging Capability in Azure HDInsight Log Analytics

### Aim of the project
To add the functionality of selective logging capability in Azure HDInsight Log Analytics. Customer should be able to disable/enable tables or log types of their choice. Customer will only pay for what they use.


### Tech Stack Used
Fluentd(td-agent), Azure Monitoring portal (Geneva monitoring), script action, bash scripts, python scripts, mds daemon

**Note: The tables and log types are disabled/enabled using a script run through script action in azure portal which runs the script in the nodes of a cluster.**

## How are data/logs collected?

1. Fluentd has a unified logging layer which takes all different types of data/logs tagged using configuration files and passed to the monitoring service which further sends it to log analytics workspace.

2. Log analytics install script installs the configuration files inside a cluster in the following location (/etc/td-agent). Since there are 3 types of nodes in a HDInsight Cluster i.e. (Head Node, Zookeeper Node and the Worker Node). Different types of configuration files are installed according to the node type.

3. There are different log tables present in a log analytics workspace and each table has multiple sources(also called log types). For e.g SecurityLog Table has two sources AuthLog and AmbariAuditLog.

4. There are two main folders CurrentLogAnalyticsOutputConfigurations and CurrentLogAnalyticsSourceConfigurations. The ouptut configuration folder contains all the main top level tables which collect data from sources in the source configuration folder.

## How specific tables and their log types are disabled/ enabled?

### 1. Hash Map to map tables and their sources
Each table is mapped to its corresponding configuration file in the hashmap, so if a customer wants to disable table A then the confgiuration file responsible for that table is changed. (Example: SparkLogs -> SparkLogOutput.conf). Similarly sources are also mapped to their corresponding config files.

### 2. Checking tables if they are present in the current nodes
The script checks if the table/log type name given by the user is present in the particular node of the cluster. If it is present then further action is performed otherwise nothing is done.

### 3. Disabling and Enabling of a table
After the config file name is found and it is deduced that the particular table/log type is present inside the node.

**DISABLE** - The particular config file is removed from its original position and put in another directory named history (location: /etc/td-agent/history).

**ENABLE** - The particular config file is moved back to its original position from the history directory.

***NOTE: Since the config file is responsible for the data population inside the table, we can control the data flow by moving the config file.***

The entry point/main script which we run in script action is **automation_script.sh**

## Selective Logging with Script Action in Azure Portal

Use script action to run the script in all the nodes of a cluster and perform disable/enable of tables and their log types.

Please find the steps below inside the documentation to use this feature using scrip action.

[How to use Selective Logging Feature](https://microsoftapc.sharepoint.com/:w:/t/HDInsightEngineering-Blr/EbUtuVmObGNCnXFojA_tUJgBTEosVVQu6-ri35pXc8QYtA?e=FgF1kv)

## Manually run selective logging command in all the nodes of a cluster

One can also use it by running the following commands inside the nodes of a cluster after ssh.


```bash
PARAMETERS="HDInsightHadoopAndYarnLogs, HDInsightAmbariSystemMetrics, HDInsightSecurityLogs, HDInsightHadoopAndYarnMetrics --disable"
wget https://automationscripttable.blob.core.windows.net/scriptfiles/automation_script.sh
sudo bash automation_script.sh $PARAMETERS
```

NOTE: Example parameters have been used in this code. You can learn parameter syntax from the documentation [How to use Selective Logging Feature](https://microsoftapc.sharepoint.com/:w:/t/HDInsightEngineering-Blr/EbUtuVmObGNCnXFojA_tUJgBTEosVVQu6-ri35pXc8QYtA?e=FgF1kv)

## More Documentations


**1. [Documentation on Log Analytics Installation](https://microsoftapc.sharepoint.com/:w:/t/HDInsightEngineering-Blr/EQaHTjYum_pPsEWTyM4D1McB-t19G988V1BoEQXLpBBrhw?e=90mgbY)**

This explains how log analytics is installed inside a cluster. Also which tables and log types are installed in which nodes of a cluster.

**2. [Documentation on Manual installation of Log Analytics](https://microsoftapc.sharepoint.com/:w:/t/HDInsightEngineering-Blr/EUPkyPcGcP9HpihA0w6Vn2gBjRPhJ0ZflJ5_JBrPDJRHyQ?e=Yj3PoK)**

Normally log analytics monitoring is installed using Monitor Integration in the Azure portal, but this documentation explains step wise how to install it manually using script action.

**3. [Documentation on Tables and their source types](https://microsoftapc.sharepoint.com/:w:/t/HDInsightEngineering-Blr/EVa3uxIvyytDjspbOQ6uH8wBsdvlJNXS2gWZ0pWEXjDssA?e=TUMgnD)**

This documentation covers all the names of tables and their log types inside HDInsight clusters.
