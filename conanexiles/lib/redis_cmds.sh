function set_update_running_start(){
    echo 0 | redi.sh -s update_running -H redis
}

function set_update_running_stop(){
    echo 1 | redi.sh -s update_running -H redis
}

function get_update_running(){
    redi.sh -g update_running -H redis
}

function set_initial_install_stat_success(){
    echo 0 | redi.sh -s initial_installation -H redis
}

function set_initial_install_stat_fail(){
    echo 1 | redi.sh -s initial_installation -H redis
}

function get_initial_install_stat(){
    redi.sh -g initial_installation -H redis
}

function get_master_server_instance(){
    redi.sh -g master_server_instance -H redis
}

function set_master_server_instance(){
    echo `hostname` | redi.sh -s master_server_instance -H redis
}






