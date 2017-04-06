#!/bin/bash

ES_NODE_MASTER=${ES_NODE_MASTER:-true}
ES_NODE_DATA=${ES_NODE_DATA:-true}
echo ">> Set node.master=${ES_NODE_MASTER} / node.data=${ES_NODE_DATA}"
sed -i'' -e "s/node.master:.*/node.master: ${ES_NODE_MASTER}/" /usr/share/elasticsearch/config/elasticsearch.yml
sed -i'' -e "s/node.data:.*/node.data: ${ES_NODE_DATA}/" /usr/share/elasticsearch/config/elasticsearch.yml
