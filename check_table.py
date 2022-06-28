import sys
import json
import subprocess
import log_analytics_utilities

# Setting Command line arguments
FILE_NAME = sys.argv[len(sys.argv) - 1]
COMMAND_LINE_ARGUMENT = sys.argv[1:len(sys.argv) - 1]
COMMAND_LINE_ARGUMENT = " ".join(COMMAND_LINE_ARGUMENT)
COMMAND_LINE_ARGUMENT = COMMAND_LINE_ARGUMENT.split("--")
ACTION = COMMAND_LINE_ARGUMENT[1]
TABLES = COMMAND_LINE_ARGUMENT[0].split(",")

# Declaring global variables
FILE_NAME = "/etc/automation_script/{}".format(FILE_NAME)

TD_AGENT_OUTPUTS = "tdAgentOutputs"

TD_AGENT_SOURCES = "tdAgentSources"

DISABLE_SOURCES = "/etc/automation_script/disable/disable_sources.sh"

ENABLE_SOURCES = "/etc/automation_script/enable/enable_sources.sh"

DISABLE_TABLES = "/etc/automation_script/disable/disable_tables.sh"

ENABLE_TABLES = "/etc/automation_script/enable/enable_tables.sh"

DEFAULT_TABLE_NAMES = ["HDInsightAmbariClusterAlerts",
                       "HDInsightAmbariSystemMetrics", "HDInsightSecurityLogs"]

TABLE_TO_CONFIG_MAP = {"HDInsightSparkLogs": "SparkLogOutput",
                       "HDInsightHadoopAndYarnLogs": "YarnLogOutput",
                       "HDInsightHadoopAndYarnMetrics": "YarnMetricsOutput",
                       "HDInsightOozieLogs": "OozieLogOutput",

                       #HBase Tables
                       "HDInsightHBaseLogs": "HBaseLogOutput",
                       "HDInsightHBaseMetrics": "HBaseMetricsOutput",
                       
                       #Interactive Query Tables
                       "HDInsightHiveAndLLAPLogs": "InteractiveHiveLogOutput",
                       "HDInsightHiveAndLLAPMetrics":"InteractiveHiveMetricsOutput",
                       "HDInsightHiveTezAppStats":"AppStatsHiveTezOutput",

                       }

TABLE_TO_CONFIG_HADOOP_MAP = {
                    "HDInsightHadoopAndYarnLogs": "YarnLogOutput",
                    "HDInsightHadoopAndYarnMetrics": "YarnMetricsOutput",
                    "HDInsightOozieLogs": "OozieLogOutput",
                    "HDInsightHiveAndLLAPLogs": "HiveLogOutput",
                    "HDInsightHiveAndLLAPMetrics": "HiveMetricsOutput",
}

DEFAULT_SOURCE_NAMES = ["AmbariAuditLog", "AuthLog"]

SOURCE_TO_CONFIG_MAP = {
                        #Spark Sources
                        "MRJobSummary": "YarnMRJobSummaryLog",
                        "ResourceManager": "YarnResourceManagerLog",
                        "TimelineServer": "YarnTimelineServerLog",
                        "NodeManager": "YarnNodeManagerLog",
                        "JupyterLog": "SparkJupyterLog",
                        "LivyLog": "SparkLivyLog",
                        "SparkThriftDriverLog": "SparkThriftDriverLog",
                        "SparkExecutorLog": "SparkExecutorLog",
                        "SparkDriverLog": "SparkDriverLog",
                        "OozieLog": "OozieLog",
                        #Hbase Sources
                        "HDFSGarbageCollectorLog": "HBaseHDFSGarbageCollectorLog",
                        "HDFSNameNodeLog" : "HBaseHDFSNameNodeLog",
                        "PhoenixServerLog" : "HBasePhoenixServerLog",
                        "HBaseRegionServerLog": "HBaseRegionServerLog",
                        "HBaseRestServerLog": "HBaseRestServerLog",
                        "HBaseMasterLog": "HBaseMasterLog",
                        #Interactive Sources
                        "InteractiveHiveMetastoreLog": "InteractiveHiveMetastoreLog",
                        "ZeppelinLog" :"InteractiveHiveZeppelinLog",
                        "InteractiveHiveHSILog":"InteractiveHiveHSILog"

                        }

SOURCE_TO_CONFIG_HADOOP_MAP = {
                        "MRJobSummary": "YarnMRJobSummaryLog",
                        "ResourceManager": "YarnResourceManagerLog",
                        "TimelineServer": "YarnTimelineServerLog",
                        "NodeManager": "YarnNodeManagerLog",
                        "HiveMetastoreLog": "HiveMetastoreLog",
                        "HiveServer2Log": "HiveServer2Log",
                        "WebHcatLog":"HiveWebHcatLog"
}

