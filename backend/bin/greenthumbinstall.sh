#!/bin/bash
# greenthumbinstall

# GreenThumb installation script for newbs
# GreenThumb Group <greenthumb441@umich.edu>

set -Eeuo pipefail
# Uncomment for debugging purposes
# set -x

# check root status
if [[ $(id -u) -ne 0 ]];
then 
    echo "Please run this script as root."
    exit 1
fi

# check that we are in the main backend directory
if [[ $(pwd | grep -c "backend/") -ne 0 ]]; then
    echo "Please execute this script in the main backend/ directory."
    exit 1
fi

echo "Creating python venv..."
python3 -m venv env

echo "Activating venv..."
set +u
source env/bin/activate
set -u

echo "Installing required python packages..."
pip install -e .

echo "Setting up gunicorn service..."