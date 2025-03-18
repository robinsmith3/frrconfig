#!/bin/bash
docker exec $1 /usr/lib/frr/frr-reload.py --reload frr.conf.$1

