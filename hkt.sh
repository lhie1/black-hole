#!/bin/bash
echo "                            "
echo "       Renew DHCP !!!       "
echo "                            "
chattr -i /etc/resolv.conf
NIC=`ls /sys/class/net |grep -v -E 'docker|lo|veth'`
dhclient -r $NIC && \
rm -rf /var/lib/dhcp/*
sleep 1
dhclient -v $NIC