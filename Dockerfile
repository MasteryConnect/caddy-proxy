#
# Builder
# https://github.com/abiosoft/caddy-docker/blob/master/Dockerfile
#
FROM abiosoft/caddy:builder as builder

ARG version="0.11.1"
ARG plugins="git,cors,realip,expires,cache"

RUN VERSION=${version} PLUGINS=${plugins} /bin/sh /usr/bin/builder.sh

#
# Docker Generator
# https://github.com/jwilder/docker-gen/blob/master/Dockerfile
#
FROM alpine:latest as generator
LABEL maintainer="Jason Wilder <mail@jasonwilder.com>"

RUN apk -U add openssl

ENV VERSION 0.7.4
ENV DOWNLOAD_URL https://github.com/jwilder/docker-gen/releases/download/$VERSION/docker-gen-alpine-linux-amd64-$VERSION.tar.gz
ENV DOCKER_HOST unix:///tmp/docker.sock

RUN mkdir /install
RUN wget -qO- $DOWNLOAD_URL | tar xvz -C /install

#
# Final stage
# Partially created from https://github.com/abiosoft/caddy-docker/blob/master/Dockerfile
#
FROM nimmis/alpine:latest
LABEL maintainer "Abiola Ibrahim <abiola89@gmail.com>"

ARG version="0.11.1"
LABEL caddy_version="$version"

RUN apk update && apk upgrade && \
    apk add --no-cache openssh-client git && \
    rm -rf /var/cache/apk/*

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# install docker generator
COPY --from=generator /install/docker-gen /usr/local/bin/docker-gen

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

# Let's Encrypt Agreement
ENV ACME_AGREE="true"
# Other caddy options
ENV CADDY_OPTIONS ""
ENV DOCKER_HOST unix:///tmp/docker.sock

RUN printf ":80\nproxy / caddyserver.com" > /etc/Caddyfile

ADD etc /etc

