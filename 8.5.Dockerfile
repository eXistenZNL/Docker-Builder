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

FROM alpine:3.23

LABEL maintainer="docker@stefan-van-essen.nl"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' TERM='xterm'

# Temporary workaround for problems with php85-iconv on Alpine based PHP images
# See https://github.com/docker-library/php/issues/240 for more info
ENV LD_PRELOAD='/usr/lib/preloadable_libiconv.so php'
COPY --from=locales /usr/lib/preloadable_libiconv.so /usr/lib/preloadable_libiconv.so

# Load the built locales from this location
ENV MUSL_LOCPATH=/usr/share/i18n/locales/musl
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
    php85 \
    php85-ctype \
    php85-curl \
    php85-dom \
    php85-fileinfo \
    php85-ftp \
    php85-gettext \
    php85-gd \
    php85-gmp \
    php85-iconv \
    php85-intl \
    php85-json \
    php85-ldap \
    php85-mbstring \
    php85-openssl \
    php85-pecl-xdebug \
    php85-pcntl \
    php85-pdo_mysql \
    php85-pdo_pgsql \
    php85-pdo_sqlite \
    php85-phar \
    php85-posix \
    php85-redis \
    php85-session \
    php85-simplexml \
    php85-snmp \
    php85-soap \
    php85-sodium \
    php85-tokenizer \
    php85-xml \
    php85-xmlreader \
    php85-xmlwriter \
    php85-zip \
    php85-zlib \
    podman \
    zlib-dev \
    && ln -sf /usr/bin/php85 /usr/bin/php \
    && curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && npm install -g --unsafe-perm yarn \
    && sed -i 's/;zend/zend/g' /etc/php85/conf.d/50_xdebug.ini

COPY cache-tool.sh /usr/local/bin/cache-tool
