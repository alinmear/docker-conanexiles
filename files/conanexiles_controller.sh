#!/bin/bash

_current_timestamp=0
_last_timestamp=0

start_server() {
    supervisorctl status conanexilesServer | grep RUNNING > /dev/null
    [[ $? != 0 ]] && supervisorctl start conanexilesServer
}

update_server() {

    supervisorctl status conanexilesServer | grep RUNNING > /dev/null
    [[ $? == 0 ]] && supervisorctl stop conanexilesServer

    supervisorctl status conanexilesUpdate | grep RUNNING > /dev/null
    [[ $? != 0 ]] && supervisorctl start conanexilesUpdate
}

while true; do
    current_timestamp=$(/steamcmd/steamcmd.sh +login anonymous +app_info_update 1 +app_info_print 443030 +quit | \
			    grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | \
			    grep -m 1 -EB 10 "^\s+}" | grep -E "^\s+\"timeupdated\"\s+" | \
			    tr '[:blank:]"' ' ' | awk '{print $2}')

    [ -f /conanexiles/lastUpdate ] && last_timestamp=$(cat /conanexiles/lastUpdate) 

    if [[ $_current_timestamp > $last_timestamp ]];then
	update_server

	# wait till update is finished
	while supervisorctl status conanexilesUpdate | grep RUNNING > /dev/null; do
	    sleep 1
	done
	start_server
    fi

    # check server is running
    supervisorctl status conanexilesServer | grep RUNNING > /dev/null; do
    [[ $? != 0 ]] && start_server

    sleep 10
done
