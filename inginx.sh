#!/usr/bin/env bash

yum update -y
yum install -y curl make gcc autoconf perl-devel.x86_64 libcurl-devel.x86_64 freetype-devel.x86_64  libpng-devel.x86_64 pcre pcre-devel openssl-devel openssl-libs.x86_64 openssl.x86_64 openssl-devel libxml2-devel

#######################################  公共区域 ##########################################################################

CURRENT_DIR=`pwd`
function addpath(){
    echo "export PATH=\${PATH}:${1}" >> /etc/profile
    source /etc/profile
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
# replace text in certain line
# @param int $line_number
# @param string $text2replace
# @param string $textfilepath
function line_replace(){
    sed -i "${1}c ${2}" ${3}
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



nginx="nginx-1.10.3"
nginx_download="http://nginx.org/download/${nginx}.tar.gz"

SERVER_DIR=/srv
INSTALL_DIR=${SERVER_DIR}/install
NGINX_HOME=${SERVER_DIR}/nginx

buildir ${SERVER_DIR}
buildir ${INSTALL_DIR}
buildir ${NGINX_HOME}
USER=deamon
GROUP=deamon

httpd_file_path=${INSTALL_DIR}/${nginx}.tar.gz
if [ ! -f ${httpd_file_path} ] ; then
    download ${httpd_file_path} ${nginx_download}
fi
httpd_folder_path=${INSTALL_DIR}/${nginx}
if [ ! -d ${httpd_folder_path} ]; then
    tar -zxf ${httpd_file_path} -C ${INSTALL_DIR}
    println "${httpd_folder_path} source unzip done"
else
    println "${httpd_folder_path} source exist"
fi


if [ ! -f ${NGINX_HOME}/install.lock ]; then
    cd ${httpd_folder_path}
    ./configure --prefix=${NGINX_HOME} \
#    --user=${USER} --group=${GROUP}  \
    --with-http_realip_module  \
    --with-http_sub_module  --with-http_gzip_static_module   \
    --with-http_stub_status_module    \
    --with-pcre --with-http_ssl_module

    # make clean &&
    make && make install

    addpath ${NGINX_HOME}/sbin
    touch ${NGINX_HOME}/install.lock
fi


function backup(){
    if [ ! -f "${1}.bak" ] ; then
        cp $1 "${1}.bak"
    fi
}
backup ${NGINX_HOME}/conf/nginx.conf

# rm -f /etc/init.d/nginx /etc/rc.d/rc5.d/S85nginx
if [ ! -f /etc/init.d/nginx ]; then
    echo "#!/bin/sh
    # chkconfig: 2345 85 15
    # Startup script for the nginx Web Server
    # description: nginx is a World Wide Web server.
    # It is used to serve HTML files and CGI.
    # processname: nginx
    # pidfile: /tmp/nginx.pid
    # config: /srv/nginx/conf/nginx.conf

    DESC=\"nginx server\"
    NAME=nginx
    DAEMON=/bin/nginx
    SCRIPTNAME=/etc/init.d/nginx

    test -x \$DAEMON || exit 0

    d_start(){
      \$DAEMON || echo -n \"already running\"
    }

    d_stop(){
      \$DAEMON -s quit || echo -n \"not running\"
    }


    d_reload(){
      \$DAEMON -s reload || echo -n \"can not reload\"
    }

    case \"\$1\" in
    start)
      echo -n \"Starting \$DESC: \$NAME\"
      d_start
      echo \".\"
    ;;
    stop)
      echo -n \"Stopping \$DESC: \$NAME\"
      d_stop
      echo \".\"
    ;;
    reload)
      echo -n \"Reloading \$DESC conf...\"
      d_reload
      echo \"reload .\"
    ;;
    restart)
      echo -n \"Restarting \$DESC: \$NAME\"
      d_stop
      sleep 2
      d_start
      echo \".\"
    ;;
    *)
      echo \"Usage: \$ScRIPTNAME {start|stop|reload|restart}\" >&2
      exit 3
    ;;
    esac

    exit 0" > /etc/init.d/nginx
    chmod a+x /etc/init.d/nginx
    ln -s /etc/init.d/nginx /etc/rc.d/rc5.d/S85nginx
    chkconfig --add nginx
    systemctl enable nginx
    systemctl start nginx
fi



