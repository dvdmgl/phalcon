FROM ubuntu:14.04

RUN apt-get update && apt-get -y install \
  git \
  nginx-extras \
  php5-cli \
  php5-dev \
  php5-fpm \
  libpcre3-dev \
  gcc \
  make \
  curl \
  php5-curl \
  php5-pgsql \
  php5-redis

RUN git clone --depth=1 --branch phalcon-v2.0.8 http://github.com/phalcon/cphalcon.git cphalcon
RUN cd cphalcon/build && ./install;

RUN echo '[phalcon] extension = phalcon.so' >> /etc/php5/fpm/conf.d/50-phalcon.ini

RUN echo '[phalcon] extension = phalcon.so' >> /etc/php5/cli/conf.d/50-phalcon.ini

RUN curl -sS https://getcomposer.org/installer | php && \
  mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer && \
  composer global require 'phpunit/phpunit=3.7.*' && \
  echo "export PATH=$PATH:/.composer/vendor/bin/:" >> /root/.profile

ADD nginx.conf /etc/nginx/nginx.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

ADD default /etc/nginx/sites-available/default

RUN mkdir -p /var/www/app/public
RUN echo "<?php phpinfo(); ?>" > /var/www/index.php

WORKDIR /var/www/app/

EXPOSE  80

CMD service php5-fpm start && nginx