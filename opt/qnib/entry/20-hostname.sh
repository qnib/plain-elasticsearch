#!/bin/bash

if [[ -z ${ES_NODE_NAME} ]];then
  if [[ -f /etc/conf.d/hostname ]];then
      # The Gentoo way
      ES_NODE_NAME=$(cat /etc/conf.d/hostname |awk -F= '/hostname=/{print $2}' |tr -d '"')
  elif [[ -f /etc/hostname ]];then
      ES_NODE_NAME=$(cat /etc/hostname)
  else
      # should never be called, as /etc/hostname has to be present... (?)
      ES_NODE_NAME=$(hostname)
  fi
fi
echo ">> sed -i '' -e \"s/node.name: .*/node.name: ${ES_NODE_NAME}/\" /usr/share/elasticsearch/config/elasticsearch.yml"
sed -i'' -e "s/node.name:.*/node.name: ${ES_NODE_NAME}/" /usr/share/elasticsearch/config/elasticsearch.yml
