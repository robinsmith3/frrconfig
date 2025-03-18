tar -cvf temp.tar frr.conf.$1 reload.sh reload-test.sh
docker cp temp.tar $1:/etc/frr
docker exec $1 tar -xvf /etc/frr/temp.tar -C /etc/frr
docker exec $1 rm /etc/frr/temp.tar
