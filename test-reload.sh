#!/bin/bash
#/usr/lib/frr/frr-reload.py --test $1
#docker exec $1 ./reload-test.sh frr.conf.$1
docker exec $1 /usr/lib/frr/frr-reload.py --test frr.conf.$1

