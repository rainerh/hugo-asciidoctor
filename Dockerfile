FROM ubuntu:18.04

# Use the Sass/SCSS enabled variant by default
ARG HUGO_TYPE=_extended 
ARG HUGO_VERSION=0.64.1
ARG HUGO_DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v$HUGO_VERSION/hugo"$HUGO_TYPE"_"$HUGO_VERSION"_Linux-64bit.tar.gz"
ARG MINIFY_DOWNLOAD_URL="https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz"
ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer hermanns@aixcept.de
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="MIT" \
    org.label-schema.name="Docker Hugo based on Ubuntu" \
    org.label-schema.url="https://github.com/rainerh/hugo-ubuntu/" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/rainerh/hugo-ubuntu.git" \
    org.label-schema.vcs-type="Git"

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

RUN apt-get update && apt-get upgrade -y \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
           curl \
           ruby \
           ruby-dev \
           make \
           cmake \
           build-essential \
           bison \
           flex \
           graphviz \
           plantuml \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && rm -rf /tmp/*

RUN mkdir -p ${HUGO_HOME} \
    && mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && curl -L "$HUGO_DOWNLOAD_URL" | tar -xz \
    && mv hugo /usr/local/bin/hugo \
    && curl -L "$MINIFY_DOWNLOAD_URL" | tar -xz \
    && mv minify /usr/local/bin/ \
    && gem install --no-document asciidoctor \
            asciidoctor-revealjs \
            rouge \
            asciidoctor-bibtex \
            asciidoctor-confluence \
            asciidoctor-diagram \
            coderay \
            pygments.rb

# Add preconfigured asciidoctor wrapper to include custom extensions
COPY asciidoctor /usr/local/sbin

USER $HUGO_USER

WORKDIR $HUGO_HOME

VOLUME ${HUGO_HOME}

CMD ["hugo","server","--bind","0.0.0.0"]
