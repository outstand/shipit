FROM outstand/fixuid as fixuid

FROM ruby:2.7.3-alpine
LABEL maintainer="Ryan Schlesinger <ryan@outstand.com>"

RUN addgroup -S shipitron && \
    adduser -S -G shipitron shipitron && \
    addgroup -g 1101 docker && \
    addgroup shipitron docker

RUN apk add --no-cache \
    ca-certificates \
    openssl-dev \
    tini \
    su-exec \
    build-base \
    git \
    git-lfs \
    openssh-client \
    perl \
    bash \
    curl \
    wget \
    jq \
    cmake

COPY --from=fixuid /usr/local/bin/fixuid /usr/local/bin/fixuid
RUN chmod 4755 /usr/local/bin/fixuid && \
      USER=shipitron && \
      GROUP=shipitron && \
      mkdir -p /etc/fixuid && \
      printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

ENV ECR_CREDENTIAL_HELPER_VERSION 0.5.0
RUN cd /usr/local/bin && \
      wget https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/${ECR_CREDENTIAL_HELPER_VERSION}/linux-amd64/docker-credential-ecr-login && \
      chmod +x docker-credential-ecr-login

ENV BUILDKIT_VERSION v0.8.3
RUN cd /usr/local/bin && \
      wget -nv https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION}.linux-amd64.tar.gz && \
      tar --strip-components=1 -zxvf buildkit-${BUILDKIT_VERSION}.linux-amd64.tar.gz bin/buildctl && \
      chmod +x buildctl && \
      rm -f buildkit-${BUILDKIT_VERSION}.linux-amd64.tar.gz

USER shipitron
ENV BUILDX_VERSION v0.5.1
RUN cd /home/shipitron && \
      wget -nv https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64 && \
      mkdir -p ~/.docker/cli-plugins && \
      mv buildx-${BUILDX_VERSION}.linux-amd64 ~/.docker/cli-plugins/docker-buildx && \
      chmod a+x ~/.docker/cli-plugins/docker-buildx

USER root
ENV USE_BUNDLE_EXEC true
ENV BUNDLE_GEMFILE /shipitron/Gemfile

ENV BUNDLER_VERSION 2.2.21
RUN gem install bundler -v ${BUNDLER_VERSION} -i /usr/local/lib/ruby/gems/$(ls /usr/local/lib/ruby/gems) --force

WORKDIR /app
COPY Gemfile shipitron.gemspec /shipitron/
COPY lib/shipitron/version.rb /shipitron/lib/shipitron/

RUN git config --global push.default simple
COPY . /shipitron/
RUN mkdir -p /home/shipitron/.ssh && \
    chown shipitron:shipitron /home/shipitron/.ssh && \
    chmod 700 /home/shipitron/.ssh

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["help"]
