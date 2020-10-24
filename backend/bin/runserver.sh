#!/bin/bash

# runs the server with gunicorn
set -Eeuo pipefail
set -x

gunicorn -b 0.0.0.0:5000 wsgi:app