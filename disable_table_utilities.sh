get_node_and_cluster_type() {

    #Setting node Type
    DOMAIN_NAME=$1
    if [[ ${DOMAIN_NAME::1} == "h" ]]
    then
        NODE_TYPE="head"
    elif [[ ${DOMAIN_NAME::1} == "z" ]]
    then
        NODE_TYPE="zookeeper"
    elif [[ ${DOMAIN_NAME::1} == "w" ]]
    then
        NODE_TYPE="worker"
    else
        NODE_TYPE="invalid node"; fi

    #Setting Clustertype
    if [[ $DOMAIN_NAME == *"spark"* ]]
    then
        CLUSTER_TYPE="spark"
    elif [[ $DOMAIN_NAME == *"inter"* ]]
    then
        CLUSTER_TYPE="interactivehive"
    elif [[ $DOMAIN_NAME == *"hadoop"* ]]
    then
        CLUSTER_TYPE="hadoop"   
    else
        CLUSTER_TYPE="hbase"; fi
}
