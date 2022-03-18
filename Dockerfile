FROM ubuntu:20.04
RUN apt-get update 
RUN apt -y install curl wget python3 python3-pip
RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.14.0-amd64.deb
RUN  dpkg -i filebeat-7.14.0-amd64.deb
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_amd64.deb
RUN dpkg -i dumb-init_*.deb
ENV SIGIL_VERSION 0.4.0
RUN set -ex \
  && curl -Lo sigil.tgz "https://github.com/gliderlabs/sigil/releases/download/v${SIGIL_VERSION}/sigil_${SIGIL_VERSION}_Linux_x86_64.tgz" \
  && tar xzf sigil.tgz -C /usr/local/bin \
  && rm sigil.tgz
WORKDIR /app
COPY filebeat.yml.tmpl /app
COPY FilebeatManager.py /app
