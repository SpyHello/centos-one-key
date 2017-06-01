#!/usr/bin/env bash
# chkconfig: 2345 85 15
#
# Startup script for the nginx Web Server
#
# description: nginx is a World Wide Web server.
# processname: nginx
# pidfile: /home/srv/nginx/log/nginx.pid
# config: /home/srv/nginx/conf/nginx.conf
NGINX_HOME=/home/srv/nginx

nginxd=${NGINX_HOME}/sbin/nginx
nginx_config=${NGINX_HOME}/conf/nginx.conf
nginx_pid=${NGINX_HOME}/logs/nginx.pid
RETVAL=0
prog="nginx"
# Source function library.
source /etc/rc.d/init.d/functions
# Source networking configuration.
source /etc/sysconfig/network
# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0
[ -x ${nginxd} ] || exit 0
# Start nginx daemons functions.
start() {
if [ -e ${nginx_pid} ];then
   echo "nginx already running...."
   exit 1
fi
   echo -n $"Starting $prog: "
   daemon ${nginxd} -c ${nginx_config}
   RETVAL=$?
   echo
   [ ${RETVAL} = 0 ] && touch /var/lock/nginx
   return ${RETVAL}
}
# Stop nginx daemons functions.
stop() {
        echo -n $"Stopping $prog: "
        killproc ${nginxd}
        RETVAL=$?
        echo
        [ ${RETVAL} = 0 ] && rm -f /var/lock/nginx ${nginx_pid}
}
# reload nginx service functions.
reload() {
    echo -n $"Reloading $prog: "
    #kill -HUP `cat ${nginx_pid}`
    killproc ${nginxd} -HUP
    RETVAL=$?
    echo
}
# See how we were called.
case "$1" in
    start)
            start
            ;;
    stop)
            stop
            ;;
    reload)
            reload
            ;;
    restart)
            stop
            start
            ;;
    status)
            status ${prog}
            RETVAL=$?
            ;;

    *)
            echo $"Usage: $prog {start|stop|restart|reload|status|help}"
            exit 1
esac
exit ${RETVAL}