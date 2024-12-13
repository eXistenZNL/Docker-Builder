FROM alpine:3.21 as locales

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

FROM alpine:3.21

LABEL maintainer="docker@stefan-van-essen.nl"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' TERM='xterm'

# Temporary workaround for problems with php81-iconv on Alpine based PHP images
# See https://github.com/docker-library/php/issues/240 for more info
ENV LD_PRELOAD='/usr/lib/preloadable_libiconv.so php'
COPY --from=locales /usr/lib/preloadable_libiconv.so /usr/lib/preloadable_libiconv.so

# Load the built locales from this location
ENV MUSL_LOCPATH /usr/share/i18n/locales/musl
COPY --from=locales /usr/share/i18n/locales/musl /usr/share/i18n/locales/musl

RUN apk -U --no-cache add \
    bash \
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
    php81 \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-fileinfo \
    php81-ftp \
    php81-gettext \
    php81-gd \
    php81-gmp \
    php81-iconv \
    php81-intl \
    php81-json \
    php81-ldap \
    php81-mbstring \
    php81-openssl \
    php81-pecl-xdebug \
    php81-pcntl \
    php81-pdo_mysql \
    php81-pdo_pgsql \
    php81-pdo_sqlite \
    php81-phar \
    php81-posix \
    php81-redis \
    php81-session \
    php81-simplexml \
    php81-snmp \
    php81-soap \
    php81-sodium \
    php81-tokenizer \
    php81-xml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-zip \
    php81-zlib \
    zlib-dev \
    && curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && npm install -g --unsafe-perm yarn \
    && sed -i 's/;zend/zend/g' /etc/php81/conf.d/50_xdebug.ini

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ buildah podman

COPY cache-tool.sh /usr/local/bin/cache-tool
