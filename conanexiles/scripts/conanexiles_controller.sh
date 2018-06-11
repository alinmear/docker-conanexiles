#!/bin/bash

source /var/lib/conanexiles/redis_cmds.sh
source /var/lib/conanexiles/notifier.sh

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

check_server_running() {
    if ps axg | grep -F 'ConanSandboxServer' | grep -v -F 'grep' > /dev/null; then
        echo 0
    else
        echo 1
    fi
}

function start_server() {
    # check if server is already running to avoid running it more than one time
    if [[ `check_server_running` == 0 ]];then
        notfier_error "The server is already running. I don't want to start it twice."
        return
    else
        supervisorctl status conanexilesServer | grep RUNNING > /dev/null
        [[ $? != 0 ]] && supervisorctl start conanexilesServer
    fi
}

function stop_server() {
    # stop the server
    supervisorctl status conanexilesServer | grep RUNNING > /dev/null
    [[ $? == 0 ]] && supervisorctl stop conanexilesServer

    # wait until the server process is gone
    while ps axg | grep -F 'ConanSandboxServer' | grep -v -F 'grep' > /dev/null; do 
      notifier_error "Seems I can't stop the server. Help me!"
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
        notifier_info "Removed existing build backup in $_dst"
    fi

    # backup current build db and config
    if [ -d "$_src" ]; then
        cp -a "$_src" "$_dst"

        # Was backup successfull ?
        if [ $? -eq 0 ]; then
            notifier_info "Backed up current build db and configs to $_dst"
        else
            notifier_warn "Failed to backup current build db and configs to $_dst."
        fi
    fi
}

start_update_timer() {
    _t_val="$1"
    _i=0

    while true; do
        if [ $_i == $_t_val ]; then
            break
        fi
        echo "/usr/bin/rconcli broadcast --type shutdown --value $((_t_val - _i))"
        ((i++))
    done
}

function do_update() {
    # stop, backup, update and start again the server
    start_update_timer

    set_update_running_start
    stop_server
    # Give other instances time to shutdown
    sleep 300    backup_server
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

    set_update_running_stop

    start_server
}

#
# Main loop
#

echo "Global Master Server Instance: `get_master_server_instance`"

if [[ "`get_master_server_instance`" == "`hostname`" ]];then
    notifier_info "Mode: Master - Instance: `hostname`"
    while true; do
        # check if an update is needed
        ab=$(get_available_build)
        ib=$(get_installed_build)

        if [[ $ab != $ib ]];then
            notifier_info "New build available. Updating $ib -> $ab"
            do_update
        fi

        # if initial install/update fails try again
        if [ ! -f "/conanexiles/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe" ]; then
            notifier_warn "Initial installation failed. Trying to install/update again"
            do_update
            notifier_debug "Initial installation finished."
        fi

        start_server
        sleep 300
    done
else
    notifier_info "Mode: Slave - Instance: `hostname`"
    while true; do
        if [[ "`get_update_running`" == 0 ]]; then
            [[ `check_server_running` == 0 ]] && \
                stop_server
        else
            [[ `check_server_running` == 1 ]] && \
                start_server
        fi
        sleep 10
    done
fi
