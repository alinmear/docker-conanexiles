source /var/lib/conanexiles/notifier.sh

redis_set_update_running_start(){
    echo 0 | redi.sh -s update_running -H redis
}

redis_set_update_running_stop(){
    echo 1 | redi.sh -s update_running -H redis
}

redis_get_update_running(){
    redi.sh -g update_running -H redis
}

redis_get_initial_install_stat(){
    redi.sh -g initial_installation -H redis
}

redis_get_master_server_instance(){
    redi.sh -g master_server_instance -H redis
}

redis_set_master_server_instance(){
    echo `hostname` | redi.sh -s master_server_instance -H redis
}

_check_connection() {
    _host=$1
    _port=$2

    bash -c "cat < /dev/null > /dev/tcp/${_host}/${_port}" >/dev/null 2>/dev/null
    return $?
}

redis_cmd_proxy() {
    _check_connection redis 6379
    [[ $? == 0 ]] && $1 || \
            notifier_warn "Failed to connect to redis instance - redis:6379. Skipping redis call: ${1}"
}
