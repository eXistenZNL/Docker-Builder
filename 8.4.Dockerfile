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

FROM alpine:3.22

LABEL maintainer="docker@stefan-van-essen.nl"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' TERM='xterm'

# Temporary workaround for problems with php84-iconv on Alpine based PHP images
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
    php84 \
    php84-ctype \
    php84-curl \
    php84-dom \
    php84-fileinfo \
    php84-ftp \
    php84-gettext \
    php84-gd \
    php84-gmp \
    php84-iconv \
    php84-intl \
    php84-json \
    php84-ldap \
    php84-mbstring \
    php84-openssl \
    php84-pecl-xdebug \
    php84-pcntl \
    php84-pdo_mysql \
    php84-pdo_pgsql \
    php84-pdo_sqlite \
    php84-phar \
    php84-posix \
    php84-redis \
    php84-session \
    php84-simplexml \
    php84-snmp \
    php84-soap \
    php84-sodium \
    php84-tokenizer \
    php84-xml \
    php84-xmlreader \
    php84-xmlwriter \
    php84-zip \
    php84-zlib \
    podman \
    zlib-dev \
    && ln -sf /usr/bin/php84 /usr/bin/php \
    && curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && npm install -g --unsafe-perm yarn \
    && sed -i 's/;zend/zend/g' /etc/php84/conf.d/50_xdebug.ini

COPY cache-tool.sh /usr/local/bin/cache-tool
