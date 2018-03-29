FROM ruby:2.5.0-alpine3.7 as cache
COPY cache/ /tmp/
RUN   cd /usr/local/bundle && \
    ([ -f /tmp/bundler-data.tar.gz ] && \
    tar -zxf /tmp/bundler-data.tar.gz && \
    rm /tmp/bundler-data.tar.gz) || true

FROM ruby:2.5.0-alpine3.7
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

RUN addgroup -S shipitron && \
    adduser -S -G shipitron shipitron && \
    addgroup -g 1101 docker && \
    addgroup shipitron docker

ENV GOSU_VERSION 1.10
ENV DUMB_INIT_VERSION 1.2.0

RUN apk add --no-cache ca-certificates openssl tini su-exec

RUN apk add --no-cache \
    build-base \
    git \
    openssh-client \
    perl \
    bash \
    curl \
    wget \
    jq

ENV USE_BUNDLE_EXEC true
ENV BUNDLE_GEMFILE /shipitron/Gemfile

WORKDIR /app
COPY Gemfile shipitron.gemspec /shipitron/
COPY lib/shipitron/version.rb /shipitron/lib/shipitron/

COPY --from=cache /usr/local/bundle /usr/local/bundle
RUN (bundle check || bundle install) && \
      git config --global push.default simple
COPY . /shipitron/
RUN ln -s /shipitron/exe/shipitron /usr/local/bin/shipitron && \
    mkdir -p /home/shipitron/.ssh && \
    chown shipitron:shipitron /home/shipitron/.ssh && \
    chmod 700 /home/shipitron/.ssh

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["help"]
