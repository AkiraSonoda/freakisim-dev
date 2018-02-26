#!/bin/bash
#

stop (){
  #First we want to kill the original servers, so we don't get errors.
  echo "Removing Surabaya process"
  cd /opt/wildfly/bin
  ./jboss-cli.sh --connect command=:shutdown
  for oldpid in `ps ax|grep "org.jboss.as.standalone"|grep -v grep | cut -c 1-6`; do
    sleep 30
    kill -9 `ps ax|grep "org.jboss.as.standalone"|grep -v grep | cut -c 1-6`
  done
  rm -f /tmp/surabaya.pid
}


start (){
  cd /opt/wildfly/bin
  sleep 30
  nohup ./standalone.sh > /dev/null 2>&1 &
  #Create the pid file...
  sleep 10
  ps ax|grep "org.jboss.as.standalone"|grep -v grep | cut -c 1-6 > /tmp/surabaya.pid
  #Done now!
  echo "Started the surabaya server."
}


case "$1" in
  start)  	
    if [[ ! -e /tmp/surabaya.pid ]]
    then
	start $2
	if [[ -e /tmp/surabaya.pid ]] 
	then		
		echo "Startup [SUCCESS]"
	fi
    else
	echo "suarabaya is already running. Try calling shoutcast restart."
	echo "Startup 						[FAILED]"
    fi
  ;;
  restart)
    stop $2
    start $2
    if [[ -e /tmp/surabaya.pid ]] 
    then		
	echo "Startup 						[SUCCESS]"
    fi
  ;;
  stop)
    if [[ -e /tmp/surabaya.pid ]];
    then
	stop 
	echo "Surabaya shutdown 					[SUCCESS]"
    else
  	echo "There are no registered surabaya servers running right now. Attempting to kill anyways."
	stop
  	echo "There are no registered surabaya servers running right now. Attempting to kill anyways."
	
    fi
  ;;
  *)
  	echo "Usage: Surabaya_Start.sh (start|stop|restart)"

esac
