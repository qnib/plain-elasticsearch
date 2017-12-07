#!/bin/bash

ES_NODE_MASTER=${ES_NODE_MASTER:-true}
ES_NODE_DATA=${ES_NODE_DATA:-true}
echo ">> Set node.master=${ES_NODE_MASTER} / node.data=${ES_NODE_DATA}"
sed -i'' -e "s/node.master:.*/node.master: ${ES_NODE_MASTER}/" /etc/elasticsearch/elasticsearch.yml
sed -i'' -e "s/node.data:.*/node.data: ${ES_NODE_DATA}/" /etc/elasticsearch/elasticsearch.yml
