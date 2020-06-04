# 介绍

[![Build Status](https://api.travis-ci.org/dockero/php_centos.svg?branch=master)](https://travis-ci.org/dockero/php_centos)

在`centos`容器里面开启`ssh`，以便宿主机可以直接通过`vscode`的`ssh remote`插件登陆进去容器进行开发。

## 快速开始

### 配置变量

你需要修改`docker-compose.yml`文件里面的变量。或者创建一个`.env`文件，例子：

```ini
HTTP_PROXY=http://127.0.0.1:8080
HTTPS_PROXY=http://127.0.0.1:8080
CODEDIR_VOLUME=~/codeDir:/root/codeDir
HOST_SSH_PORT=9522
PASSWORD=123456
PHP_VERSION=7.4.0
SWOOLE_VERSION=4.4.12
GIT_VERSION=2.24.0
SSH_PUB_KEY=填写你的公钥
```

#### CODEDIR_VOLUME（建议配置）

指的是你宿主机的代码希望挂在到容器的哪个位置。例如：

```shell
CODEDIR_VOLUME=~/codeDir:/root/codeDir
```

#### HTTP_PROXY（按需配置，非必须）

指的是为容器里面配置HTTP代理。例如：`http://127.0.0.1:8080`。

> 如果不需要代理，可以删除此环境变量

#### HTTPS_PROXY（按需配置，非必须）

指的是为容器里面配置HTTPS代理。例如：`http://127.0.0.1:8080`。

> 如果不需要代理，可以删除此环境变量

#### HOST_SSH_PORT（必须）

指的是容器为宿主机暴露出来的ssh端口。例如：`9522`。

#### PASSWORD（必须）

指的是容器中root用户的密码，用来登陆容器用的。例如：`123456`。

#### SSH_PUB_KEY（可选）

把宿主机的公钥添加到容器的`~/.ssh/authorized_keys`里面，用来免密登陆。

#### PHP_VERSION（必须）

指定按照的`PHP`版本。支持`7.3.x`和`7.4.x`。例如填写`7.3.12`。

#### SWOOLE_VERSION（必须）

指定安装的`Swoole`版本。例如：`4.4.12`。

#### GIT_VERSION（必须）

建议版本大于`2.0`。

### 编译镜像

```shell
docker-compose build
```

### 启动容器

```shell
docker-compose up -d
```

### 登陆容器

```shell
ssh root@127.0.0.1 -p 9522
root@127.0.0.1's password:
```

登陆成功之后，将会进入容器：

```shell
Last login: Sun Dec  1 07:09:11 2019 from gateway
```
