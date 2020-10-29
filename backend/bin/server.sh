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
    if [[ $(ufw status | grep -c "inactive") -ne 0 ||  $(ufw status | grep -c "Nginx Full") -eq 0 ]];
    then
        echo "Allowing Nginx in ufw"
        ufw allow "Nginx Full"
    fi
}

start_server() {
    if [ $(pgrep -fc "gunicorn.*wsgi:app") -ne 0 ]; then
        echo "Error: gunicorn already running."
        exit 1
    fi
    echo "systemctl: starting greenthumb..."
    systemctl start greenthumb
}

stop_server() {
    echo "systemctl: stopping greenthumb..."
    systemctl stop greenthumb
}

restart() {
    check_privileges
    stop_server
    echo "systemctl: reloading config files..."
    systemctl daemon-reload
    start_server
}

usage() {
    echo "Usage: ./bin/server.sh (start|stop|restart)"
}

debug() {
    if [ $(pgrep -fc "gunicorn.*wsgi:app") -ne 0 ]; then
        echo "Error: gunicorn already running."
        exit 1
    fi
    if [[ $(pwd | grep -c "backend/") -ne 0 ]]; then
        echo "Please execute this script in the main backend/ directory."
        exit 1
    fi
    export FLASK_ENV=development
    flask run
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
    "debug")
    check_privileges
    debug
    ;;
esac
