#!/bin/bash
set -x

sed -i'' -e "s/[#]*-Xms.*/-Xms${ES_HEAP_MIN:-2g}/" /etc/elasticsearch/jvm.options
sed -i'' -e "s/[#]*-Xmx.*/-Xmx${ES_HEAP_MAX:-2g}/" /etc/elasticsearch/jvm.options
sed -i'' -e "s/-Dlog4j2.disable.jmx=.*/-Dlog4j2.disable.jmx=${ES_LOG4J2_JMX:-false}/" /etc/elasticsearch/jvm.options
