#!/bin/bash
set -x

sed -i'' -e "s/-Dlog4j2.disable.jmx=.*/-Dlog4j2.disable.jmx=${ES_LOG4J2_JMX:-false}/" /etc/elasticsearch/jvm.options
rm -f /usr/share/elasticsearch/config/jvm.options
cp /etc/elasticsearch/jvm.options /usr/share/elasticsearch/config/
