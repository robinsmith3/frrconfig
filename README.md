# To add IPv6 networks and hosts to the system
## Gateway v6 address
```2a00:23c6:9c79:3201:42:21ff:fee9:6b00/64``` 

- Network prefix size /64
- A supplemental issue here being how to handle a non static allocation by the ISP
- on a dymanic re-allocation could use SED to adjust all configs and reload nodes

## Should we use a public IPv6 space?
- Where a public IP space is used for v6 and private for v4 \
- Am open to guidance on this - my rational is a home network NATs v4 but not v6, so why here either? v6 can handle it

## v6 Networks
``2a00:23c6:9c79:3201:10:1:2:1/64`` 
- where `10` id's the whole network prefix
- where ``10:1:2:n`` is the point to point network prefix
- with lower order node on the left
- and the right most n is the node id

## v6 Hosts (loopbacks)
``2a00:23c6:9c79:3201:10:1:1:1/64`` 
- likewise where ``10:1:1:1`` is the loopback for say node 1
- the right most 1 completing the node id
- ``10:1:1`` is never going to appear as a network prefix 
- because node 1 cannot connect to node 1 across a p2p link
