FROM php:7.3-cli-alpine3.9

RUN apk update && apk add bash

RUN docker-php-ext-install opcache

RUN echo "opcache.enable = 1" >> /usr/local/etc/php/php.ini \
    && echo "opcache.enable_cli = 1" >> /usr/local/etc/php/php.ini \
    && echo "opcache.memory_consumption = 128" >> /usr/local/etc/php/php.ini \
    && echo "opcache.max_accelerated_files = 100000" >> /usr/local/etc/php/php.ini \
    && echo "opcache.interned_strings_buffer = 16" >> /usr/local/etc/php/php.ini \
    && echo "realpath_cache_size = 50M" >> /usr/local/etc/php/php.ini \
    && echo /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && chmod +x /usr/bin/composer

RUN composer global config minimum-stability beta && composer global require debricked/cli ^1.0.4 --prefer-stable

COPY pipe /
COPY test /test
RUN chmod a+x /*.sh

ENTRYPOINT ["/pipe.sh"]
