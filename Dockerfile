# php alipine www-data uid = 82 guid = 82 // it's empty by default and set later on
# php alipine xfs uid = 33 guid = 33
# php alipine nginx uid = 100 guid = 101

# nginx alpine xfs uid = 33, guid = 33
# nginx alpine www-data is empty
# nginx alpine uid=82 and guid=82 are empty by default
# nginx alipine nginx uid = 100 guid = 101


# ubuntu www=data uid = 33 guid = 33
# ubuntu uid = 82 guid = 82 are emtpy by default
# ubuntu uid = 100/101 guid = 100/101 are beign used as systemmd

# conclusion, on ubuntu server add uid & guid with number 82 and named it www or nginx or whatsoever
# then on nginx alpine add 82 as well 

# sudo groupadd -g 82 nginx
# sudo adduser --gid 82 --uid 82 --system --no-create-home --disabled-password --disabled-login nginx

FROM php:7.2-fpm-alpine

# Install dev dependencies
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    imagemagick-dev \
    libtool \
    libxml2-dev \
    postgresql-dev \
    sqlite-devvim 

# Install production dependencies
RUN apk add --no-cache \
    bash \
    curl \
    g++ \
    gcc \
    git \
    imagemagick \
    libc-dev \
    libpng-dev \
    make \
    mysql-client \
    nodejs \
    nodejs-npm \
    openssh-client \
    postgresql-libs \
    rsync \
    imap-dev \
    openssl-dev \
    logrotate \
    libmcrypt-dev

# Install PECL and PEAR extensions
RUN pecl install imagick

# Install and enable php extensions
RUN docker-php-ext-enable imagick

RUN docker-php-ext-install \
    curl \
    iconv \
    mbstring \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pcntl \
    tokenizer \
    xml \
    gd \
    zip \
    bcmath \
    sockets \
    imap

# Install Imap
RUN docker-php-ext-enable imap && docker-php-ext-configure imap --with-imap-ssl

# Install Redis
RUN apk add --no-cache \
		$PHPIZE_DEPS
RUN pecl install redis && docker-php-ext-enable redis

# Install supervisor
RUN apk add --no-cache supervisor

# Install composer
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="./vendor/bin:$PATH"

# Cleanup dev dependencies
RUN apk del -f .build-deps
