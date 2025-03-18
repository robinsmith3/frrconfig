#!/bin/bash
# docker exec $1 ./reload.sh frr.conf.$1
docker exec $1 /usr/lib/frr/frr-reload.py --reload frr.conf.$1

