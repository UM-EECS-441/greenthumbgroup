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

echo "Installing required python packages..."
pip install -e .

echo "Installing MongoDB v4.4..."
curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt update
apt install mongodb-org
systemctl start mongod.service
systemctl enable mongod

echo "Enabling UFW..."
ufw enable

echo "Setting up gunicorn service..."
cp scripts/greenthumb.service /etc/systemd/system/
echo "Copying nginx config files..."
cp scripts/greenthumb /etc/nginx/sites-available/
echo "Enabling greenthumb in nginx..."
ln -s /etc/nginx/sites-available/greenthumb /etc/nginx/sites-enabled/

systemctl enable greenthumb
bin/server.sh start

echo "Installation complete."