#!/bin/bash
DISCOVERY_PATH=/usr/share/elasticsearch/config/discovery-file/
mkdir -p ${DISCOVERY_PATH}
rm -f ${DISCOVERY_PATH}/unicast_hosts.txt
touch  ${DISCOVERY_PATH}/unicast_hosts.txt
for HOST in $(echo ${ES_HOSTS} |sed -e 's/,/ /g');do
  echo ${HOST} >> ${DISCOVERY_PATH}/unicast_hosts.txt
done
