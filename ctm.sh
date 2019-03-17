#!/bin/bash
echo "                            "
echo "       Renew DHCP !!!       "
echo "                            "
NIC=`ls /sys/class/net |grep -v -E 'docker|lo|veth'`
dhclient -r -v $NIC
sleep 1
dhclient -v $NIC