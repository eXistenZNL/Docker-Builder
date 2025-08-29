FROM alpine:3.13 as locales

RUN apk -U --no-cache add \
    alpine-sdk \
    automake \
    cmake \
    gettext-dev \
    gnu-libiconv \
    libintl \
    musl-dev

RUN curl https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip --output musl-locales-master.zip \
    && unzip musl-locales-master.zip && cd musl-locales-master \
    && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install

FROM alpine:3.19

LABEL maintainer="docker@stefan-van-essen.nl"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' TERM='xterm'

# Temporary workaround for problems with php82-iconv on Alpine based PHP images
# See https://github.com/docker-library/php/issues/240 for more info
ENV LD_PRELOAD='/usr/lib/preloadable_libiconv.so php'
COPY --from=locales /usr/lib/preloadable_libiconv.so /usr/lib/preloadable_libiconv.so

# Load the built locales from this location
ENV MUSL_LOCPATH /usr/share/i18n/locales/musl
COPY --from=locales /usr/share/i18n/locales/musl /usr/share/i18n/locales/musl

RUN apk -U --no-cache add \
    bash \
    buildah \
    curl \
    docker \
    git \
    libintl \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libpng \
    libpng-dev \
    libtool \
    libwebp \
    libwebp-dev \
    nodejs \
    npm \
    openssh \
    php82 \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-fileinfo \
    php82-ftp \
    php82-gettext \
    php82-gd \
    php82-gmp \
    php82-iconv \
    php82-intl \
    php82-json \
    php82-ldap \
    php82-mbstring \
    php82-openssl \
    php82-pecl-xdebug \
    php82-pcntl \
    php82-pdo_mysql \
    php82-pdo_pgsql \
    php82-pdo_sqlite \
    php82-phar \
    php82-posix \
    php82-redis \
    php82-session \
    php82-simplexml \
    php82-snmp \
    php82-soap \
    php82-sodium \
    php82-tokenizer \
    php82-xml \
    php82-xmlreader \
    php82-xmlwriter \
    php82-zip \
    php82-zlib \
    podman \
    zlib-dev \
    && curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && npm install -g --unsafe-perm yarn \
    && sed -i 's/;zend/zend/g' /etc/php82/conf.d/50_xdebug.ini

COPY cache-tool.sh /usr/local/bin/cache-tool
