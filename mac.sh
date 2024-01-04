#!/bin/bash

# TODO: Some boards may not have a fixed MAC address and get a random address
# every boot. This can be very annoying regarding getting a stable IP address
# from a DHCP server, and may pollute the devices list in the router.
# As a fix, provide a MAC address at the kernel arguments. This address 
# should picked at random, but then stay the same. Some code to generate
# such a MAC address

macaddr=$(echo -n 02; od -t x1 -An -N 5 /dev/urandom | tr ' ' ':')
echo $macaddr
