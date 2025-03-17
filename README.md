# To migrate the network to IPv6 networks and hosts
## Gateway v6 address
```2a00:23c6:9c79:3201:42:21ff:fee9:6b00/64``` 
- A supplemental issue here being how to handle a non static allocation by the ISP

## Network Prefix
``2a00:23c6:9c79:3201::::/64``

## All numbering in hex
- Network prefix size /120
- on a dymanic re-allocation could use SED to adjust all configs and reload nodes

## Should we use a public IPv6 space?
- Where a public IP space is used for v6 and private for v4 \
- Am open to guidance on this - my rational is a home network NATs v4 but not v6, so why here either? v6 can handle it

## v6 p2p Networks
``2a00:23c6:9c79:3201::1:2:2/120`` \
``2a00:23c6:9c79:3201::lower-order-node:higher-order-node:to-node:/116`` 

## v6 Hosts (loopbacks)
``2a00:23c6:9c79:3201::1/128`` 
- likewise where the above host address is the loopback for say node 1
