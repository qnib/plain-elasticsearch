#!/bin/bash

if [[ -n ${ES_ZEN_HOSTS} ]];then
    echo "> Setup zen unicast hosts: discovery.zen.ping.unicast.hosts: ${ES_ZEN_HOSTS}"
    sed -i'' -e "s/[#]*discovery.zen.ping.unicast.hosts:.*/discovery.zen.ping.unicast.hosts: ${ES_ZEN_HOSTS}/" /usr/share/elasticsearch/config/elasticsearch.yml
fi
