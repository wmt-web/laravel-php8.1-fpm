# Using base ubuntu image
FROM ubuntu:20.04

LABEL Maintainer="Harsh Solanki <harshsolanki7116@gmail.com>" \
      Description="Nginx + PHP8.1-FPM Based on Ubuntu 20.04."

# Setup document root
RUN mkdir -p /var/www/


# Base install
RUN apt update --fix-missing
RUN  DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && echo Asia/Kolkata > /etc/timezone
RUN apt install -y \
      software-properties-common \
      git \
      zip \
      unzip \
      curl \
      ca-certificates \
      lsb-release \
      libicu-dev \
      supervisor \
      nginx \
      nano

# Install php8.1-fpm
# Since the repo is supported on ubuntu 20
RUN add-apt-repository ppa:ondrej/php
RUN apt update -y
RUN apt install -y \
      php8.1-fpm \
      php8.1-pdo \
      php8.1-mysql \
      php8.1-zip \
      php8.1-gd \
      php8.1-mbstring \
      php8.1-curl \
      php8.1-xml \
      php8.1-bcmath \
      php8.1-intl

# Install composer
COPY --from=composer:2.5.4 /usr/bin/composer /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="./vendor/bin:$PATH"
RUN composer --help

RUN rm /etc/nginx/sites-enabled/default

COPY php.ini /etc/php/8.1/fpm/php.ini
COPY www.conf /etc/php/8.1/fpm/pool.d/www.conf
COPY default.conf /etc/nginx/conf.d/
COPY supervisord.conf /etc/supervisor/conf.d/

# # Prevent exit
ENTRYPOINT ["/usr/bin/supervisord"]