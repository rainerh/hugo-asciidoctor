FROM ubuntu:18.04 as builder

# Use the Sass/SCSS enabled variant by default
ARG HUGO_TYPE=_extended 
ARG HUGO_VERSION=0.64.1
ARG HUGO_DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v$HUGO_VERSION/hugo"$HUGO_TYPE"_"$HUGO_VERSION"_Linux-64bit.tar.gz"
ARG MINIFY_DOWNLOAD_URL="https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz"
ARG BUILD_DATE
ARG VCS_REF

ARG ASCIIDOCTOR_VERSION=2.0.10
ARG ASCIIDOCTOR_PDF_VERSION=1.5.0.beta.2

LABEL maintainer hermanns@aixcept.de
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="MIT" \
    org.label-schema.name="Docker Hugo based on Ubuntu" \
    org.label-schema.url="https://github.com/rainerh/hugo-ubuntu/" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/rainerh/hugo-ubuntu.git" \
    org.label-schema.vcs-type="Git"

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

# Install development essentials
RUN apt-get update && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        apt-transport-https \
        lsb-release \
        wget \
        ruby \
        git \
        ruby-dev \
        python3-all \
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
        zlibc \
        make \
        cmake \
        build-essential \
        bison \
        flex \
        graphviz \
        plantuml \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt install -y nodejs git \  
    && npm install -g postcss-cli autoprefixer \
    && npm install -g yarn 

FROM builder AS gem    

# Installing Ruby Gems needed in the image
# including asciidoctor itself
RUN gem install --no-document \
        rake \
        bundler \
        "asciidoctor:${ASCIIDOCTOR_VERSION}" \
        asciidoctor-confluence \
        asciidoctor-diagram \
        asciidoctor-epub3:1.5.0.alpha.9 \
        asciidoctor-bibtex \
        asciidoctor-mathematical \
        asciimath \
        "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}" \
        asciidoctor-revealjs \
        asciidoctor-html5s \
        coderay \
        epubcheck:3.0.1 \
        haml \
        kindlegen:3.0.3 \
        pygments.rb \
        rake \
        rouge \
        slim \
        thread_safe \
        tilt

FROM gem AS pip

# Installing Python dependencies for additional
# functionnalities as diagrams or syntax highligthing
RUN pip3 install --no-cache --upgrade pip setuptools wheel \
  && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
  && pip install --no-cache-dir \
    actdiag \
    'blockdiag[pdf]' \
    nwdiag \
    Pygments \
    seqdiag 

FROM pip AS hugo

# Install HUGO
RUN mkdir -p ${HUGO_HOME} \
    && mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && curl -L "$HUGO_DOWNLOAD_URL" | tar -xz \
    && mv hugo /usr/local/bin/hugo \
    && curl -L "$MINIFY_DOWNLOAD_URL" | tar -xz \
    && mv minify /usr/local/bin/ 

# Add preconfigured asciidoctor wrapper to include custom extensions
COPY asciidoctor /usr/local/sbin

RUN apt remove -y curl wget gnupg apt-transport-https lsb-release \
    && apt-get clean \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

USER $HUGO_USER

WORKDIR $HUGO_HOME

VOLUME ${HUGO_HOME}

CMD ["hugo","server","--bind","0.0.0.0"]
