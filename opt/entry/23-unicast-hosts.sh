#!/bin/bash

if [[ -z ${ES_UNICAST_HOSTS} ]];then
    UNICAST_HOSTS="127.0.0.1"
else
    UNICAST_HOSTS=$(echo ${ES_UNICAST_HOSTS} |sed -e 's/,/","/g')
fi
sed -i'' -e "s/[#]*discovery.zen.ping.unicast.hosts:.*/discovery.zen.ping.unicast.hosts: \[\"${UNICAST_HOSTS}\"\]/" /etc/elasticsearch/elasticsearch.yml
