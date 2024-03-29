FROM centos:7

LABEL maintainer="codinghuang"

RUN yum -y update && \
        yum -y install epel-release

# install dev libraries
RUN yum -y install \
        libcurl-devel \
        libxml2-devel \
        sqlite-devel \
        libffi-devel \
        bzip2-devel \
        libxslt \
        libxslt-devel \
        oniguruma-devel

# install 32-bit libraries
RUN yum -y install \
        glibc-devel.i686 \
        libgcc.i686 \
        libstdc++-devel.i686

# install pressure test tools
RUN yum -y install \
        httpd-tools

# install build tools
RUN yum -y install \
        gcc \
        gcc-c++ \
        make \
        cmake3 \
        autoconf \
        bzip2

# install other tools
RUN yum -y install \
        wget \
        vim \
        help2man \
        nmap \
        net-tools \
        valgrind \
        gettext \
        git

# install openssl-dev 1.1.1
RUN cd /tmp \
        && git clone https://gitee.com/codinghuang/openssl.git \
        && cd openssl \
        && git checkout OpenSSL_1_1_1c \
        && ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib \
        && make > /dev/null \
        && make install > /dev/null

RUN cp /usr/local/openssl/lib/pkgconfig/*.pc /usr/lib64/pkgconfig/

# install test tools
RUN cd /tmp \
        && wget https://github.com/google/googletest/archive/release-1.10.0.tar.gz \
        && tar xf release-1.10.0.tar.gz \
        && cd googletest-release-1.10.0 \
        && cmake3 -DBUILD_SHARED_LIBS=ON . \
        && make > /dev/null \
        && make install > /dev/null

# install git 2
RUN cd /tmp \
        && git clone https://gitee.com/codinghuang/git.git \
        && cd git \
        && git checkout v2.22.2 \
        && yum -y remove git* \
        && make configure \
        && ./configure --with-openssl=/usr/local/openssl \
        && make > /dev/null \
        && make install > /dev/null

# install debug tools
RUN yum install -y ncurses-devel texinfo readline-devel automake flex
RUN yum install -y gdb
RUN cd /root \
        && wget https://github.com/cgdb/cgdb/archive/v0.7.1.tar.gz -O cgdb-0.7.1.tar.gz \
        && tar xvfz cgdb-0.7.1.tar.gz \
        && cd cgdb-0.7.1 \
        && ./autogen.sh \
        && ./configure \
        && make > /dev/null \
        && make install > /dev/null \
        && cd /root \
        && rm -r cgdb-0.7.1.tar.gz cgdb-0.7.1


# install ssh
RUN yum install -y \
        openssh-server

# install php
# download php src
# http://cn2.php.net/
# curl -L http://cn2.php.net/distributions/php-${PHP_VERSION}.tar.xz -o php-${PHP_VERSION}.tar.gz
RUN yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/r/re2c-0.14.3-2.el7.x86_64.rpm \
        re2c \
        bison \
        flex
ARG PHP_VERSION
ENV PATH $PATH:/usr/bin:/usr/sbin
RUN cd /root \
        && git clone https://gitee.com/codinghuang/php-repo.git \
        && cp php-repo/php-${PHP_VERSION}.tar.gz .
# unpace php package
RUN cd /root                           \
        && tar xf php-${PHP_VERSION}.tar.gz    \
        && mv php-${PHP_VERSION} php-src
# build php
RUN cd /root \
        && cd php-src \
        && ./configure --prefix=/usr \
                --with-config-file-path=/etc \
                --with-config-file-scan-dir=/etc/php.d \
                --enable-fpm \
                --with-mysqli=mysqlnd \
                --with-pdo-mysql=mysqlnd \
                --with-mysqli \
                --with-pdo_mysql \
        && make > /dev/null \
        && make install > /dev/null \
        && cp php.ini-development /etc/php.ini \
        && cd /root \
        && rm -r php-${PHP_VERSION}.tar.gz                \
        && php -v

# install php extension
# install openssl

RUN cd /root/php-src/ext \
        && cd openssl \
        && cp config0.m4 config.m4 \
        && phpize \
        && ./configure \
        && make > /dev/null \
        && make install > /dev/null

# install zlib
RUN cd /root/php-src/ext \
        && cd zlib \
        && cp config0.m4 config.m4 \
        && phpize \
        && ./configure \
        && make > /dev/null \
        && make install > /dev/null

# install curl
RUN cd /root/php-src/ext \
        && cd curl \
        && phpize \
        && ./configure \
        && make > /dev/null \
        && make install > /dev/null

# install zip
# upgrade libzip
RUN yum -y remove libzip-devel
RUN cd /root \
        && wget https://libzip.org/download/libzip-1.3.2.tar.gz \
        && tar xvf libzip-1.3.2.tar.gz \
        && cd libzip-1.3.2 \
        && ./configure --prefix=/usr/local/libzip \
        && make > /dev/null && make install > /dev/null \
        && cd /root \
        && yes | rm libzip-1.3.2.tar.gz

RUN cp /usr/local/libzip/lib/pkgconfig/*.pc /usr/lib64/pkgconfig/

# install zip extension

RUN cd /root/php-src/ext \
        && cd zip \
        && phpize \
        && ./configure \
        && make > /dev/null \
        && make install > /dev/null

# install sockets extension
RUN cd /root/php-src/ext \
        && cd sockets \
        && phpize \
        && ./configure \
        && make > /dev/null \
        && make install > /dev/null

# install swoole
# download swoole
ARG SWOOLE_VERSION
RUN cd /root \
        && curl -L https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -o swoole-src.tar.gz
# build swoole
RUN cd /root \
        && tar -xzf swoole-src.tar.gz \
        && cd swoole-src* \
        && phpize \
        && ./configure --enable-openssl --with-openssl-dir=/usr/local/openssl/ \
                --enable-sockets \
                --enable-mysqlnd \
                --enable-http2 \
        && make > /dev/null \
        && make install > /dev/null \
        && cd /root \
        && rm swoole-src.tar.gz

COPY etc/php.d etc/php.d

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/composer
# RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
#         && composer global require hirak/prestissimo \
#         && composer global require "squizlabs/php_codesniffer=*"

# modify the password
ARG PASSWORD
RUN sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config \
        && ssh-keygen -t rsa -P "" -f /etc/ssh/ssh_host_rsa_key \
        && ssh-keygen -t ecdsa -P "" -f /etc/ssh/ssh_host_ecdsa_key \
        && ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key \
        && echo "root:${PASSWORD}" | chpasswd

# add id_rsa.pub in authorized_keys
ARG SSH_PUB_KEY
RUN mkdir -p ~/.ssh \
        && echo $SSH_PUB_KEY > ~/.ssh/authorized_keys

# set the path for ssh
ARG LD_LIBRARY_PATH
# set the LD_LIBRARY_PATH to the compiler's search library
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> /etc/profile
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib" >> /etc/profile
# set the PATH
RUN echo "export PATH=$PATH:~/.composer/vendor/bin" >> /etc/profile

# set the http proxy for ssh
ARG HTTP_PROXY
ARG HTTPS_PROXY
RUN echo "export http_proxy=${HTTP_PROXY}" >> /etc/profile
RUN echo "export http_proxys=${HTTPS_PROXY}" >> /etc/profile

# Install php tools
RUN wget -q -O /usr/bin/phpbrew https://github.com/phpbrew/phpbrew/raw/master/phpbrew && chmod +x /usr/bin/phpbrew

RUN phpbrew init \
  && echo 'source $HOME/.phpbrew/bashrc' >> /root/.bashrc \
  && source ~/.phpbrew/bashrc

WORKDIR /root/codeDir

CMD ["/usr/sbin/sshd", "-D"]
