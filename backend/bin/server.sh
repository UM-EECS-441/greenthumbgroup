#!/bin/bash

# runs the server with gunicorn.
# makes sure that the firewall is configured as well.
set -Eeuo pipefail
set -x

# check if sudo & that firewall enables listening to port 5000
check_privileges() {
    # check sudo status
    if [[ $(id -u) -ne 0 ]];
    then 
        echo "Please run this script as root."
        exit 1
    fi
    # check ufw status
    if [![ $(ufw status | grep -c "inactive") -eq 0 ||  $(ufw status | grepc -c "5000") -gt 0]];
    then
        echo "Opening port 5000 in ufw"
        ufw allow 5000
    fi
}

run_server() {
    echo "Running server in background"
    gunicorn -b 0.0.0.0:5000 wsgi:app &
}

usage() {
    echo "Usage: ./bin/server.sh (start|stop|restart)"
}

if [ $# -ne 1 ]; then
    usage 
    exit 1
fi

case $1 in
    "start")
    check_privileges
    run_server
    ;;
    "stop")
    check_privileges
    stop_server
    ;;
    "restart")
    restart
    ;;
esac
