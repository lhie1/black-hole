#!/bin/bash
echo "                            "
echo "       Renew DHCP !!!       "
echo "                            "
chattr -i /etc/resolv.conf
dhclient -r eth0 && \
rm -rf /var/lib/dhcp/*
sleep 1
dhclient -v eth0