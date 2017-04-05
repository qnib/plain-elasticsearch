FROM qnib/alplain-openjre8


# ensure elastic user exists
RUN addgroup -S elastic && adduser -S -G elastic elastic

# grab su-exec for easy step-down from root
# and bash for "bin/elasticsearch" among others
RUN apk add --no-cache 'su-exec>=0.2' bash

# https://artifacts.elastic.co/GPG-KEY-elasticsearch
ENV GPG_KEY 46095ACC8548582C1A2699A9D27D666CD88E42B4

WORKDIR /usr/share/elasticsearch
ENV PATH /usr/share/elasticsearch/bin:$PATH

ENV ELASTICSEARCH_VERSION 5.3.0
ENV ELASTICSEARCH_TARBALL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.3.0.tar.gz" \
	ELASTICSEARCH_TARBALL_ASC="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.3.0.tar.gz.asc" \
	ELASTICSEARCH_TARBALL_SHA1="9273fdecb2251755887f1234d6cfcc91e44a384d"

RUN set -ex; \
	\
	apk add --no-cache --virtual .fetch-deps \
		ca-certificates \
		gnupg \
		openssl \
		tar \
	; \
	\
	wget -qO elasticsearch.tar.gz "$ELASTICSEARCH_TARBALL"; \
	\
	if [ "$ELASTICSEARCH_TARBALL_SHA1" ]; then \
		echo "$ELASTICSEARCH_TARBALL_SHA1 *elasticsearch.tar.gz" | sha1sum -c -; \
	fi; \
	\
	if [ "$ELASTICSEARCH_TARBALL_ASC" ]; then \
		wget -qO elasticsearch.tar.gz.asc "$ELASTICSEARCH_TARBALL_ASC"; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"; \
		gpg --batch --verify elasticsearch.tar.gz.asc elasticsearch.tar.gz; \
		rm -r "$GNUPGHOME" elasticsearch.tar.gz.asc; \
	fi; \
	\
	tar -xf elasticsearch.tar.gz --strip-components=1; \
	rm elasticsearch.tar.gz; \
	\
	apk del .fetch-deps; \
	\
	mkdir -p ./plugins; \
	for path in \
		./data \
		./logs \
		./config \
		./config/scripts \
	; do \
		mkdir -p "$path"; \
		chown -R elastic:elastic "$path"; \
	done; \
	\
# we shouldn't need much RAM to test --version (default is 2gb, which gets Jenkins in trouble sometimes)
	export ES_JAVA_OPTS='-Xms32m -Xmx32m'; \
	if [ "${ELASTICSEARCH_VERSION%%.*}" -gt 1 ]; then \
		elasticsearch --version; \
	else \
# elasticsearch 1.x doesn't support --version
# but in 5.x, "-v" is verbose (and "-V" is --version)
		elasticsearch -v; \
	fi
WORKDIR /

ENV ES_DATA_NODE=true \
    ES_MASTER_NODE=true \
    ES_NET_HOST=0.0.0.0 \
    ES_MLOCKALL=true \
    ENTRY_USER=elastic
RUN apk add --no-cache curl nmap jq vim sed
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
