#!/bin/bash

if [[ `uname` == 'Darwin' ]]; then
    sed -i "_back" "s/^PHP_VERSION=.*/PHP_VERSION=$1/g" .env
elif [[ `uname` == 'Linux' ]]; then
    sed -i "s/^PHP_VERSION=.*/PHP_VERSION=$1/g" .env
fi
