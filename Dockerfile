FROM qnib/alplain-jdk8


# ensure elasticsearch user exists
RUN adduser -D -g elasticsearch elasticsearch

ENV ELASTICSEARCH_VERSION 1.7.6
ENV ELASTICSEARCH_TARBALL="https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.6.tar.gz" \
    ELASTICSEARCH_TARBALL_ASC="" \
    ELASTICSEARCH_TARBALL_SHA1="0b6ec9fe34b29e6adc4d8481630bf1f69cb04aa9"
RUN set -ex; \
	\
	apk add --no-cache --virtual .fetch-deps \
		ca-certificates \
		gnupg \
		openssl \
		tar \
	; \
	\
	wget -O elasticsearch.tar.gz "$ELASTICSEARCH_TARBALL"; \
	\
	if [ "$ELASTICSEARCH_TARBALL_SHA1" ]; then \
		echo "$ELASTICSEARCH_TARBALL_SHA1 *elasticsearch.tar.gz" | sha1sum -c -; \
	fi; \
	\
	if [ "$ELASTICSEARCH_TARBALL_ASC" ]; then \
		wget -O elasticsearch.tar.gz.asc "$ELASTICSEARCH_TARBALL_ASC"; \
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
		chown -R elasticsearch:elasticsearch "$path"; \
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
RUN apk --no-cache add wget \
 && wget -qO /usr/local/bin/go-elastic-health https://github.com/qnib/go-elastic-health/releases/download/v1.0.0/go-elastic-health_Linux \
 && chmod +x /usr/local/bin/go-elastic-health
ENV ES_DATA=true \
    ES_MASTER=true \
    ES_NET_HOST=0.0.0.0 \
    ES_MLOCKALL=true \
    ES_HEAP_MAX=256m \
    ES_HEAP_MIN=256m \
    ENTRY_USER=elasticsearch
COPY opt/qnib/elasticsearch/index-registration/settings/*.json /opt/qnib/elasticsearch/index-registration/settings/
COPY wait.sh /usr/local/bin/
HEALTHCHECK --interval=2s --retries=300 --timeout=1s \
  CMD /usr/local/bin/go-elastic-health
CMD ["elasticsearch"]
VOLUME ["/usr/share/elasticsearch/logs", "/usr/share/elasticsearch/data/"]
COPY opt/qnib/elasticsearch/bin/* /opt/qnib/elasticsearch/bin/
COPY opt/qnib/entry/* /opt/qnib/entry/
COPY usr/share/elasticsearch/config/elasticsearch.yml \
     usr/share/elasticsearch/config/log4j2.properties \
     /usr/share/elasticsearch/config/
RUN echo "gosu elasticsearch elasticsearch" >> /root/.bash_history
