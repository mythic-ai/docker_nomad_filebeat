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

ENV FILEBEAT_VERSION=6.2.4
ENV FILEBEAT_SHA512=19d0a93a42a758b8c9e71ca2691130fe5998fcb717019e29864f6ce0a21d4880c1654581220f0ce0f6118c914629df2baa91e95728f4e6a333666dffdf04df20
RUN set -ex \
  && curl -Lo filebeat.tgz "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz" \
  && echo "${FILEBEAT_SHA512}  filebeat.tgz" | sha512sum -c - \
  && tar xzf filebeat.tgz \
  && cp filebeat-*/filebeat /usr/local/bin \
  && cp filebeat-*/fields.yml ./ \
  && rm -rf filebeat* \
  && apk del --virtual build-tools

COPY run.sh filebeat.yml.tmpl ./

ENTRYPOINT ["./run.sh"]
CMD ["filebeat", "-e"]
