#!/bin/bash

function loop_wait {
  while [ true ];do
    /usr/local/bin/go-elastic-health --host ${ES_UNICAST_HOSTS}
    if [[ $? == 0 ]];then
      exit 0
    else
      sleep 1
      loop_wait
    fi
  done
}

if [[ -n ${ES_UNICAST_HOSTS} ]];then
  echo "  >> ES_UNICAST_HOSTS is set '${ES_UNICAST_HOSTS}. Waiting until master is up..."
  loop_wait
fi
