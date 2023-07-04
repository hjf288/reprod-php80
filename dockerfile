FROM php:8.2-fpm-buster

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y net-tools \
procps \
rsync \
wget \
libcurl4-openssl-dev \
libonig-dev \
openssl \
libssl-dev \
libc-dev \
libxml2-dev \
libzip-dev \
libpng-dev \
zlib1g-dev \
openssh-server \
nano \
software-properties-common \
ufw \
mariadb-client \
wget \
curl \
git \
zip \
nano \
jq \
msmtp \
vim \
ca-certificates \
lsb-release \
apt-transport-https \
gnupg \
bsdmainutils \
libedit-dev \
pv \
redis-tools \
logrotate \
tzdata \
screen

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && install-php-extensions \
apcu \
opcache \
pcntl

RUN mkdir -p /var/run/sshd

COPY configs/php7.ini /usr/local/etc/php/conf.d/
COPY configs/opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

RUN curl -L https://download.newrelic.com/php_agent/archive/10.11.0.3/newrelic-php5-10.11.0.3-linux.tar.gz| tar -C /tmp -zx && \
  export NR_INSTALL_USE_CP_NOT_LN=1 && \
  export NR_INSTALL_SILENT=1 && \
  /tmp/newrelic-php5-*/newrelic-install install && \
  rm -rf /tmp/newrelic-php5-* /tmp/nrinstall*

COPY configs/newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini

RUN curl -o blackfire-probe.deb https://packages.blackfire.io/debian/pool/any/main/b/blackfire-php/blackfire-php_1.88.1_amd64.deb \
  && dpkg -i blackfire-probe.deb \
  && rm blackfire-probe.deb; \
  curl -o blackfire.deb https://packages.blackfire.io/debian/pool/any/main/b/blackfire/blackfire_2.16.1_amd64.deb \
  && dpkg -i blackfire.deb \
  && rm blackfire.deb

RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/dadb501680566074a956f0a52f8e87a3612b0eae/web/installer -O - -q | php -- --quiet; \
  cp composer.phar /usr/local/bin/composer; \
  composer self-update --2;

COPY entrypoint.sh /usr/local/bin/
RUN ["chmod", "+x", "/usr/local/bin/entrypoint.sh"]
ENTRYPOINT ["/bin/bash", "-c", "/usr/local/bin/entrypoint.sh"]
