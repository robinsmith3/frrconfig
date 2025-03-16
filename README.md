#To add IPv6 networks and hosts to the system#
Gateway v6 address: 2a00:23c6:9c79:3201:42:21ff:fee9:6b00/64
Should we use a public IPv6 space?
What size network /64?

Where a public IP is used for v6 and private for v4
Am open to guidance on this - my rational is a home network NATs v4 but not v6, so why here either. v6 can handle it)

Where 10 id's the whole network prefix

v6 Networks - 2a00:23c6:9c79:3201:10:1:2:1/64

where 10:1:2 is the point to point network link
and 1 is the lower order host and 2 the higher
and the left most 1 (or 2) is interface IP

v6 Hosts (loopbacks) - 2a00:23c6:9c79:3201:10:1:1:1/64

Likewise where 10:1:1:1 is the loopback for node 1
and 1:1 is never going to appear as a network prefix because node 1 does not connect to 1
