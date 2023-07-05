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

## BLackfire
RUN curl -o blackfire-probe.deb https://packages.blackfire.io/debian/pool/any/main/b/blackfire-php/blackfire-php_1.88.1_amd64.deb \
  && dpkg -i blackfire-probe.deb \
  && rm blackfire-probe.deb; \
  curl -o blackfire.deb https://packages.blackfire.io/debian/pool/any/main/b/blackfire/blackfire_2.16.1_amd64.deb \
  && dpkg -i blackfire.deb \
  && rm blackfire.deb

## Sourceguardian

RUN PHP_VERSION=$(php -v | head -n1 | cut -d' ' -f2 | cut -d. -f1-2) \
    && mkdir -p /tmp/sourceguardian \
    && cd /tmp/sourceguardian \
    && curl -Os https://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz \
    && tar xzf loaders.linux-x86_64.tar.gz \
    && cp ixed.${PHP_VERSION}.lin "$(php -i | grep '^extension_dir =' | cut -d' ' -f3)/sourceguardian.so" \
    && echo "extension=sourceguardian.so" > /usr/local/etc/php/conf.d/15-sourceguardian.ini \
    && rm -rf /tmp/sourceguardian

RUN export TZ='Europe/London'; wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -d 'opcache.enable_cli=0' -- --quiet; \
  cp composer.phar /usr/local/bin/composer1; \
  wget https://raw.githubusercontent.com/composer/getcomposer.org/dadb501680566074a956f0a52f8e87a3612b0eae/web/installer -O - -q | php -d 'opcache.enable_cli=0' -- --quiet; \
  cp composer.phar /usr/local/bin/composer2; \
  update-alternatives --install /usr/bin/composer composer /usr/local/bin/composer1 10; \
  update-alternatives --install /usr/bin/composer composer /usr/local/bin/composer2 10; \
  /usr/local/bin/composer1 self-update --1; \
  /usr/local/bin/composer2 self-update --2;

COPY entrypoint.sh /usr/local/bin/
RUN ["chmod", "+x", "/usr/local/bin/entrypoint.sh"]
ENTRYPOINT ["/bin/bash", "-c", "/usr/local/bin/entrypoint.sh"]
