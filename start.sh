#!/bin/bash
#set -e

GROUP_NAME=${GROUP_NAME:-"group1"}
NGINX_PORT=${NGINX_PORT:-"8888"}
IS_CLUSTER=${IS_CLUSTER:-"false"}

function fdfs_set () {
    if [ "$1" = "monitor" ] ; then
        if [ -n "$TRACKER_SERVER" ] ; then
          sed -i "s|^tracker_server =.*$|tracker_server = ${TRACKER_SERVER}|g" /etc/fdfs/client.conf
        fi
	#fdfs_monitor /etc/fdfs/client.conf
        /usr/bin/fdfs_monitor /etc/fdfs/client.conf
        exit 0
    elif [ "$1" = "storage" ] ; then
        FASTDFS_MODE="storage"
    else
        FASTDFS_MODE="tracker"
    fi

    if [ -n "$PORT" ] ; then
        sed -i "s|^port =.*$|port = ${PORT}|g" /etc/fdfs/"$FASTDFS_MODE".conf
    fi
    
    if [ -n "$TRACKER_SERVER" ] ; then  
	# single
    	if [ "$IS_CLUSTER" = "false" ] ; then
	   sed -i "s|^tracker_server =.*$|tracker_server = ${TRACKER_SERVER}|g" /etc/fdfs/storage.conf
	   sed -i "s|^tracker_server =.*$|tracker_server = ${TRACKER_SERVER}|g" /etc/fdfs/client.conf
	   #注意：mod_fastdfs.conf的等号旁边是没有空格的
	   sed -i "s|^tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/mod_fastdfs.conf
	fi
        # cluster
	# add more tracker_server in storage.conf,client.conf,mod_fastdfs.conf
	# tracker_server = ip1:22122
	# tracker_server = ip2:22122
	# tracker_server = ip3:22122
	# cluster must be like this when docker run
	# /etc/fdfs/storage.conf:/etc/fdfs/storage.conf
	# /etc/fdfs/client.conf:/etc/fdfs/client.conf
	# /etc/fdfs/mod_fastdfs.conf:/etc/fdfs/mod_fastdfs.conf
    fi
    
    sed -i "s|^group_name =.*$|group_name = ${GROUP_NAME}|g" /etc/fdfs/storage.conf
    
    FASTDFS_LOG_FILE="${FASTDFS_BASE_PATH}/${FASTDFS_MODE}/logs/${FASTDFS_MODE}d.log"
    #PID_NUMBER="${FASTDFS_BASE_PATH}/${FASTDFS_MODE}/data/fdfs_${FASTDFS_MODE}d.pid"
    
    # start the fastdfs node.
    fdfs_${FASTDFS_MODE}d /etc/fdfs/${FASTDFS_MODE}.conf start
    #/etc/init.d/fdfs_${FASTDFS_MODE}d start
}

function nginx_set () {
    # start nginx.
    if [ "${FASTDFS_MODE}" = "storage" ]; then
	 #sed -i "s|^listen .*$|listen $NGINX_PORT;|g" /usr/local/nginx/conf/nginx.conf
         /usr/local/nginx/sbin/nginx
    fi
}

#function health_check() {
#    if [ $HOSTNAME = "localhost.localdomain" ]; then
#        return 0
#    fi
#    # Storage OFFLINE, restart storage.
#    monitor_log=/tmp/monitor.log
#    check_log=/tmp/health_check.log
#    while true; do
#        fdfs_monitor /etc/fdfs/client.conf 1>$monitor_log 2>&1
#        cat $monitor_log|grep $HOSTNAME > $check_log 2>&1
#        error_log=$(egrep "OFFLINE" "$check_log")
#        if [ ! -z "$error_log" ]; then
#            cat /dev/null > "$FASTDFS_LOG_FILE"
#            fdfs_${FASTDFS_MODE}d /etc/fdfs/${FASTDFS_MODE}.conf stop
#            fdfs_${FASTDFS_MODE}d /etc/fdfs/${FASTDFS_MODE}.conf start
#        fi
#        sleep 10
#    done
#}

fdfs_set $*
nginx_set $*
#health_check &

## wait for pid file(important!),the max start time is 5 seconds,if the pid number does not appear in 5 seconds,start failed.
#TIMES=5
#while [ ! -f "$PID_NUMBER" -a $TIMES -gt 0 ]
#do
#    sleep 1s
#    TIMES=`expr $TIMES - 1`
#done

tail -f "$FASTDFS_LOG_FILE"