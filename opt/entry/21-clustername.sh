#!/bin/bash

if [[ -z ${ES_CLUSTER_NAME} ]];then
  export ES_CLUSTER_NAME=${SWARM_SERVICE_NAME:-default}
fi

echo ">> sed -i '' -e \"s/cluster.name: .*/cluster.name: ${ES_CLUSTER_NAME}/\" /etc/elasticsearch/elasticsearch.yml"
sed -i'' -e "s/cluster.name:.*/cluster.name: ${ES_CLUSTER_NAME}/" /etc/elasticsearch/elasticsearch.yml
