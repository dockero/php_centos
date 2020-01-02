FROM centos:7

LABEL maintainer="codinghuang"

RUN yum -y update

# install dev libraries
RUN yum -y install \
        libcurl-devel \
        libxml2-devel \
        openssl-devel

# install dev tools
RUN yum -y install \
        wget \
        gcc \
        gcc-c++ \
        make \
        cmake \
        vim \
        autoconf \
        help2man \
        nmap \
        net-tools

# install test tools
RUN wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz \
        && tar xf release-1.8.0.tar.gz \
        && cd googletest-release-1.8.0 \
        && cmake -DBUILD_SHARED_LIBS=ON . \
        && make \
        && make install

# install git 2
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm
RUN yum -y install git2u-all

# install debug tools
RUN yum install -y ncurses-devel texinfo readline-devel automake flex
RUN yum install -y gdb
RUN cd /root \
        && wget https://cgdb.me/files/cgdb-0.7.0.tar.gz \
        && tar xvfz cgdb-0.7.0.tar.gz \
        && cd cgdb-0.7.0 \
        && ./configure \
        && make \
        && make install \
        && cd /root \
        && rm -r cgdb-0.7.0.tar.gz cgdb-0.7.0

# install ssh
RUN yum install -y \
        openssh-server

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

# install php
# download php src
ENV PATH $PATH:/usr/bin:/usr/sbin
RUN cd /root \
        && curl -L http://cn2.php.net/distributions/php-7.3.12.tar.xz -o php-7.3.12.tar.gz
# build php
RUN cd /root \
        && tar xvf php-7.3.12.tar.gz \
        && cd php-7.3.12 \
        && ./configure --prefix=/usr --enable-fpm --enable-debug --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d \
        && make \
        && make install \
        && cp php.ini-development /etc/php.ini \
        && cd /root \
        && rm -r php-7.3.12.tar.gz

# install php extension
# install openssl
RUN cd /root/php-7.3.12/ext \
        && cd openssl \
        && cp config0.m4 config.m4 \
        && phpize \
        && ./configure \
        && make \
        && make install

# install zlib
RUN cd /root/php-7.3.12/ext \
        && cd zlib \
        && cp config0.m4 config.m4 \
        && phpize \
        && ./configure \
        && make \
        && make install

# install curl
RUN cd /root/php-7.3.12/ext \
        && cd curl \
        && phpize \
        && ./configure \
        && make \
        && make install

# install zip
# upgrade libzip
RUN yum -y remove libzip-devel
RUN cd /root \
        && wget https://libzip.org/download/libzip-1.3.2.tar.gz \
        && tar xvf libzip-1.3.2.tar.gz \
        && cd libzip-1.3.2 \
        && ./configure \
        && make && make install \
        && cd /root \
        && yes | rm libzip-1.3.2.tar.gz

# install zip extension
RUN cd /root/php-7.3.12/ext \
        && cd zip \
        && phpize \
        && ./configure \
        && make \
        && make install

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
        && ./configure \
        && make \
        && make install \
        && cd /root \
        && rm swoole-src.tar.gz

COPY etc/php.d etc/php.d

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/composer
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
        && composer global require hirak/prestissimo \
        && composer global require "squizlabs/php_codesniffer=*"

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

WORKDIR /root/codeDir

CMD ["/usr/sbin/sshd", "-D"]