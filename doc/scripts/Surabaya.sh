#!/bin/bash
#
# chkconfig: 345  91 35
# description: Starts and stops sc_serv. 
#	       You know, the mp3 streaming thang.
#
#	Version 1.3 (nov 4 2001)
#	Now with more revisions! System now checks for pid file before cat
#	to display so that we receive no error messages. System also displays
#	pids as we are killing old processes. Profanity was removed from the 
#	startup messages. Tests for a pid file before reporting success. Displays
#	the relay server name when we start the daemon up, so that we know
#	which servers are getting booted. Pushed the success marker over to the 
#	right and added [] because I am just a slave to fashion.
#
#	Version 1.2 (nov 3 2001)
#	Same exact shit, but runs as nobody for security reasons. Just
#	in case we are worried about buffer overflows or whatnot.
#	
#	Version 1.1 (nov 3 2001)
#	Starts stops and restarts jobs. Also checks for existing daemons
#	before calling a start, and exits without starting new ones. This
#	prevents you from being a dumbass and starting multiple listeners
#	on the same port. I would suggest using the restart command
#	in these cases. Also creates a shoutcast.pid file that can be used
#	to discover all of the (many) pids used by shoutcast when running.
#
#	Version 1.0 (nov 3 2001) 
#	Starts and stops successfully. 
#	Kills old jobs on start command. Dirty, but 
#	does the job well enough. Tested functional on
#	mandrake version 8.1 but should work on redhat 
#	or any other distro that supports a standard 
#	sysv startup script.
#
#	Instructions for use.
#	1: untargzip shoutcast into the directory of your choosing
#	2: copy sc_serv into the /usr/sbin directory 
#	3: Create the directory /etc/shoutcast
#	4: copy the shoutcast.conf file into your /etc/shoutcast dir.
#	5: Edit the shoutcast.conf file to match your needs.
#	6: Make as many more conf files as needed to support 
#	   multiple streams. Be sure to edit these files so that
#	   you are not starting multiple shoutcast servers that
#	   are either listening or broadcasting on the same port.
#	7: Copy this file into the /etc/rc.d/init.d directory
#	8: chmod this file +x (chmod ug+x /etc/rc.d/init.d/shoutcast)
#	9: run chkconfig --add shoutcast from the /etc/rc.d/init.d dir.
#	10:Run /etc/rc.d/init.d/shoutcast start 
#	11:Drink a beer, or light one up, and enjoy the tunes.
#

# Source networking configuration.
#. /etc/sysconfig/network

# Check that networking is up. This line may cause an error on incompatible
# distributions. Remove it if necessary. Also remove if the startup always
# fails for no apparent reason.
#c[[ ${NETWORKING} = "no" ]] && exit 0


stop (){
  #First we want to kill the original servers, so we don't get errors.
  echo "Removing Surabaya process"
  cd /opt/wildfly/bin
  ./jboss-cli.sh --connect command=:shutdown
  for oldpid in `ps ax|grep "org.jboss.as.standalone"|grep -v grep | cut -c 1-6`; do
    sleep 10
  done
  rm -f /tmp/surabaya.pid
}


start (){
  cd /opt/wildfly/bin
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
		echo "Startup 						[SUCCESS]"
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