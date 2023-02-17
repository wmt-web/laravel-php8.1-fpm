# Using base ubuntu image
FROM ubuntu:22.04

LABEL Maintainer="Harsh Solanki <harshsolanki7116@gmail.com>" \
      Description="Nginx + PHP7.4-FPM Based on Ubuntu 22.04."

# Setup document root
RUN mkdir -p /var/www/


# Base install
RUN apt update --fix-missing
RUN  DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && echo Asia/Kolkata > /etc/timezone
RUN apt install git zip unzip curl gnupg2 ca-certificates lsb-release libicu-dev supervisor nginx nano -y

# Install php7.4-fpm
# Since the repo is supported on ubuntu 20
RUN apt install php-fpm php-json php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-intl -y

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