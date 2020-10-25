#!/bin/bash
# greenthumbinstall

# GreenThumb installation script for newbs
# GreenThumb Group <greenthumb441@umich.edu>

set -Eeuo pipefail
set -x

python3 -m venv env

set +u
source env/bin/activate
set -u

pip install -e .