FROM alpine:3.12
MAINTAINER Luc Michalski <lmichalski@evolutive-business.com>

ARG PERCONA_TOOLKIT_VERSION=${PERCONA_TOOLKIT_VERSION:-"3.2.1"}
ARG MYDUMPER_TAG=${MYDUMPER_TAG:-"v0.9.5"}

ENV PERCONA_TOOLKIT_VERSION=${PERCONA_TOOLKIT_VERSION:-"3.2.1"} \
    MYDUMPER_TAG=${MYDUMPER_TAG:-"v0.9.5"} \
    BUILD_PATH="/opt/mydumper-src/" \
    BUILD_PACKAGES="make cmake build-base git"

RUN set -x \
  && apk add --update --no-progress \
      perl \
      perl-doc \
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
  \
  && update-ca-certificates \
  \
  && wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl -O /usr/bin/mysqltuner \
  && wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt -O /usr/bin/basic_passwords.txt \
  && wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/vulnerabilities.csv -O /usr/bin/vulnerabilities.csv \
  && chmod +x /usr/bin/mysqltuner \
  \
  && wget -O /tmp/percona-toolkit.tar.gz https://www.percona.com/downloads/percona-toolkit/${PERCONA_TOOLKIT_VERSION}/source/tarball/percona-toolkit-${PERCONA_TOOLKIT_VERSION}.tar.gz \
  && tar -xzvf /tmp/percona-toolkit.tar.gz -C /tmp \
  && cd /tmp/percona-toolkit-${PERCONA_TOOLKIT_VERSION} \
  && perl Makefile.PL \
  && make \
  && make test \
  && make install \
  \
  && git clone --depth=1 https://github.com/maxbube/mydumper.git $BUILD_PATH \
  && cd $BUILD_PATH \
  && cmake -DWITH_SSL=OFF . \
  && make \
  && mv ./mydumper /usr/bin/. \
  && mv ./myloader /usr/bin/. \
  \
  && cd / && rm -rf $BUILD_PATH \
  && apk del ca-certificates wget $BUILD_PACKAGES \ 
  && rm -f /usr/lib/*.a \
  && rm -rf /var/cache/apk/* /tmp/percona-toolkit*

CMD ["/bin/bash"]
