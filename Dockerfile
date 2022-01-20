FROM php:8.0-cli-alpine

RUN apk update && apk add bash git libzip-dev

RUN docker-php-ext-install zip opcache

RUN echo "opcache.enable = 1" >> /usr/local/etc/php/php.ini \
    && echo "opcache.enable_cli = 1" >> /usr/local/etc/php/php.ini \
    && echo "opcache.memory_consumption = 128" >> /usr/local/etc/php/php.ini \
    && echo "opcache.max_accelerated_files = 100000" >> /usr/local/etc/php/php.ini \
    && echo "opcache.interned_strings_buffer = 16" >> /usr/local/etc/php/php.ini \
    && echo "realpath_cache_size = 50M" >> /usr/local/etc/php/php.ini \
    && echo "memory_limit = -1" >> /usr/local/etc/php/php.ini \
    && echo /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && chmod +x /usr/bin/composer

RUN composer global config minimum-stability beta && composer global require debricked/cli ^9.0.2 --prefer-stable

COPY pipe /
COPY test /test
RUN chmod a+x /*.sh

# Run debricked-cli once during build to fetch all dependencies
RUN ["/root/.composer/vendor/debricked/cli/bin/console", "debricked:scan", "--help"]

ENTRYPOINT ["/pipe.sh"]
