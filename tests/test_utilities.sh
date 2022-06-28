#Testing the utilities function

#Importing the uitilites function
. ../disable_table_utilities.sh

#Declaring test cases
DOMAIN_NAMES=("hn0-hadoop" "wn0-hadoop" "zk2-hadoop" "hn0-intera" "wn0-intera" "zk0-intera" "hn0-hbase1" "wn1-hbase1" "zk1-hbase1")
CLUSTER_TYPES=("hadoop" "hadoop" "hadoop" "interactivehive" "interactivehive" "interactivehive" "hbase" "hbase" "hbase")
NODE_TYPES=("head" "worker" "zookeeper" "head" "worker" "zookeeper" "head" "worker" "zookeeper")



for i in ${!DOMAIN_NAMES[@]}; do
    get_node_and_cluster_type ${DOMAIN_NAMES[$i]}

    #Checks the cluster type
    if [[ $CLUSTER_TYPE == "${CLUSTER_TYPES[$i]}" ]]
        then
        echo "$(tput setaf 2)PASS Cluster type correct for ${DOMAIN_NAMES[$i]}"
    else
        echo "$(tput setaf 1)FAIL Cluster Type incorrect for ${DOMAIN_NAMES[$i]}"
    fi

    #Checks the node type
    if [[ $NODE_TYPE == "${NODE_TYPES[$i]}" ]]
        then
        echo "$(tput setaf 2)PASS Node Type correct for ${DOMAIN_NAMES[$i]}"
    else
        echo "$(tput setaf 1)FAIL Node Type incorrect for ${DOMAIN_NAMES[$i]}"
    fi
    done