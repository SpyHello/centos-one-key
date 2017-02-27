#!/usr/bin/env bash

yum update
yum install -y curl make gcc autoconf perl-devel.x86_64 libcurl-devel.x86_64 freetype-devel.x86_64  libpng-devel.x86_64 pcre pcre-devel openssl-devel openssl-libs.x86_64 openssl.x86_64 openssl-devel libxml2-devel


function println(){
    echo -e "|---- ${1}"
}
function copy(){
    if [ ! -f $2 ]; then
        println "file '${1}' begin copy";
        cp -R $1 $2
    else
        println "file '${1}' exist, stop copy";
    fi
}
function download(){
    buildir `dirname $1`
    if [ ! -f $1 ]; then
        println "file '${1}' begin download";
        wget $2 -O $1
#        curl -o $1 -L --connect-timeout 100 -m 200 $2
    else
        println "file '${1}' exist, stop download";
    fi
}
# insert text into text file
# @param int $line_number
# @param string $text2insert
# @param string $textfilepath
function iinsert(){
    if [ ! -f ${3} ]; then
        touch ${3}
    fi
    sed -i "${1}a ${2}" ${3}
}

# replace text in certain line
# @param int $line_number
# @param string $text2replace
# @param string $textfilepath
function line_replace(){
    sed -i "${1}c ${2}" ${3}
}
function buildir(){
    # check parent dir
    parentdir=`dirname $1`
    if [ ! -d ${parentdir} ]; then
        println "to make parentdir ${parentdir}"
        buildir ${parentdir}
    fi
    # make dir
    if [ ! -d $1 ]; then
        println "to make dir ${1}"
        mkdir $1
    else
        println "to make dir ${1}:exist"
    fi
}

########################################################################################################################
SRV_HOME=/srv
PHP7_HOME=${SRV_HOME}/php7
HTTPD_HOME=${SRV_HOME}/apache24
INSTALL_HOME=${SRV_HOME}/install
# var
php=php-7.0.15
MIRROR=http://cn2.php.net

# php 源码包下载解压
php_file_path=${INSTALL_HOME}/${php}.tar.gz
download ${php_file_path} ${MIRROR}/distributions/${php}.tar.gz
php_folder_path=${INSTALL_HOME}/${php}
if [ ! -d ${php_folder_path} ]; then
    tar -zxf ${php_file_path} -C ${INSTALL_HOME}
    println "${php} source unzip done"
else
    println "${php} source exist"
fi

# gd2 libjpeg库依赖
jpegsrc=jpeg-9b
jpegsrc_file_path=${INSTALL_HOME}/${jpegsrc}.tgz
if [ ! -f ${jpegsrc_file_path} ]; then
    println "Download ${jpegsrc_file_path}"
    # this address has been redirected
    download ${jpegsrc_file_path} http://www.ijg.org/files/jpegsrc.v9b.tar.gz
    tar -zxvf ${jpegsrc_file_path} -C ${INSTALL_HOME}
    cd ${INSTALL_HOME}/${jpegsrc}
    ./configure
    make clean && make && make install
fi
# php主程序安装
if [ ! -f ${PHP7_HOME}/path.lock ]; then
    cd ${php_folder_path}
    ./configure --prefix=${PHP7_HOME}  \
                --with-libdir=lib64 \
                --enable-fpm \
                --enable-sockets \
                --with-openssl  \
                --with-libxml-dir \
                --with-pcre-regex \
                --enable-mbstring   \
                --with-pdo-mysql    \
                --with-openssl-dir \
                --with-gd  --with-freetype-dir  \
                --with-curl  \
                --enable-pcntl --enable-zip
    make clean && make && make install

    if [ -d ${PHP7_HOME}/lib/ ] ; then
        cp ${php_folder_path}/php.ini-development ${PHP7_HOME}/lib/php.ini

        addpath ${PHP7_HOME}/bin
        touch ${PHP7_HOME}/path.lock
    fi
fi

# composer安装
composer_file=${PHP7_HOME}/bin/composer
if [ ! -f ${composer_file} ];then
    download ${INSTALL_HOME}/composer.phar "https://getcomposer.org/download/1.3.2/composer.phar"
    copy ${INSTALL_HOME}/composer.phar ${PHP7_HOME}/bin/composer
    chmod a+x ${PHP7_HOME}/bin/composer
fi

# fpm 安装
if [ ! -f /etc/init.d/php-fpm ];then
    cp ${PHP7_HOME}/sapi/fpm/init.d.php-fpm.in /etc/init.d/php-fpm
    chmod a+x /etc/init.d/php-fpm
    chkconfig php-fpm on
    systemctl enable php-fpm
    systemctl start php-fpm
fi