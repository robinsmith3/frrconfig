tar -cvf temp.tar *
docker cp temp.tar $1:/etc/frr
docker exec $1 tar -xvf /etc/frr/temp.tar -C /etc/frr
docker exec $1 rm /etc/frr/temp.tar
