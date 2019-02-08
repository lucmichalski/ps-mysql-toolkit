FROM alpine:3.8
MAINTAINER Chad Jones<cj@patientsky.com.com>

ENV PERCONA_TOOLKIT_VERSION="3.0.13" \
    BUILD_PATH="/opt/mydumper-src/" \
    BUILD_PACKAGES="make cmake build-base git" \
    MYDUMPER_TAG="v0.9.5 "

RUN set -x \
  && apk add --update \
      perl \
      perl-dbi \
      perl-dbd-mysql \
      perl-io-socket-ssl \
      perl-term-readkey \
      ca-certificates \
      wget \
      glib-dev \
      zlib-dev \
      pcre-dev \
      libressl-dev \
      mariadb-connector-c-dev \
      mariadb-connector-c \
      bash \
      $BUILD_PACKAGES \
  && update-ca-certificates \
  && wget -O /tmp/percona-toolkit.tar.gz https://www.percona.com/downloads/percona-toolkit/${PERCONA_TOOLKIT_VERSION}/source/tarball/percona-toolkit-${PERCONA_TOOLKIT_VERSION}.tar.gz \
  && tar -xzvf /tmp/percona-toolkit.tar.gz -C /tmp \
  && cd /tmp/percona-toolkit-${PERCONA_TOOLKIT_VERSION} \
  && perl Makefile.PL \
  && make \
  && make test \
  && make install \
  && git clone https://github.com/maxbube/mydumper.git $BUILD_PATH \
  && cd $BUILD_PATH \
  && git checkout tags/$MYDUMPER_TAG \
  && cmake . \
  && make \
  && mv ./mydumper /usr/bin/. \
  && mv ./myloader /usr/bin/. \
  && cd / && rm -rf $BUILD_PATH \
  && apk del ca-certificates wget $BUILD_PACKAGES \ 
  && rm -f /usr/lib/*.a \
  && rm -rf /var/cache/apk/* /tmp/percona-toolkit*

CMD ["/bin/bash"]