#!/bin/bash

cat /opt/qnib/elasticsearch/etc/elasticsearch.yml \
    | sed -e "s;[#]*node.name:*;node.name: ${ES_NODE_NAME};" \
    | sed -e "s;[#]*cluster.name:*;cluster.name: ${ES_CLUSTER_NAME};" \
    > /usr/share/elasticsearch/config/elasticsearch.yml
