#!/bin/bash

ES_MASTER=${ES_MASTER:-true}
ES_DATA=${ES_DATA:-true}

echo "> Setup master=${ES_MASTER} / data:${ES_DATA} configuration for node"
sed -i'' -e "s/[#]*node.master:.*/node.master: ${ES_MASTER:-true}/" /usr/share/elasticsearch/config/elasticsearch.yml
sed -i'' -e "s/[#]*node.data:.*/node.data: ${ES_DATA:-true}/" /usr/share/elasticsearch/config/elasticsearch.yml

