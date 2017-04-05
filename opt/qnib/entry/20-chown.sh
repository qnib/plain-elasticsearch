#!/bin/bash
set -x

chown -R ${ENTRY_USER}: /usr/share/elasticsearch/{data,logs}
