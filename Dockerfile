# syntax = docker/dockerfile:1.0-experimental
FROM ubuntu:bionic

# Use the Sass/SCSS enabled variant by default
ARG HUGO_TYPE=_extended
ARG HUGO_VERSION=0.69.2
ARG HUGO_DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v$HUGO_VERSION/hugo"$HUGO_TYPE"_"$HUGO_VERSION"_Linux-64bit.tar.gz"
ARG MINIFY_DOWNLOAD_URL="https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz"
ARG BUILD_DATE
ARG VCS_REF

MAINTAINER Rainer Hermanns <rainerh@gmail.com>
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="MIT" \
    org.label-schema.name="Docker Hugo (extended) based on Ubuntu" \
    org.label-schema.url="https://github.com/rainerh/hugo-asciidoctor/" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/rainerh/hugo-asciidoctor.git" \
    org.label-schema.vcs-type="Git"

# Install development essentials
RUN apt-get clean && apt-get update && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        bash \
        imagemagick \
        ttf-dejavu \
        fonts-liberation2 \
        bash-completion \
        inotify-tools \
        gnupg \
        apt-transport-https \
        lsb-release \
        wget \
        ruby-full \
        git \
        ruby \
        ruby-dev \
        openjdk-11-jre \
        python3-all \
        python3-setuptools \
        python3-dev \
        python3-pip \
        libxml2 \
        libxml2-dev \
        libcairo2-dev \
        libreadline-dev \
        libpango-1.0-0 \
        libpango1.0-dev \
        libpangocairo-1.0-0 \
        libghc-pango-dev \
        libgdk-pixbuf2.0-dev \
        ruby-pango \
        tzdata \
        zlibc \
        make \
        cmake \
        build-essential \
        bison \
        flex \
        graphviz \
        plantuml

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt install -y nodejs \
    && npm install -g postcss-cli autoprefixer \
    && npm install -g yarn

# Setup user and group
ENV HUGO_USER=hugo \
    HUGO_UID=1000 \
    HUGO_GID=1000 \
    HUGO_HOME=/hugo

RUN addgroup --system --gid $HUGO_GID $HUGO_USER \
      && adduser --system  \
            --gid $HUGO_GID \
            --home $HUGO_HOME \
            --uid $HUGO_UID \
            $HUGO_USER

# Install HUGO
RUN mkdir -p ${HUGO_HOME} \
    && mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && curl -L "$HUGO_DOWNLOAD_URL" | tar -xz \
    && mv hugo /usr/local/bin/hugo \
    && curl -L "$MINIFY_DOWNLOAD_URL" | tar -xz \
    && mv minify /usr/local/bin/

RUN apt remove -y curl wget gnupg apt-transport-https lsb-release \
    && apt-get clean \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

USER $HUGO_USER

WORKDIR $HUGO_HOME

VOLUME ${HUGO_HOME}

ENV PATH=${HUGO_HOME}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD ["hugo","server","--bind","0.0.0.0"]
