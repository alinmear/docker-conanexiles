#!/bin/bash

source /var/lib/conanexiles/notifier.sh

redis_set_update_running_start() {
    redis-cli -h redis SET update_running 0
}

redis_set_update_running_stop() {
    redis-cli -h redis SET update_running 1
}

redis_get_update_running() {
    redis-cli -h redis --raw GET update_running
}

redis_get_initial_install_stat() {
    redis-cli -h redis GET initial_installation
}

redis_get_master_server_instance() {
    redis-cli -h redis GET master_server_instance
}

redis_set_master_server_instance() {
    redis-cli -h redis SET master_server_instance $(hostname)
}

redis_cmd_proxy() {
    redis-cli -h redis PING > /dev/null 2> /dev/null
    [[ $? -eq 0 ]] && $1 || \
            notifier_warn "Failed to connect to redis instance - redis:6379. Skipping redis call: ${1}"
}
