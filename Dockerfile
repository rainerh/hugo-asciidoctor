FROM ubuntu:18.04

ARG HUGO_VERSION=0.64.1
ENV DOCUMENT_DIR=/hugo-project

RUN apt-get update && apt-get upgrade -y \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
           ruby ruby-dev make cmake build-essential bison flex graphviz plantuml \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && rm -rf /tmp/*
RUN gem install --no-document asciidoctor asciidoctor-revealjs \
         rouge asciidoctor-bibtex asciidoctor-confluence asciidoctor-diagram asciidoctor-rouge coderay pygments.rb

ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp/hugo.tgz

RUN cd /usr/local/bin && tar -xzf /tmp/hugo.tgz && rm /tmp/hugo.tgz

# Add preconfigured asciidoctor wrapper to include custom extensions
COPY asciidoctor /usr/local/sbin

RUN mkdir ${DOCUMENT_DIR}
WORKDIR ${DOCUMENT_DIR}

VOLUME ${DOCUMENT_DIR}

CMD ["hugo","server","--bind","0.0.0.0"]
