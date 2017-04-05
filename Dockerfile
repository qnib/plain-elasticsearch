FROM qnib/dplain-openjdk8


# ensure elastic user exists
RUN groupadd elastic \
 && useradd -g elastic elastic


RUN set -ex; \
# https://artifacts.elastic.co/GPG-KEY-elasticsearch
	key='46095ACC8548582C1A2699A9D27D666CD88E42B4'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/elastic.gpg; \
	rm -r "$GNUPGHOME"; \
	apt-key list

# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html
# https://www.elastic.co/guide/en/elasticsearch/reference/5.0/deb.html
RUN set -x \
 && apt-get update \
 && apt-get install -y curl nmap jq vim sed \
 && apt-get install -y --no-install-recommends apt-transport-https && rm -rf /var/lib/apt/lists/* \
 && echo 'deb https://artifacts.elastic.co/packages/5.x/apt stable main' > /etc/apt/sources.list.d/elasticsearch.list

ENV ELASTICSEARCH_VERSION 5.3.0
ENV ELASTICSEARCH_DEB_VERSION 5.3.0

RUN set -x \
	\
# don't allow the package to install its sysctl file (causes the install to fail)
# Failed to write '262144' to '/proc/sys/vm/max_map_count': Read-only file system
	&& dpkg-divert --rename /usr/lib/sysctl.d/elasticsearch.conf \
	\
	&& apt-get update \
	&& apt-get install -y --no-install-recommends "elasticsearch=$ELASTICSEARCH_DEB_VERSION" \
	&& rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/elasticsearch/bin:$PATH

WORKDIR /usr/share/elasticsearch

RUN set -ex \
	&& for path in \
		./data \
		./logs \
		./config \
		./config/scripts \
	; do \
		mkdir -p "$path"; \
		chown -R elasticsearch:elasticsearch "$path"; \
	done

WORKDIR /

ENV ES_DATA_NODE=true \
    ES_MASTER_NODE=true \
    ES_NET_HOST=0.0.0.0 \
    ES_MLOCKALL=true
COPY opt/qnib/elasticsearch/index-registration/settings/*.json /opt/qnib/elasticsearch/index-registration/settings/
HEALTHCHECK --interval=2s --retries=300 --timeout=1s \
  CMD /opt/qnib/elasticsearch/bin/healthcheck.sh
CMD ["elasticsearch"]
VOLUME ["/usr/share/elasticsearch/logs", "/usr/share/elasticsearch/data/"]
COPY opt/qnib/entry/* /opt/qnib/entry/
COPY opt/qnib/elasticsearch/bin/* \
     /opt/qnib/elasticsearch/bin/
COPY opt/qnib/elasticsearch/etc/elasticsearch.yml \
     /opt/qnib/elasticsearch/etc/elasticsearch.yml
#ENV ENTRY_USER=elastic
