#!/bin/bash
docker exec $1 /usr/lib/frr/frr-reload.py --test frr.conf.$1

