#!/bin/bash

if [[ "X${ES_UNICAST_HOSTS}" != "X" ]];then
    UNICAST_HOSTS=$(echo ${ES_UNICAST_HOSTS} |sed -e 's/,/","/g')
    sed -i'' -e "s/[#]*discovery.zen.ping.unicast.hosts:.*/discovery.zen.ping.unicast.hosts: \[\"${UNICAST_HOSTS}\"\]/" /usr/share/elasticsearch/config/elasticsearch.yml
fi
