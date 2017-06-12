#!/usr/bin/env bash
# chkconfig: 2345 85 15
# Startup script for the nginx Web Server
# description: nginx is a World Wide Web server.
# It is used to serve HTML files and CGI.
# processname: nginx
# pidfile: /home/srv/nginx/logs/nginx.pid
# config: /home/srv/nginx/conf/nginx.conf
NGINX_HOME=/home/srv/nginx
DESC="nginx server"
NAME=nginx
DAEMON=${NGINX_HOME}/sbin/nginx
SCRIPTNAME=/etc/init.d/nginx

test -x ${DAEMON} || exit 0

d_start(){
  ${DAEMON} || echo -n "already running"
}

d_stop(){
  ${DAEMON} -s quit || echo -n "not running"
}


d_reload(){
  ${DAEMON} -s reload || echo -n "can not reload"
}

case "$1" in
start)
  echo -n "Starting $DESC: $NAME"
  d_start
  echo "."
;;
stop)
  echo -n "Stopping $DESC: $NAME"
  d_stop
  echo "."
;;
reload)
  echo -n "Reloading $DESC conf..."
  d_reload
  echo "reload ."
;;
restart)
  echo -n "Restarting $DESC: $NAME"
  d_stop
  sleep 2
  d_start
  echo "."
;;
*)
  echo "Usage: \$SCRIPTNAME {start|stop|reload|restart}" >&2
  exit 3
;;
esac

exit 0