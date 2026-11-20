FROM alpine:3.24 as locales

RUN apk -U --no-cache add \
    build-base \
    cmake \
    curl \
    gettext-dev \
    unzip

# GNU libiconv 1.15 is the last release that ships a preloadable library, and it only builds as C17 with a modern GCC
RUN curl --silent --show-error --location https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz | tar xz \
    && cd libiconv-1.15 \
    && CFLAGS='-O2 -std=gnu17' ./configure --prefix=/usr --enable-static=no \
    && make \
    && cp preload/preloadable_libiconv.so /usr/lib/preloadable_libiconv.so

RUN curl https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip --output musl-locales-master.zip \
    && unzip musl-locales-master.zip && cd musl-locales-master \
    && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install

FROM alpine:edge

LABEL maintainer="docker@stefan-van-essen.nl"

ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' TERM='xterm'

# Temporary workaround for problems with php86-iconv on Alpine based PHP images
# See https://github.com/docker-library/php/issues/240 for more info
ENV LD_PRELOAD='/usr/lib/preloadable_libiconv.so php'
COPY --from=locales /usr/lib/preloadable_libiconv.so /usr/lib/preloadable_libiconv.so

# Load the built locales from this location
ENV MUSL_LOCPATH=/usr/share/i18n/locales/musl
COPY --from=locales /usr/share/i18n/locales/musl /usr/share/i18n/locales/musl

# PHP 8.6 is currently only available in the Alpine edge testing repository, which is why this container is tagged with -edge
RUN apk -U --no-cache add \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
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
    php86 \
    php86-ctype \
    php86-curl \
    php86-dom \
    php86-fileinfo \
    php86-ftp \
    php86-gettext \
    php86-gd \
    php86-gmp \
    php86-iconv \
    php86-intl \
    php86-json \
    php86-ldap \
    php86-mbstring \
    php86-openssl \
    php86-pecl-xdebug \
    php86-pcntl \
    php86-pdo_mysql \
    php86-pdo_pgsql \
    php86-pdo_sqlite \
    php86-phar \
    php86-posix \
    php86-redis \
    php86-session \
    php86-simplexml \
    php86-snmp \
    php86-soap \
    php86-sodium \
    php86-tokenizer \
    php86-xml \
    php86-xmlreader \
    php86-xmlwriter \
    php86-zip \
    php86-zlib \
    podman \
    zlib-dev \
    && ln -sf /usr/bin/php86 /usr/bin/php \
    && curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && npm install -g yarn \
    && sed -i 's/;zend/zend/g' /etc/php86/conf.d/50_xdebug.ini

COPY cache-tool.sh /usr/local/bin/cache-tool
