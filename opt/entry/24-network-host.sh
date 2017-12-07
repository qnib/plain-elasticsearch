#!/bin/bash

ETH_ADDR=$(ip -o -4 addr |awk '/eth0.*(16|24)/{print $4}' |awk -F/ '{print $1}')
echo "  >> s/[#]*network.host:.*/network.host: \[_local_, \"${ETH_ADDR}\"\]/"
sed -i'' -e "s/[#]*network.host:.*/network.host: \[_local_, \"${ETH_ADDR}\"\]/" /etc/elasticsearch/elasticsearch.yml
