# syntax = docker/dockerfile:1.0-experimental
FROM ubuntu:bionic-20200403

# Use the Sass/SCSS enabled variant by default
ARG HUGO_TYPE=_extended
ARG HUGO_VERSION=0.69.2
ARG HUGO_DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v$HUGO_VERSION/hugo"$HUGO_TYPE"_"$HUGO_VERSION"_Linux-64bit.tar.gz"
ARG MINIFY_DOWNLOAD_URL="https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz"

ARG asciidoctor_version=2.0.10
ARG asciidoctor_confluence_version=0.0.2
ARG asciidoctor_pdf_version=1.5.2
ARG asciidoctor_diagram_version=2.0.1
ARG asciidoctor_epub3_version=1.5.0.alpha.13
ARG asciidoctor_mathematical_version=0.3.1
ARG asciidoctor_revealjs_version=4.0.1
ARG kramdown_asciidoc_version=1.0.1

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
RUN apt-get clean \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-transport-https \
        bash \
        bash-completion \
        bison \
        build-essential \
        curl \
        cmake \
        flex \
        fonts-liberation2 \
        git \
        gnupg \
        graphviz \
        imagemagick \
        inotify-tools \
        libreadline-dev \
        libcairo2-dev \
        libghc-pango-dev \
        libgdk-pixbuf2.0-dev \
        libpango-1.0-0 \
        libpango1.0-dev \
        libpangocairo-1.0-0 \
        libxml2 \
        libxml2-dev \
        lsb-release \
        make \
        ttf-dejavu \
        openjdk-11-jre \
        plantuml \
        python3-all \
        python3-setuptools \
        python3-dev \
        python3-pip \
        ruby \
        ruby-dev \
        ruby-pango \
        tzdata \
        wget \
        zlibc

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get update \
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

# Installing Ruby Gems needed in the image
# including asciidoctor itself
RUN gem install --no-document \
        rake \
        bundler \
        "asciidoctor:${asciidoctor_version}" \
        "asciidoctor-confluence:${asciidoctor_confluence_version}" \
        "asciidoctor-diagram:${asciidoctor_diagram_version}" \
        "asciidoctor-epub3:${asciidoctor_epub3_version}" \
        "asciidoctor-mathematical:${asciidoctor_mathematical_version}" \
        asciimath \
        "asciidoctor-pdf:${asciidoctor_pdf_version}" \
        "asciidoctor-revealjs:${asciidoctor_revealjs_version}" \
        pygments.rb \
        rouge \
        coderay \
        epubcheck-ruby:4.2.2.0 \
        haml \
        "kramdown-asciidoc:${kramdown_asciidoc_version}" \
        rouge \
        slim \
        thread_safe \
        tilt \
        kindlegen:3.0.4

# Installing Python dependencies for additional
# functionalities as diagrams or syntax highligthing
RUN pip3 install --no-cache --upgrade pip setuptools wheel \
  && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
  && pip install --no-cache-dir \
    actdiag \
    'blockdiag[pdf]' \
    nwdiag \
    Pygments \
    seqdiag

# Add preconfigured asciidoctor wrapper to include custom extensions
COPY asciidoctor /usr/local/sbin

# Install HUGO
RUN mkdir -p ${HUGO_HOME} \
    && mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && curl -L "$HUGO_DOWNLOAD_URL" | tar -xz \
    && mv hugo /usr/local/bin/hugo \
    && curl -L "$MINIFY_DOWNLOAD_URL" | tar -xz \
    && mv minify /usr/local/bin/

# Cleanup
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
