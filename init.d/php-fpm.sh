#! /bin/sh
### BEGIN INIT INFO
# Provides:          php-fpm
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts php-fpm
# Description:       starts the PHP FastCGI Process Manager daemon
### END INIT INFO

PREFIX=/home/srv/php
EXEC_PREFIX=${PREFIX}

SBIN=${EXEC_PREFIX}/sbin/php-fpm
SCONF=${PREFIX}/etc/php-fpm.conf
SPID=${PREFIX}/var/run/php-fpm.pid


php_opts="--fpm-config $SCONF --pid ${SPID}"


wait_for_pid () {
	try=0

	while test ${try}} -lt 35 ; do

		case "$1" in
			'created')
			if [ -f "$2" ] ; then
				try=''
				break
			fi
			;;

			'removed')
			if [ ! -f "$2" ] ; then
				try=''
				break
			fi
			;;
		esac

		echo -n .
		try=`expr ${try} + 1`
		sleep 1

	done

}

case "$1" in
	start)
		echo -n "Starting php-fpm "

		${SBIN} --daemonize ${php_opts}

		if [ "$?" != 0 ] ; then
			echo " failed"
			exit 1
		fi

		wait_for_pid created ${SPID}

		if [ -n "$try" ] ; then
			echo " failed"
			exit 1
		else
			echo " done"
		fi
	;;

	stop)
		echo -n "Gracefully shutting down php-fpm "

		if [ ! -r ${SPID} ] ; then
			echo "warning, no pid file found - php-fpm is not running ?"
			exit 1
		fi

		kill -QUIT `cat ${SPID}`

		wait_for_pid removed ${SPID}

		if [ -n "$try" ] ; then
			echo " failed. Use force-quit"
			exit 1
		else
			echo " done"
		fi
	;;

	status)
		if [ ! -r ${SPID} ] ; then
			echo "php-fpm is stopped"
			exit 0
		fi

		PID=`cat ${SPID}`
		if ps -p ${PID} | grep -q ${PID} ; then
			echo "php-fpm (pid ${PID} ) is running..."
		else
			echo "php-fpm dead but pid file exists"
		fi
	;;

	force-quit)
		echo -n "Terminating php-fpm "

		if [ ! -r ${SPID} ] ; then
			echo "warning, no pid file found - php-fpm is not running ?"
			exit 1
		fi

		kill -TERM `cat ${SPID}`

		wait_for_pid removed ${SPID}

		if [ -n "$try" ] ; then
			echo " failed"
			exit 1
		else
			echo " done"
		fi
	;;

	restart)
		$0 stop
		$0 start
	;;

	reload)

		echo -n "Reload service php-fpm "

		if [ ! -r ${SPID} ] ; then
			echo "warning, no pid file found - php-fpm is not running ?"
			exit 1
		fi

		kill -USR2 `cat ${SPID}`

		echo " done"
	;;

	configtest)
		${SBIN} -t
	;;

	*)
		echo "Usage: $0 {start|stop|force-quit|restart|reload|status|configtest}"
		exit 1
	;;

esac