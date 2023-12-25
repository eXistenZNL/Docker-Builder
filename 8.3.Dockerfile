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

# Temporary workaround for problems with php83-iconv on Alpine based PHP images
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
    php83 \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-fileinfo \
    php83-ftp \
    php83-gettext \
    php83-gd \
    php83-gmp \
    php83-iconv \
    php83-intl \
    php83-json \
    php83-ldap \
    php83-mbstring \
    php83-openssl \
    php83-pecl-xdebug \
    php83-pcntl \
    php83-pdo_mysql \
    php83-pdo_pgsql \
    php83-pdo_sqlite \
    php83-phar \
    php83-posix \
    php83-redis \
    php83-session \
    php83-simplexml \
    php83-snmp \
    php83-soap \
    php83-sodium \
    php83-tokenizer \
    php83-xml \
    php83-xmlreader \
    php83-xmlwriter \
    php83-zip \
    php83-zlib \
    zlib-dev \
    && ln -s /usr/bin/php83 /usr/bin/php \
    && curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && npm install -g --unsafe-perm yarn \
    && sed -i 's/;zend/zend/g' /etc/php83/conf.d/50_xdebug.ini

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ buildah podman

COPY cache-tool.sh /usr/local/bin/cache-tool
