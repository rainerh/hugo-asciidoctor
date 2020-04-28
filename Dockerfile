# syntax = docker/dockerfile:1.0-experimental
FROM ubuntu:bionic

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


# Installing Ruby Gems needed in the image
# including asciidoctor itself

ENV ASCIIDOCTOR_VERSION=${asciidoctor_version} \
  ASCIIDOCTOR_CONFLUENCE_VERSION=${asciidoctor_confluence_version} \
  ASCIIDOCTOR_PDF_VERSION=${asciidoctor_pdf_version} \
  ASCIIDOCTOR_DIAGRAM_VERSION=${asciidoctor_diagram_version} \
  ASCIIDOCTOR_EPUB3_VERSION=${asciidoctor_epub3_version} \
  ASCIIDOCTOR_MATHEMATICAL_VERSION=${asciidoctor_mathematical_version} \
  ASCIIDOCTOR_REVEALJS_VERSION=${asciidoctor_revealjs_version} \
  KRAMDOWN_ASCIIDOC_VERSION=${kramdown_asciidoc_version}

RUN gem install --no-document \
        rake \
        bundler \
        "asciidoctor:${ASCIIDOCTOR_VERSION}" \
        "asciidoctor-confluence:${ASCIIDOCTOR_CONFLUENCE_VERSION}" \
        "asciidoctor-diagram:${ASCIIDOCTOR_DIAGRAM_VERSION}" \
        "asciidoctor-epub3:${ASCIIDOCTOR_EPUB3_VERSION}" \
        "asciidoctor-mathematical:${ASCIIDOCTOR_MATHEMATICAL_VERSION}" \
        asciimath \
        "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}" \
        "asciidoctor-revealjs:${ASCIIDOCTOR_REVEALJS_VERSION}" \
        pygments.rb \
        rouge \
        coderay \
        epubcheck-ruby:4.2.2.0 \
        haml \
        "kramdown-asciidoc:${KRAMDOWN_ASCIIDOC_VERSION}" \
        rouge \
        slim \
        thread_safe \
        tilt

RUN gem install --no-document --backtrace --verbose --debug \
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