# Function for actions on table name
def table_function(TABLE_NAME):
    td_output_confs = []
    CONFIG_FILE_NAME="NULL"
    if TABLE_NAME in DEFAULT_TABLE_NAMES:
        if ACTION == "enable":
            command = "bash {} {} default".format(ENABLE_TABLES, TABLE_NAME)
            process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
            print(output)
        else:
            command = "bash {} {} default".format(
                DISABLE_TABLES, TABLE_NAME)
            process = subprocess.Popen(
                command.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
            print(output)
    else:
        with open(FILE_NAME) as node_type_conf_file:
            node_type_configuration = json.load(node_type_conf_file)
            if TD_AGENT_OUTPUTS in node_type_configuration:
                td_output_confs.extend(
                    node_type_configuration.get(TD_AGENT_OUTPUTS, []))

        # Get Config file name responsible for the table
        # Hadoop map is different because some table names coincide (temp solution)
        if "hadoop" in FILE_NAME:  
            if TABLE_NAME in TABLE_TO_CONFIG_HADOOP_MAP.keys():
                CONFIG_FILE_NAME = TABLE_TO_CONFIG_HADOOP_MAP[TABLE_NAME]
                print(CONFIG_FILE_NAME)
            else:
                print("INVALID TABLE NAME")
                print("Table name is incorrect please check table name")
                return
        else:
            if TABLE_NAME in TABLE_TO_CONFIG_MAP.keys():
                CONFIG_FILE_NAME = TABLE_TO_CONFIG_MAP[TABLE_NAME]
                print(CONFIG_FILE_NAME)
            else:
                print("INVALID TABLE NAME")
                print("Table name is incorrect please check table name")
                return

        # Check if config file name is present in this node
        if CONFIG_FILE_NAME not in td_output_confs:
            print("This node does not contain this table - {}".format(TABLE_NAME))
            return

        #Checks the action (enable or disable)
        if ACTION == "enable":
            command = "bash {} {} {}".format(
                ENABLE_TABLES, TABLE_NAME,FILE_NAME)
            process = subprocess.Popen(
                command.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
            print(output)
        else:
            command = "bash {} {} {}".format(
                DISABLE_TABLES, TABLE_NAME,FILE_NAME)
            process = subprocess.Popen(
                command.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
            print(output)

#Function for performing action related to logtypes(Enabling/Disabling of sources)
def source_function(SOURCE_NAME):
    td_source_confs = []
    CONFIG_FILE_NAME="NULL"
    if SOURCE_NAME in DEFAULT_SOURCE_NAMES:
        if ACTION == "enable":
            command = "bash {} {} default".format(ENABLE_SOURCES, SOURCE_NAME)
            process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
            print(output)
        else:
            command = "bash {} {} default".format(
                DISABLE_SOURCES, SOURCE_NAME)
            process = subprocess.Popen(
                command.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
            print(output)
    else:
        with open(FILE_NAME) as node_type_conf_file:
            node_type_configuration = json.load(node_type_conf_file)
            if TD_AGENT_SOURCES in node_type_configuration:
                td_source_confs.extend(
                    node_type_configuration.get(TD_AGENT_SOURCES, []))

        #Gets the config name for the source name given
        #hadoop map is different beacuse some source names coincide(temp solution)
        if "hadoop" in FILE_NAME:
            if SOURCE_NAME in SOURCE_TO_CONFIG_HADOOP_MAP.keys():
                CONFIG_FILE_NAME = SOURCE_TO_CONFIG_HADOOP_MAP[SOURCE_NAME]
                print(CONFIG_FILE_NAME)
            else:
                print("INVALID SOURCE NAME")
                print("Source name is incorrect please check Source name again")
                return
        else:
            if SOURCE_NAME in SOURCE_TO_CONFIG_MAP.keys():
                CONFIG_FILE_NAME = SOURCE_TO_CONFIG_MAP[SOURCE_NAME]
                print(CONFIG_FILE_NAME)
            else:
                print("INVALID SOURCE NAME")
                print("Source name is incorrect please check Source name again")
                return

        #Checks if config file name is present in this node or not
        if CONFIG_FILE_NAME not in td_source_confs:
            print("This node does not contain this source - {}".format(SOURCE_NAME))
            return
        
        #Command to disable/enable sources
        if ACTION=="enable":
            command = "bash {} {} {}".format(
                            ENABLE_SOURCES, SOURCE_NAME, FILE_NAME)
            process = subprocess.Popen(
                command.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
            print(output)
        else:
            command = "bash {} {} {}".format(
                            DISABLE_SOURCES, SOURCE_NAME, FILE_NAME)
            process = subprocess.Popen(
                command.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()
            print(output)

# Performing actions on tables and different source types
for TABLE in TABLES:
    if ":" in TABLE:
        TABLE = TABLE.split(":")
        SOURCES = TABLE[1].strip().split(" ")
        for SOURCE in SOURCES:
            source_function(SOURCE.strip())
        # print(TABLE[0].strip())
    else:
        # print(TABLE.strip())
        table_function(TABLE.strip())

# Restarting mdsd, td-agent, collectd services
def restart_pipeline():
    log_analytics_utilities.ensure_mdsd_restarted()
    log_analytics_utilities.restart_service("td-agent")
    log_analytics_utilities.restart_service("collectd")


restart_pipeline()
