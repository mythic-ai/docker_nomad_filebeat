FROM frolvlad/alpine-glibc:alpine-3.7

WORKDIR /app

# install dumb-init, a simple process supervisor and init system
ENV DUMB_INIT_VERSION 1.2.1
RUN set -ex \
  && apk add --virtual build-tools --no-cache curl build-base bash \
  && curl -Lo dumb-init.tgz "https://github.com/Yelp/dumb-init/archive/v${DUMB_INIT_VERSION}.tar.gz" \
  && tar xzf dumb-init.tgz \
  && cd dumb-init-${DUMB_INIT_VERSION} \
  && make \
  && cp dumb-init /usr/bin \
  && cd .. \
  && rm -rf dumb-init*

ENV SIGIL_VERSION 0.4.0
RUN set -ex \
  && curl -Lo sigil.tgz "https://github.com/gliderlabs/sigil/releases/download/v${SIGIL_VERSION}/sigil_${SIGIL_VERSION}_Linux_x86_64.tgz" \
  && tar xzf sigil.tgz -C /usr/local/bin \
  && rm sigil.tgz

ENV FILEBEAT_VERSION=7.14.0
RUN set -ex \
  && curl -Lo filebeat.tgz "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz" \
  && tar xzf filebeat.tgz \
  && cp filebeat-*/filebeat /usr/local/bin \
  && cp filebeat-*/fields.yml ./ \
  && rm -rf filebeat* \
  && apk del --virtual build-tools

COPY run.sh filebeat.yml.tmpl get_device_ids.py ./
RUN apk add --update --no-cache python py-pip
RUN pip install requests
