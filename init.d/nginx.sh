#!/usr/bin/env bash
# chkconfig: - 85 15
#
# Startup script for the nginx Web Server
#
# description: nginx is a www server.
# processname: nginx
# pidfile: /home/srv/nginx/logs/nginx.pid
# config: /home/srv/nginx/conf/nginx.conf

NGINX_HOME=/home/srv/nginx

nginxd=${NGINX_HOME}/sbin/nginx
nginx_config=${NGINX_HOME}/conf/nginx.conf
nginx_pid=${NGINX_HOME}/logs/nginx.pid

function start ()
{
    ${nginxd} -c ${nginx_config}
}
function stop() {
    ${nginxd} -s stop
}
# reload nginx service functions.
function reload() {
    stop
    start
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
        reload
            ;;
    status)
         cat "PID ${nginxd} running"
            ;;

    *)
            echo $"Usage: nginx {start|stop|restart|reload|status|help}"
            exit 1
esac


exit
