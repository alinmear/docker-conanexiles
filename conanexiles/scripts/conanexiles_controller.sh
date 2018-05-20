#!/bin/bash
APPID=443030

function get_available_build() {
    # clear appcache (to avoid reading infos from cache)
    rm -rf /root/Steam/appcache

    # get available build id and return it
    local _build_id=$(/steamcmd/steamcmd.sh +login anonymous +app_info_update 1 +app_info_print $APPID +quit | \
    			    grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | \
    			    grep -m 1 -EB 10 "^\s+}" | grep -E "^\s+\"buildid\"\s+" | \
    			    tr '[:blank:]"' ' ' | awk '{print $2}')

    echo $_build_id
}

function get_installed_build() {
    # get currently installed build id and return it
    local _build_id=$(cat /conanexiles/steamapps/appmanifest_$APPID.acf | \
              grep -E "^\s+\"buildid\"" |  tr '[:blank:]"' ' ' | awk '{print $2}')

    echo $_build_id
}

function start_server() {
    # check if server is already running to avoid running it more than one time
    if ps axg | grep -F 'ConanSandboxServer' | grep -v -F 'grep' > /dev/null; then
        echo "Error: The server is already running. I don't want to start it twice."
        return
    fi

    # start the server
    supervisorctl status conanexilesServer | grep RUNNING > /dev/null
    [[ $? != 0 ]] && supervisorctl start conanexilesServer
}

function stop_server() {
    # stop the server
    supervisorctl status conanexilesServer | grep RUNNING > /dev/null
    [[ $? == 0 ]] && supervisorctl stop conanexilesServer

    # wait until the server process is gone
    while ps axg | grep -F 'ConanSandboxServer' | grep -v -F 'grep' > /dev/null; do 
      echo "Error: Seems I can't stop the server. Help me!"
      sleep 5
    done
}

function update_server() {
    # update server  
    supervisorctl status conanexilesUpdate | grep RUNNING > /dev/null
    [[ $? != 0 ]] && supervisorctl start conanexilesUpdate
}

function backup_server() {
    # backup the server db and config
    local _src="/conanexiles/ConanSandbox/Saved"
    local _dst="/conanexiles/ConanSandbox/Saved.$(get_installed_build)"

    # remove backup dir if already exists (should never happen)
    if [ -d "$_dst" ]; then
        rm -rf "$_dst"
        echo "Info: Removed existing build backup in $_dst"
    fi

    # backup current build db and config
    if [ -d "$_src" ]; then
        cp -a "$_src" "$_dst"

        # Was backup successfull ?
        if [ $? -eq 0 ]; then
            echo "Info: Backed up current build db and configs to $_dst"
        else
            echo "Warning: Failed to backup current build db and configs to $_dst."
        fi
    fi
}

function do_update() {
    # stop, backup, update and start again the server
    stop_server
    backup_server
    update_server
        
    # wait till update is finished
    while $(supervisorctl status conanexilesUpdate | grep RUNNING > /dev/null); do
        sleep 1
    done

    # check if server is up to date
    local _ab=$(get_available_build)
    local _ib=$(get_installed_build)

    if [[ $_ab != $_ib ]];then
        echo "Warning: Update seems to have failed. Installed build ($_ib) does not match available build ($_ab)."
    else
        echo "Info: Updated to build ($_ib) successfully."
    fi

    start_server
}

#
# Main loop
#
while true; do
    # check if an update is needed
    ab=$(get_available_build)
    ib=$(get_installed_build)

    if [[ $ab != $ib ]];then
        echo "Info: New build available. Updating $ib -> $ab"
        do_update
    fi

    # if initial install/update fails try again
    [ ! -f "/conanexiles/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe" ] && do_update

    start_server
    sleep 300
done
