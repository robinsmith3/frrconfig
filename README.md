
# Automate restarts for GNS3 networks

- container_names.sh - converts funny names to GNS3 hostnames
- copy_containers.sh - copies necessary files to bring up nodes (still needs daemons file in included files to copy)
- config-file-check.sh - checks loaded configs and reloads from scratch
- download_frr.sh - download to store of initial or pre-running frr node

## IPv6 prefix
2001:db8::n1:n2:n3:n4
2001:db8::0:1:2:1

Where:
- n1 for future use
- n2:n3 p2p link network address
- n4: interface, host or loopback address