#!/bin/bash

# Disable Ipv6

sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Add bridge and start it up

brctl addbr br0
brctl addif br0 ens192 ens224
ifconfig ens192 up
ifconfig ens224 up
ifconfig br0 up

# Enable iptables for bridge

sysctl -w net.bridge.bridge-nf-call-iptables=1

# Start AAnval ИЗГ and SMT

cd /var/www/html/aanval/apps/
perl idsBackground.pl -start
cd /smt
perl /smt/idsSensor.pl -start

# Start barnyard2

/usr/local/bin/barnyard2 -c /etc/barnyard2.conf -f merged.log -d /var/log/snort -n
