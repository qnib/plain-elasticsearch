#!/bin/bash

PUBLISH_IFACE=${ES_PUBLISH_IFACE:-eth0}
ETH_ADDR=$(ip -o -4 addr |grep ${PUBLISH_IFACE} |awk '/eth.*(16|24)/{print $4}' |awk -F/ '{print $1}')
echo "  >> s/[#]*network.publish_host:.*/network.publish_host: ${ETH_ADDR}/"
sed -i'' -e "s/[#]*network.publish_host:.*/network.publish_host: ${ETH_ADDR}/" /usr/share/elasticsearch/config/elasticsearch.yml
