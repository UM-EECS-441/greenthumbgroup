#!/bin/bash

# runs the server with gunicorn.
# makes sure that the firewall is configured as well.
set -Eeuo pipefail

# check if sudo & that firewall enables listening to port 5000
check_privileges() {
    # check sudo status
    if [[ $(id -u) -ne 0 ]];
    then 
        echo "Please run this script as root."
        exit 1
    fi
    # check ufw status
    if [[ $(ufw status | grep -c "inactive") -ne 0 ||  $(ufw status | grep -c "5000") -eq 0]];
    then
        echo "Opening port 5000 in ufw"
        ufw allow 5000
    fi
}

start_server() {
    if [ $(pgrep -fc "gunicorn -b 0.0.0.0:5000 wsgi:app") -ne 0 ]; then
        echo "Error: gunicorn already running."
        exit 1
    fi
    echo "Running server in background"
    gunicorn -b 0.0.0.0:5000 wsgi:app &
}

stop_server() {
    echo "Stopping gunicorn..."
    pkill -f "gunicorn -b 0.0.0.0:5000 wsgi:app"
}

restart() {
    check_privileges
    stop_server
    start_server
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
    start_server
    ;;
    "stop")
    check_privileges
    stop_server
    ;;
    "restart")
    restart
    ;;
esac
