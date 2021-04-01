#!/bin/sh

notifier_info() {
    echo "`date "+%F %T"` INFO $1"
}

notifier_debug() {
    echo "`date "+%F %T"` DEBUG $1"
}

notifier_error() {
    echo "`date "+%F %T"` ERROR $1"
}

notifier_warn() {
    echo "`date "+%F %T"` WARN $1"
}
