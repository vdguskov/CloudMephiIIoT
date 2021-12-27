#!/bin/bash

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

echo "Executing service in '$BASEDIR'"

cd $BASEDIR

sudo docker-compose start
