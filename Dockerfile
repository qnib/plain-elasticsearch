FROM qnib/alplain-jre8

ARG ES_VER=2.3.5
ARG ES_URL=https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch
ENV ES_DATA_NODE=true \
    ES_MASTER_NODE=true \
    ES_HEAP_SIZE=512m \
    ES_NET_HOST=0.0.0.0 \
    ES_PATH_DATA=/opt/elasticsearch/data/ \
    ES_PATH_LOGS=/opt/elasticsearch/logs \
    ES_MLOCKALL=true
RUN apk add --update curl nmap jq vim \
 && curl -sL ${ES_URL}/${ES_VER}/elasticsearch-${ES_VER}.tar.gz |tar xfz - -C /opt/ \
 && mv /opt/elasticsearch-${ES_VER} /opt/elasticsearch \
 && rm -rf /var/cache/apk/* /tmp/* \
 && /opt/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf
VOLUME ["/opt/elasticsearch/logs", "/opt/elasticsearch/data/"]
RUN adduser -s /bin/bash -u 2000 -h /opt/elasticsearch -H -D elasticsearch \
 && echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/bin" >> /opt/elasticsearch/.bash_profile \
 && chown -R elasticsearch: /opt/elasticsearch 
ADD etc/consul-templates/elasticsearch/elasticsearch.yml.ctmpl \
    etc/consul-templates/elasticsearch/logging.yml.ctmpl \
    /etc/consul-templates/elasticsearch/
ADD opt/qnib/elasticsearch/bin/start.sh \
    opt/qnib/elasticsearch/bin/stop.sh \
    opt/qnib/elasticsearch/bin/register.sh \
    opt/qnib/elasticsearch/bin/healthcheck.sh \
    /opt/qnib/elasticsearch/bin/
ADD opt/qnib/elasticsearch/index-registration/settings/*.json /opt/qnib/elasticsearch/index-registration/settings/
ARG CT_VER=0.16.0
RUN curl -Lso /tmp/consul-template.zip https://releases.hashicorp.com/consul-template/${CT_VER}/consul-template_${CT_VER}_linux_amd64.zip \
 && cd /usr/local/bin/ \
 && unzip /tmp/consul-template.zip
HEALTHCHECK --interval=2s --retries=300 --timeout=1s \
 CMD /opt/qnib/elasticsearch/bin/healthcheck.sh
CMD ["/opt/qnib/elasticsearch/bin/start.sh"]
