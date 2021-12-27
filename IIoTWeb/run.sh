#!/bin/bash

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

echo "Executing service in '$BASEDIR'"

cd $BASEDIR

source $BASEDIR/web_server/bin/activate
pip install -r requirements.in

python3 $BASEDIR/app.py
