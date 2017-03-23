#!/bin/bash

# _current_timestamp=0
_current_build_id=0
# _last_timestamp=0
_last_build_id=0

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

function do_update() {
    update_server
    
    # wait till update is finished
    while $(supervisorctl status conanexilesUpdate | grep RUNNING > /dev/null); do
	sleep 1
    done

    # echo $_current_timestamp > /conanexiles/lastUpdate
    echo $_current_build_id > /conanexiles/lastUpdate
}

while true; do
    # _current_timestamp=$(/steamcmd/steamcmd.sh +login anonymous +app_info_update 1 +app_info_print 443030 +quit | \
    			    # grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | \
    			    # grep -m 1 -EB 10 "^\s+}" | grep -E "^\s+\"timeupdated\"\s+" | \
    			    # tr '[:blank:]"' ' ' | awk '{print $2}')

    _current_build_id=$(/steamcmd/steamcmd.sh +login anonymous +app_info_update 1 +app_info_print 443030 +quit | \
    			    grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | \
    			    grep -m 1 -EB 10 "^\s+}" | grep -E "^\s+\"buildid\"\s+" | \
    			    tr '[:blank:]"' ' ' | awk '{print $2}')
    
    # [ -f /conanexiles/lastUpdate ] && _last_timestamp=$(cat /conanexiles/lastUpdate) 
    [ -f /conanexiles/lastUpdate ] && _last_build_id=$(cat /conanexiles/lastUpdate) 

    # if [[ $_current_timestamp > $_last_timestamp ]];then
    if [[ $_current_build_id != $_last_build_id ]];then
	do_update
    fi

    # if initial update fails do this
    [ ! -f "/conanexiles/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe" ] && do_update

    start_server
    sleep 60
done
