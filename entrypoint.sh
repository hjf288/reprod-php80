#!/bin/bash
set -e

mkdir -p "/home/web/.ssh" && touch "/home/web/.ssh/authorized_keys"

if [ -f /tmp/php/php.ini ]; then
  cp /tmp/php/php.ini /usr/local/etc/php/conf.d/php7.ini
fi

/usr/sbin/sshd -D -e
