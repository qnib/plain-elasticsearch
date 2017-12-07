#!/bin/bash
set -x

chown -R ${ENTRY_USER}: /var/lib/elasticsearch
chown -R ${ENTRY_USER}: /var/log/elasticsearch
