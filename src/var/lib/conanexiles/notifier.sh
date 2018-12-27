#!/bin/sh

notifier_info() {
    echo ">> INFO: $1"
}

notifier_debug() {
    echo ">> DEBUG: $1"
}

notifier_error() {
    echo ">> ERROR: $1"
}

notifier_warn() {
    echo ">> WARN: $1"
}
